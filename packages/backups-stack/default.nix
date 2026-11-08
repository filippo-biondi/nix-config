{
  lib,
  pkgs,
  ...
}:
# The CloudFormation template of the AWS side of the backups, synthesized from
# app.ts. Deployed by hand, with an AWS admin's credentials:
#   nix build .#backups-stack
#   aws cloudformation deploy --region us-east-1 --stack-name backups --capabilities CAPABILITY_NAMED_IAM \
#     --template-file result/backups.template.json --parameter-overrides AlertEmail=<email>
# then, once, the hosts' key, for nix-secrets' secrets/aws-backup.yaml:
#   aws iam create-access-key --user-name backup-writer
pkgs.buildNpmPackage {
  pname = "backups-stack";
  version = "1";
  src = ./.;
  npmDepsHash = "sha256-jRIUxiKACDLQ12+I3cF2RMlQwmG8CLGuO//VMgDE864=";
  nodejs = pkgs.nodejs_24;

  buildPhase = ''
    BUCKET=${lib.ccg.backupBucket} CDK_OUTDIR=cdk.out node app.ts
  '';
  installPhase = ''
    install -D -m 644 cdk.out/backups.template.json $out/backups.template.json
  '';
}
