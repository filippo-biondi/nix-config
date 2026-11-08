{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.ccg.backup;

  # Each month, one archive of everything: tar, zstd, then age to the backup key, whose
  # private half is only in Bitwarden. It goes to S3 Glacier Deep Archive, where AWS
  # keeps it 180 days (packages/backups-stack). To restore one, with the backup key:
  #   aws s3api restore-object --bucket <bucket> --key <host>/<date>.tar.zst.age \
  #     --restore-request '{"Days": 7, "GlacierJobParameters": {"Tier": "Bulk"}}'
  #   then, within 48 hours: aws s3 cp s3://<bucket>/<host>/<date>.tar.zst.age - | age -d -i <key> | zstd -d | tar -x
  # and a database with: pg_restore --create --dbname postgres dumps/<name>
  backup = pkgs.writers.writePython3 "backup" {
    libraries = [pkgs.python3Packages.boto3];
    flakeIgnore = ["E501"];
  } (builtins.readFile ./backup.py);
  settings = pkgs.writeText "backup.json" (builtins.toJSON {
    inherit (cfg) paths services dumps;
    bucket = lib.ccg.backupBucket;
    region = "us-east-1";
    host = config.networking.hostName;
    recipients = "${inputs.secrets}/keys/backup";
  });
in {
  options.ccg.backup = {
    enable = lib.ccg.mkBoolOpt' false;
    # Told when a backup fails
    notifier = lib.mkOption {type = lib.ccg.notifierType;};

    # Set by the modules of the services whose data they are. Read as they are:
    # files that are only added, never changed in place
    paths = lib.ccg.mkOpt' (lib.types.listOf lib.types.str) [];
    # Copied while the service's units are stopped: by default, the unit of its name
    services = lib.ccg.mkOpt' (lib.types.attrsOf (lib.types.submodule ({name, ...}: {
      options = {
        # Stopped together, so a socket with its service
        units = lib.ccg.mkOpt' (lib.types.listOf lib.types.str) [name];
        paths = lib.ccg.mkOpt' (lib.types.listOf lib.types.str) [];
      };
    }))) {};
    # Commands that write a dump, such as a database's, to their output, run as
    # their user, never as root. It lands in dumps/<name>
    dumps = lib.ccg.mkOpt' (lib.types.attrsOf (lib.types.submodule {
      options = {
        user = lib.mkOption {type = lib.types.str;};
        command = lib.mkOption {type = lib.types.listOf lib.types.str;};
      };
    })) {};
  };

  config = lib.mkIf cfg.enable {
    systemd.services.backup-archive = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      onFailure = ["backup-archive-failed.service"];
      # What the script runs
      path = with pkgs; [age coreutils gnutar systemd zstd];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backup} ${settings}";
        EnvironmentFile = config.sops.templates."aws-backup.env".path;
      };
    };
    systemd.timers.backup-archive = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "monthly";
        # Run at boot instead if the machine was off then
        Persistent = true;
        RandomizedDelaySec = "6h";
      };
    };

    systemd.services.backup-archive-failed = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.notifier.send} 'the monthly backup failed, see journalctl -u backup-archive'";
      };
    };

    # The key of backup-writer, which may only upload into the bucket
    sops.secrets = lib.genAttrs ["aws-backup/access-key-id" "aws-backup/secret-access-key"] (_: {
      sopsFile = "${inputs.secrets}/secrets/aws-backup.yaml";
    });
    sops.templates."aws-backup.env".content = ''
      AWS_ACCESS_KEY_ID=${config.sops.placeholder."aws-backup/access-key-id"}
      AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."aws-backup/secret-access-key"}
    '';
  };
}
