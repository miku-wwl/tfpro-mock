# Lab 02 — Multiple Providers and State-Safe Migration

> Independent Terraform Professional practice lab. This is not an official exam question.

## Scenario

A platform team inherited a LocalStack-backed AWS configuration after a partial provider upgrade. The remote objects already exist, but the Terraform configuration, provider aliases, dependency lock file, module wiring, and state addresses no longer agree.

Your objective is to repair the project without destroying, replacing, recreating, or overwriting any pre-provisioned object. The completed main and audit configurations must both produce clean plans.

**Target time:** 50–60 minutes  
**Target difficulty:** 90–95/100

## Safety rules

- Work only inside `student/`.
- Do not edit Terraform state JSON directly.
- Do not run against a real AWS account. The supplied files use LocalStack-only test credentials.
- Inspect every plan before applying it.
- No pre-provisioned resource may be destroyed or replaced.
- Preserve `artifact.txt` with the same bucket, key, bytes, hash, and remote identity.
- The final main state and audit state must not manage the same remote object.

## Start and reset

From the lab root:

```bash
./scripts/setup.sh
```

Windows PowerShell:

```powershell
./scripts/setup.ps1
```

The setup creates a disposable LocalStack environment, provisions the legacy topology, writes the initial state into `student/`, and records evidence under `student/.baseline/`.

To restore the original exercise:

```bash
./scripts/reset.sh
```

## Task 1 — Repair shared AWS files

Create the following files:

- `student/.aws/config`
- `student/.aws/credentials`

The config file must contain exactly these three role profiles:

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

Requirements:

- Every role profile uses `us-east-1` and JSON output.
- Every role profile contains an appropriate `role_arn` and `source_profile`.
- No `default` profile is allowed in the config file.
- The credentials file may contain one LocalStack-only source profile for the three role profiles.
- Do not add real credentials.

## Task 2 — Repair provider aliases and module wiring

The root module must expose exactly these AWS aliases:

- `aws.compute`
- `aws.identity`
- `aws.readonly`

Required behavior:

- The compute module uses `aws.compute`.
- The identity module uses `aws.identity`.
- The storage module and its nested catalog module receive an explicitly mapped provider.
- `data.aws_caller_identity.current` uses `aws.readonly`.
- Every child module declares the aliases it accepts.
- No child module may silently create an uncontrolled default AWS provider.
- Existing state entries that still refer to the legacy provider configuration must be reconciled with the repaired provider layout.

## Task 3 — Upgrade the AWS provider safely

Repair all provider requirements so that the root and child modules accept one explicit, compatible AWS provider release in the `5.82.x` line.

Requirements:

- Do not use `latest`.
- Do not remove all version constraints.
- Regenerate the dependency lock information using normal Terraform commands.
- Confirm the selected provider is compatible with the existing state before changing any remote object.

## Task 4 — Migrate the existing S3 object

The remote object already exists at key `artifact.txt` and currently contains exactly:

```text
ORIGINAL-CONTENT
```

Its legacy state address is:

```text
aws_s3_bucket_object.legacy_artifact
```

Its required final address is:

```text
aws_s3_object.artifact
```

Requirements:

- The deprecated resource type disappears from configuration and state.
- The legacy and replacement addresses never remain simultaneously managed at completion.
- Bucket and key stay unchanged.
- Object bytes, hash, ETag or equivalent identity evidence stay unchanged.
- The object is not deleted, recreated, replaced, or overwritten.
- The final plan contains no create, update, delete, or replace action.

## Task 5 — Preserve desired capacity drift

The pre-provisioned Auto Scaling Group has a remote `desired_capacity` of `1`. The repaired configuration must declare `2`, while the remote value remains `1`.

Requirements:

- Ignore only `desired_capacity`.
- Do not ignore the whole resource or unrelated attributes.
- Do not remove the Auto Scaling Group from state.
- The final plan must not update its remote desired capacity.

## Task 6 — Complete the address refactor without churn

Reconcile the legacy state with the target module structure.

Target mappings:

| Legacy address | Required final address |
|---|---|
| `aws_launch_template.capacity_template` | `module.compute.aws_launch_template.capacity_template` |
| `aws_autoscaling_group.capacity_group` | `module.compute.aws_autoscaling_group.capacity_group` |
| `aws_iam_user.pipeline_identity` | `module.identity.aws_iam_user.pipeline_identity` |
| `aws_iam_user.service_accounts[0]` | `module.identity.aws_iam_user.service_accounts["api-gateway"]` |
| `aws_iam_user.service_accounts[1]` | `module.identity.aws_iam_user.service_accounts["batch-worker-prod"]` |
| `aws_s3_object.catalog_manifest` | `module.storage.module.catalog.aws_s3_object.manifest` |

Additional requirements:

- The two service accounts must use stable `for_each` keys independent of input order.
- The final service-account output must be a map keyed by those stable keys, not a positional list.
- `aws_s3_bucket.audit_archive` must be transferred into the separate configuration under `student/audit-state/`.
- The main state and audit state must not both manage the audit bucket.
- No mapping may cause address churn, replacement, or remote recreation.

## Completion evidence

Before declaring completion, record or inspect:

1. `terraform state list` for both states.
2. Provider requirements and selected lock-file version.
3. A saved final plan for the main state.
4. A saved final plan for the audit state.
5. Object body, hash, and ETag or equivalent identity before and after migration.
6. Auto Scaling Group desired capacity before and after migration.
7. Confirmation that both final plans are `0 to add, 0 to change, 0 to destroy`.

Use `scripts/validate.sh` or `scripts/validate.ps1` for non-grading structural validation after your changes.
