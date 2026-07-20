# Lab 02 — Multiple AWS Providers and Safe State Migration

This is an independent Terraform Professional practice lab. It is not an official exam question.

## Scenario

A platform team has split operational duties across compute, identity, and audit roles. The Terraform configuration was partially refactored, but the shared AWS files, provider wiring, dependency lock file, an S3 object migration, and an Auto Scaling drift rule are incomplete.

The LocalStack environment contains the following existing objects:

- three IAM roles used by named profiles;
- one launch template and one Auto Scaling group;
- one IAM user;
- one S3 bucket;
- one S3 object at key `artifact.txt` whose content is exactly `ORIGINAL-CONTENT`.

The setup script imports the existing resources into the starter state. Do not edit `terraform.tfstate` directly.

## Target time and difficulty

- Target time: 50–60 minutes
- Target level: Terraform Authoring and Operations Professional
- Expected final result: a zero-change plan

## Prerequisites

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- Bash or PowerShell
- No real AWS credentials are required or permitted

## Setup

From the lab root:

```bash
./scripts/setup.sh
```

PowerShell:

```powershell
./scripts/setup.ps1
```

The setup process uses only LocalStack test credentials. It creates the remote objects, writes the generated bucket name to `student/lab.auto.tfvars.json`, imports the existing resources into the starter state, and saves baseline evidence under `bootstrap/baseline/`.

## Rules

- Work only under `student/`.
- Do not modify `bootstrap/` or the generated `student/lab.auto.tfvars.json`.
- Do not edit state JSON.
- Do not delete or recreate the existing S3 object.
- Do not remove the Auto Scaling group from state.
- Do not use broad lifecycle suppression to hide unrelated changes.
- Preserve the existing bucket, object key, object content, launch template, Auto Scaling group, and IAM user.

## Task 1 — Build the shared AWS files

Create these exact files:

- `student/.aws/config`
- `student/.aws/credentials`

The config file must contain exactly these three role profiles and no `default` profile:

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

Every role profile must use:

- region `us-east-1`;
- output format `json`;
- the matching role ARN shown in `bootstrap/terraform output`;
- a valid `source_profile`.

Use these LocalStack-only source credential profile names in `student/.aws/credentials`:

- `compute-seed`
- `identity-seed`
- `audit-seed`

Each source credential profile must use the literal LocalStack test values `test` / `test`. Do not add real credentials.

## Task 2 — Repair provider and module wiring

The root module must define exactly these three aliased AWS provider configurations for managed operations:

- `aws.compute`
- `aws.identity`
- `aws.readonly`

Meet all of the following requirements:

- the compute module uses `aws.compute`;
- the identity module uses `aws.identity`;
- the storage module receives an explicitly selected provider;
- `data.aws_caller_identity.current` uses `aws.readonly`;
- every module call uses an explicit `providers` map;
- each child module declares the alias it accepts through `configuration_aliases`;
- child modules must not create their own uncontrolled default AWS provider;
- shared config and credentials paths must resolve to the files created in Task 1.

The LocalStack endpoint settings must remain intact.

## Task 3 — Upgrade and lock the AWS provider

Repair the provider requirements so that the root and all child modules agree on an explicit AWS provider range compatible with the supplied solution baseline.

Requirements:

- use a bounded, intentional version constraint;
- do not use `latest`;
- do not remove provider constraints;
- update `.terraform.lock.hcl` through Terraform CLI commands;
- `terraform init -backend=false` must complete without a version-selection conflict.

## Task 4 — Migrate the existing S3 object safely

The object already exists remotely and is initially tracked at:

```text
aws_s3_bucket_object.legacy_artifact
```

The final state address must be:

```text
aws_s3_object.artifact
```

Requirements:

- remove the deprecated resource type from configuration and state;
- keep the bucket unchanged;
- keep the key `artifact.txt` unchanged;
- keep the exact content `ORIGINAL-CONTENT`;
- do not delete, replace, recreate, or overwrite the remote object;
- the final plan must not contain a create, delete, or replace action for the object.

Choose the appropriate Terraform state and import workflow. The exact command and import identifier are intentionally not provided here.

## Task 5 — Accept one controlled drift

The remote Auto Scaling group has desired capacity `1`.

Change the configuration to declare desired capacity `2`, while preserving the remote value `1` and producing no planned update for that property.

Requirements:

- ignore only `desired_capacity`;
- do not use `ignore_changes = all`;
- do not ignore unrelated attributes;
- do not remove the resource from state.

## Completion checks

Run:

```bash
./scripts/validate.sh student
terraform -chdir=student state list
terraform -chdir=student plan -out=final.tfplan
terraform -chdir=student show -no-color final.tfplan
```

A completed lab should show:

- the legacy S3 address absent;
- `aws_s3_object.artifact` present;
- all module resources still present;
- the remote object content and identity unchanged from the baseline;
- the remote Auto Scaling group desired capacity still equal to `1`;
- zero resources to add, change, or destroy.
