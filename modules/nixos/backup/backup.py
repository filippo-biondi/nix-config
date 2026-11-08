"""The monthly backup of a host, set up by ccg.backup (modules/nixos/backup).

backup <settings>, with <settings> ccg.backup as JSON: gathers the dumps and
copies of the services' data, taken with their units stopped, then archives
them with the paths it reads in place, a tar with zstd encrypted with age to
the backup key, and uploads that to S3 Glacier Deep Archive.
"""

import datetime
import json
import os
import pwd
import subprocess
import sys
import tempfile

import boto3


def prepare(settings, staging):
    # First, while everything runs: a database dump then never refers to files
    # that the backup, which reads the paths after, lacks
    os.mkdir(f"{staging}/dumps")
    for name, dump in settings["dumps"].items():
        # As its user, never as root, with nothing but its output
        with open(f"{staging}/dumps/{name}", "wb") as output:
            subprocess.run(dump["command"], stdout=output, env={}, check=True,
                           user=dump["user"], group=pwd.getpwnam(dump["user"]).pw_gid, extra_groups=[])

    for service in settings["services"].values():
        # Copied with its units stopped, so that what it writes is consistent
        running = [unit for unit in service["units"]
                   if subprocess.run(["systemctl", "is-active", "--quiet", unit]).returncode == 0]
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
        subprocess.run(["tar", "--create", "--zstd", "--file", tarball,
                        "--directory", "/", *(path.lstrip("/") for path in settings["paths"]),
                        "--directory", staging, "."], check=True)
        subprocess.run(["age", "--recipients-file", settings["recipients"],
                        "--output", f"{tarball}.age", tarball], check=True)
        os.remove(tarball)

        boto3.client("s3", region_name=settings["region"]).upload_file(
            f"{tarball}.age", settings["bucket"], f"{settings['host']}/{date}.tar.zst.age",
            ExtraArgs={"StorageClass": "DEEP_ARCHIVE"})


def main():
    with open(sys.argv[1]) as file:
        archive_to_s3(json.load(file))


if __name__ == "__main__":
    main()
