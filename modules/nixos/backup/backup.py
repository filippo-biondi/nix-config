"""The monthly backup of a host, set up by ccg.backup (modules/nixos/backup).

backup <settings>, with <settings> ccg.backup as JSON: gathers the dumps and
copies of the services' data, taken with their units stopped, then archives
them with the paths it reads in place, a tar with zstd encrypted with age to
the backup key, and uploads that to S3 Glacier Deep Archive.
"""

import datetime
import json
import logging
import os
import pwd
import subprocess
import sys
import tempfile
import time

import boto3

log = logging.getLogger("backup")


def size(path):
    return f"{os.path.getsize(path) / 2**30:.1f} GiB"


def prepare(settings, staging):
    # First, while everything runs: a database dump then never refers to files
    # that the backup, which reads the paths after, lacks
    os.mkdir(f"{staging}/dumps")
    for name, dump in settings["dumps"].items():
        # As its user, never as root, with nothing but its output
        log.info("Dumping %s, as %s", name, dump["user"])
        with open(f"{staging}/dumps/{name}", "wb") as output:
            subprocess.run(dump["command"], stdout=output, env={}, check=True,
                           user=dump["user"], group=pwd.getpwnam(dump["user"]).pw_gid, extra_groups=[])

    for name, service in settings["services"].items():
        # Copied with its units stopped, so that what it writes is consistent
        running = [unit for unit in service["units"]
                   if subprocess.run(["systemctl", "is-active", "--quiet", unit]).returncode == 0]
        log.info("Copying %s%s", name, f", with {', '.join(running)} stopped" if running else "")
        if running:
            subprocess.run(["systemctl", "stop", *running], check=True)
        try:
            subprocess.run(["cp", "-a", "--parents", *service["paths"], staging], check=True)
        finally:
            if running:
                subprocess.run(["systemctl", "start", *running], check=True)


def archive_to_s3(settings):
    date = datetime.date.today().isoformat()
    with tempfile.TemporaryDirectory(dir="/var/tmp") as work:
        staging = f"{work}/staging"
        os.mkdir(staging)
        prepare(settings, staging)

        tarball = f"{work}/archive.tar.zst"
        log.info("Archiving %s and the copies", ", ".join(settings["paths"]))
        subprocess.run(["tar", "--create", "--zstd", "--file", tarball,
                        "--directory", "/", *(path.lstrip("/") for path in settings["paths"]),
                        "--directory", staging, "."], check=True)
        log.info("Encrypting the archive, %s", size(tarball))
        subprocess.run(["age", "--recipients-file", settings["recipients"],
                        "--output", f"{tarball}.age", tarball], check=True)
        os.remove(tarball)

        destination = f"{settings['host']}/{date}.tar.zst.age"
        log.info("Uploading it to s3://%s/%s, %s", settings["bucket"], destination, size(f"{tarball}.age"))
        start, uploaded = time.monotonic(), 0

        # Called by the upload's threads with each part's bytes: a line per GiB
        def progress(count):
            nonlocal uploaded
            before, uploaded = uploaded, uploaded + count
            if uploaded // 2**30 > before // 2**30:
                log.info("Uploaded %d GiB", uploaded // 2**30)

        boto3.client("s3", region_name=settings["region"]).upload_file(
            f"{tarball}.age", settings["bucket"], destination,
            ExtraArgs={"StorageClass": "DEEP_ARCHIVE"}, Callback=progress)
        log.info("Uploaded in %d minutes", (time.monotonic() - start) / 60)


def main():
    # Into the journal, which adds the time; of the libraries, only their warnings
    logging.basicConfig(level=logging.WARNING, format="%(message)s")
    log.setLevel(logging.INFO)
    with open(sys.argv[1]) as file:
        archive_to_s3(json.load(file))


if __name__ == "__main__":
    main()
