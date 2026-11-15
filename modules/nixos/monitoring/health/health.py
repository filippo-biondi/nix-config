"""Checks a host's health, set up by ccg.monitoring.health
(modules/nixos/monitoring/health).

health <settings>, with <settings> as JSON: the threshold, the notifier's
send, and the file that keeps the problems last reported. It finds full
filesystems and failed systemd units, and reports through the notifier
when they change: those that appeared, with how bad they are, and those
resolved. A problem is known by what it is, such as a filesystem over the
threshold, so that one getting worse isn't reported again.
"""

import json
import os
import subprocess
import sys

# Filesystems on disks, not in memory
DISK_TYPES = {"ext2", "ext3", "ext4", "btrfs", "xfs", "f2fs", "vfat", "zfs"}


def full_filesystems(threshold):
    seen = set()
    with open("/proc/self/mounts") as mounts:
        for line in mounts:
            _, target, kind = line.split()[:3]
            if kind not in DISK_TYPES:
                continue
            # Once per filesystem, which may also be mounted elsewhere, like / at /nix/store
            device = os.stat(target).st_dev
            if device in seen:
                continue
            seen.add(device)
            usage = os.statvfs(target)
            used = usage.f_blocks - usage.f_bfree
            # As df counts it: what's left for anyone but root is free
            percent = 100 * used // (used + usage.f_bavail) if used + usage.f_bavail else 0
            print(f"{target} is {percent}% full", flush=True)
            if percent >= threshold:
                yield f"{target} is over {threshold}% full", f"{target} is {percent}% full"


def failed_units():
    output = subprocess.run(["systemctl", "--failed", "--no-legend", "--plain"],
                            capture_output=True, text=True, check=True).stdout
    for line in output.splitlines():
        problem = f"{line.split()[0]} failed"
        yield problem, problem


def main():
    with open(sys.argv[1]) as file:
        settings = json.load(file)
    # Each problem, and what to say about it
    problems = dict([*full_filesystems(settings["threshold"]), *failed_units()])

    try:
        with open(settings["state"]) as file:
            reported = set(json.load(file))
    except FileNotFoundError:
        reported = set()

    lines = [*(problems[problem] for problem in sorted(problems.keys() - reported)),
             *(f"resolved: {problem}" for problem in sorted(reported - problems.keys()))]
    if lines:
        subprocess.run([settings["send"], "\n".join(lines)], check=True)
    # Only once it's sent, so that a failed send is tried again next time
    with open(settings["state"], "w") as file:
        json.dump(sorted(problems), file)


if __name__ == "__main__":
    main()
