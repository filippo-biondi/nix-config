"""Checks that a host's latest archive is in S3, set up by ccg.backup
(modules/nixos/backup).

check <settings>, with <settings> ccg.backup as JSON: fails if the newest
archive in the host's folder of the bucket is older than a month and its
slack, or if there's none.
"""

import datetime
import json
import sys

import boto3

# The monthly timer, its random delay, a late start and the upload, with a day to spare
MAX_AGE = datetime.timedelta(days=32)


def main():
    with open(sys.argv[1]) as file:
        settings = json.load(file)
    pages = boto3.client("s3", region_name=settings["region"]).get_paginator("list_objects_v2").paginate(
        Bucket=settings["bucket"], Prefix=f"{settings['host']}/")
    latest = max((archive["LastModified"] for page in pages for archive in page.get("Contents", [])), default=None)

    if latest is None:
        sys.exit("No archive in S3")
    age = datetime.datetime.now(datetime.UTC) - latest
    if age > MAX_AGE:
        sys.exit(f"The latest archive in S3 is from {latest:%Y-%m-%d}, {age.days} days ago")
    print(f"The latest archive in S3 is from {latest:%Y-%m-%d}")


if __name__ == "__main__":
    main()
