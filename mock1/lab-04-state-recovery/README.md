# Lab 04 — State Recovery and Backend Migration

> Independent Terraform Professional practice lab. This is not an official HashiCorp exam question.

## Scenario

A previous migration stopped halfway through. The infrastructure still exists in LocalStack, but the Terraform configuration, local state, and backend settings no longer agree.

Your job is to recover management of the existing resources without rebuilding them, move the state to the required S3 backend, stop managing one retained object without deleting it, and add one new managed object.

**Target time:** 45–55 minutes  
**Target difficulty:** Terraform Professional 90–94/100

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or PowerShell

No real AWS credentials are required. The scripts use only the disposable credentials `test` / `test` against `http://localhost:4566`.

## Start the lab

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

The setup creates the remote resources, records a baseline under `bootstrap/baseline/`, and prepares a deliberately inconsistent local state in `student/terraform.tfstate`.

## Initial damaged condition

After setup, expect all of the following:

- The active state is local, while an S3 backend configuration file exists with a near-miss key and incorrect connection settings.
- The assets bucket is recorded at `aws_s3_bucket.primary`, but the target configuration uses `aws_s3_bucket.assets`.
- The three IAM users are recorded at `aws_iam_user.alpha`, `aws_iam_user.beta`, and `aws_iam_user.gamma`.
- The target IAM resource uses `for_each`, and one map key is misspelled.
- The logs bucket and application security group exist remotely but are absent from state.
- One ingress rule is recorded at a legacy address; the other ingress rule is absent from state.
- `base.txt` and `retained.txt` are both managed in the starting state.
- A stale IAM address remains in state even though its remote user no longer exists.
- The starter configuration contains provider, tag, and physical-name drift.

Use `terraform state list`, `terraform state show`, the baseline files, and normal Terraform plans to understand the environment. Do not edit state JSON.

## Task 1 — Repair and migrate the backend

Configure and use the S3 backend created by setup.

The final backend key must be exactly:

```text
tfpro-sim/lab-04/terraform.tfstate
```

Requirements:

- Migrate the existing local state; do not start with an empty remote state.
- Preserve every valid state record during migration.
- Correct the backend region and LocalStack S3 endpoint.
- Do not keep using the near-miss backend key.
- The completed lab must no longer use local state.

## Task 2 — Adopt the existing resources

The final state must contain these exact addresses:

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_security_group_rule.inbound["api"]
aws_security_group_rule.inbound["ops"]
aws_s3_object.base
```

Use the baseline data and remote inspection to determine import identifiers. The README intentionally does not provide complete import commands or complete import identifiers.

After adopting resources, align the configuration with the remote objects. Do not use broad `ignore_changes` rules to hide drift.

## Task 3 — Migrate and clean state addresses

Complete the address migration without destroying and recreating infrastructure.

Final requirements:

- `aws_s3_bucket.primary` is absent.
- `aws_iam_user.alpha`, `aws_iam_user.beta`, and `aws_iam_user.gamma` are absent.
- The legacy ingress-rule address is absent.
- The stale IAM address is absent.
- A real remote resource is never managed by two addresses at the same time.
- The IAM `for_each` keys are exactly `alpha`, `beta`, and `gamma`.

A plan that proposes delete/create or replacement actions for the existing buckets, users, security group, or ingress rules is not acceptable.

## Task 4 — Stop managing `retained.txt` without deleting it

Remove `retained.txt` from Terraform management while preserving the remote object.

Final requirements:

- Its resource block is absent from configuration.
- Its state address is absent.
- The remote key `retained.txt` still exists in the assets bucket.
- Its content remains exactly `KEEP-ME`.
- It is not deleted and recreated during the exercise.

## Task 5 — Add the new object and finish the outputs

Create a managed S3 object:

```text
key     = new.txt
content = Success
```

Create these Terraform outputs:

- `bucket_names`
- `iam_user_names`
- `security_group_id`
- `security_group_rule_ids`
- `managed_object_keys`

Generate these files dynamically from Terraform values:

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

Required file content:

- `s3.txt`: the two managed bucket names.
- `iam-users.txt`: the three IAM user names.
- `security.txt`: the security group ID followed by both ingress-rule IDs.

Use deterministic ordering. Do not hardcode remote IDs.

## Final acceptance criteria

Before considering the lab complete:

1. `terraform fmt -check -recursive` passes.
2. `terraform validate` passes.
3. `terraform state list` contains all required target addresses and none of the legacy addresses.
4. The backend uses the exact required key.
5. The original bucket names, IAM user names, security group ID, and rule identities match the baseline.
6. `retained.txt` still exists with `KEEP-ME` and is absent from state.
7. `new.txt` exists with `Success` and is present in state.
8. The generated files contain dynamically derived values in stable order.
9. The final plan reports **0 to add, 0 to change, 0 to destroy**.

## Prohibited shortcuts

- Do not directly edit `terraform.tfstate` or backend state JSON.
- Do not delete and recreate existing resources to fix addresses.
- Do not import the same remote object into multiple active addresses.
- Do not use broad lifecycle ignores to conceal configuration drift.
- Do not place real AWS credentials in any file.
- Do not run destructive commands without first reviewing a saved plan.

## Reset

Bash:

```bash
./scripts/reset.sh
```

PowerShell:

```powershell
./scripts/reset.ps1
```
