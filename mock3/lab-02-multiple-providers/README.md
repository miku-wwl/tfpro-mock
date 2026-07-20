# Lab 02 — Multiple Providers and Identity Boundaries

> Independent Terraform Professional practice lab. This is not an official exam question.

## Scenario

A platform team inherited a partially migrated Terraform project. The remote resources already exist in LocalStack, but the configuration has incorrect AWS shared-file paths, profile names, provider mappings, provider versions, state addresses, and lifecycle behavior.

Your goal is to repair the project without recreating the existing S3 object and without changing the live Auto Scaling Group capacity.

**Target time:** 50–60 minutes

**Target difficulty:** 90–95 / 100

**Terraform CLI:** 1.11.x

**Working directory:** `student/`

## Safety and operating rules

- Use only the LocalStack credentials shipped with this lab.
- Do not place real AWS credentials in this repository.
- Do not edit `terraform.tfstate` JSON directly.
- Inspect every plan before applying it.
- Do not accept a clean plan if the provider identity, profile, module mapping, or state address is wrong.
- Do not destroy or recreate `artifact.txt`.

## Environment setup

Bash:

```bash
./scripts/setup.sh
cd student
```

PowerShell:

```powershell
./scripts/setup.ps1
Set-Location student
```

The setup creates the LocalStack foundation, seeds the existing resources, and copies an initial Terraform state into `student/`. Baseline evidence is written under `bootstrap/baseline/`.

## Existing remote objects

The setup creates:

- three IAM roles representing compute, identity, and read-only boundaries;
- a VPC, two subnets, and a launch template;
- an Auto Scaling Group whose live `desired_capacity` is `1`;
- an IAM policy managed by the identity module;
- an S3 bucket containing `artifact.txt` with the exact content `ORIGINAL-CONTENT`;
- an initial state entry for `aws_s3_bucket_object.legacy_artifact`.

## Task 1 — Repair AWS shared configuration and credentials

Create the following files in the exact locations:

```text
student/.aws/config
student/.aws/credentials
```

The config file must contain exactly these target profiles:

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

Requirements:

- do not define a `default` profile;
- use `us-east-1` for all three profiles;
- set `output = json`;
- configure the correct `role_arn` and `source_profile` for each target profile;
- keep LocalStack source credentials in the credentials file, not in Terraform provider blocks;
- remove or stop using the misleading starter files and near-miss paths.

The expected LocalStack role names are available from the foundation outputs and baseline evidence. Follow real AWS shared config syntax even though LocalStack does not fully enforce IAM authorization boundaries.

## Task 2 — Repair provider and module identity mapping

The root module must define these three AWS provider aliases:

- `aws.compute`
- `aws.identity`
- `aws.readonly`

Requirements:

- the compute module must use only `aws.compute`;
- the identity module must use only `aws.identity`;
- the storage module must receive an explicitly mapped AWS provider;
- `data.aws_caller_identity.current` must use `aws.readonly`;
- every module call must use an explicit `providers` map;
- child modules must declare the aliases they receive with `configuration_aliases`;
- child modules must not create uncontrolled default AWS providers;
- remove the root default AWS provider rather than using it as a shortcut.

A configuration can successfully contact LocalStack and still fail this task if it uses the wrong identity boundary.

## Task 3 — Upgrade the AWS provider and repair the lock file

The starter provider constraint and dependency lock file are intentionally inconsistent.

Requirements:

- use a clear, bounded AWS provider version constraint compatible with the lab;
- do not use `latest` and do not remove all constraints;
- retain the required Terraform CLI range;
- refresh `.terraform.lock.hcl` using Terraform, not by inventing checksums;
- `terraform init` must finish without a version-selection conflict.

## Task 4 — Migrate the existing S3 object without replacement

The object already exists and is initially tracked at:

```text
aws_s3_bucket_object.legacy_artifact
```

The final address must be:

```text
aws_s3_object.artifact
```

Requirements:

- remove the deprecated resource type from code and state;
- preserve the bucket and key;
- preserve the exact object content `ORIGINAL-CONTENT`;
- do not delete, recreate, replace, or overwrite the object;
- use Terraform state/import mechanisms rather than editing state JSON;
- confirm the object hash or ETag against `bootstrap/baseline/`;
- the final plan must contain no create, update, delete, or replace action.

The correct migration command, import identifier, and complete answer are intentionally not provided here.

## Task 5 — Handle desired-capacity drift precisely

The compute module configuration must declare:

```hcl
desired_capacity = 2
```

The live Auto Scaling Group must remain at `1`.

Requirements:

- ignore only `desired_capacity`;
- do not use `ignore_changes = all`;
- do not ignore the whole resource;
- do not remove the resource from state;
- do not change `min_size` or `max_size` to hide the issue;
- confirm that the final plan does not update the remote capacity.

## Completion evidence

Before declaring the lab complete, collect and review:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform state list
terraform state show aws_s3_object.artifact
terraform plan -out=final.tfplan
terraform show -no-color final.tfplan
```

Also verify:

- only the three required target profiles exist in `.aws/config`;
- source profiles and role ARNs are correct;
- all three provider aliases exist;
- module provider mappings and `configuration_aliases` are exact;
- the old S3 state address is absent;
- the new S3 state address is present;
- the object content identity matches the baseline;
- the Auto Scaling Group remains at capacity `1`;
- the final plan is 0 add / 0 change / 0 destroy.

See `VALIDATION.md` in the solution package for the full review checklist.
