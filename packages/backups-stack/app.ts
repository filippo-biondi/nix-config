// The AWS side of the backups (modules/nixos/backup): the bucket the hosts upload
// to, the key they upload with, and a budget alert. nix build synthesizes it to a
// CloudFormation template, deployed by hand
import {App, BootstraplessSynthesizer, CfnParameter, Duration, RemovalPolicy, Stack} from "aws-cdk-lib";
import * as budgets from "aws-cdk-lib/aws-budgets";
import * as iam from "aws-cdk-lib/aws-iam";
import * as s3 from "aws-cdk-lib/aws-s3";

const app = new App({outdir: process.env.CDK_OUTDIR, analyticsReporting: false});
// No assets, so no cdk bootstrap: the template deploys with aws cloudformation deploy
const stack = new Stack(app, "backups", {synthesizer: new BootstraplessSynthesizer()});

const email = new CfnParameter(stack, "AlertEmail", {description: "Who gets the budget alert"});

// Private, versioned, and every object locked for 180 days, which Deep Archive
// bills anyway: no one can overwrite or delete a backup before then. GOVERNANCE
// rather than COMPLIANCE, so that an admin can still remove one by hand
const bucket = new s3.Bucket(stack, "Bucket", {
  bucketName: process.env.BUCKET,
  blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
  enforceSSL: true,
  versioned: true,
  objectLockEnabled: true,
  objectLockDefaultRetention: s3.ObjectLockRetention.governance(Duration.days(180)),
  // Backups expire after 180 days and are gone a day later; uploads that never
  // finished don't linger, since their parts are billed. The hosts upload to Deep
  // Archive: anything uploaded to another storage class is moved there
  lifecycleRules: [{
    transitions: [{storageClass: s3.StorageClass.DEEP_ARCHIVE, transitionAfter: Duration.days(0)}],
    expiration: Duration.days(180),
    noncurrentVersionExpiration: Duration.days(1),
    abortIncompleteMultipartUploadAfter: Duration.days(7),
  }],
  // Deleting the stack must never delete the backups
  removalPolicy: RemovalPolicy.RETAIN,
});

// The hosts' key may only upload: not read, list, overwrite or delete. The key
// itself is made after deploying, so that its secret is never in the stack
const writer = new iam.User(stack, "Writer", {userName: "backup-writer"});
writer.addToPolicy(new iam.PolicyStatement({
  actions: ["s3:PutObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"],
  resources: [bucket.arnForObjects("*")],
}));

// An email once the account's costs pass $4 in a month; the backups cost well under $1
new budgets.CfnBudget(stack, "Budget", {
  budget: {budgetName: "backups", budgetType: "COST", timeUnit: "MONTHLY", budgetLimit: {amount: 5, unit: "USD"}},
  notificationsWithSubscribers: [{
    notification: {notificationType: "ACTUAL", comparisonOperator: "GREATER_THAN", threshold: 80},
    subscribers: [{subscriptionType: "EMAIL", address: email.valueAsString}],
  }],
});

app.synth();
