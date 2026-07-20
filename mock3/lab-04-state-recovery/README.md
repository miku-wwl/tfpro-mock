# Lab 04 — State Recovery and Zero-Recreation Migration

> Independent Terraform Professional-style practice lab. This is not an official exam question.

## Scenario

A partially managed LocalStack environment has been handed to you after an interrupted state migration. Some resources are recorded under legacy addresses, some exist remotely but are not in state, one object must be released from Terraform management without deletion, and the S3 backend is misconfigured.

Your goal is to recover ownership safely, preserve every existing remote identity, create one new object, and finish with a **0 to add, 0 to change, 0 to destroy** plan.

- Target time: **45–55 minutes**
- Target difficulty: **Terraform Professional 90–94/100**
- Runtime: Terraform CLI 1.11.x, Docker Desktop, Docker Compose, LocalStack

## Safety rules

- Do not edit `terraform.tfstate` JSON directly.
- Do not use broad `ignore_changes` rules to hide drift.
- Do not destroy or recreate existing buckets, users, the security group, rules, or existing objects.
- Before any apply, inspect a saved plan and confirm that only the explicitly required new resources are created.
- The LocalStack credentials in this lab are test-only values, not real cloud credentials.

## Start the lab

### Bash

```bash
./scripts/setup.sh
./scripts/corrupt-state.sh
cd student
```

### PowerShell

```powershell
./scripts/setup.ps1
./scripts/corrupt-state.ps1
Set-Location student
```

The scripts create randomized LocalStack resources, save a baseline under `bootstrap/baseline/`, and prepare a deliberately broken local state in `student/`.

---

## Task 1 — Repair and migrate the backend

The starter backend uses the correct bucket name after setup, but other backend settings are intentionally wrong.

Final requirements:

- Backend type: S3
- Backend key: `tfpro-sim/lab-04/terraform.tfstate`
- Region: `us-east-1`
- LocalStack S3 endpoint: `http://localhost:4566`
- Existing local state must be migrated, not discarded.
- No duplicate resource records may be introduced.
- The final workflow must no longer use local state.
- Regenerate and retain a valid `.terraform.lock.hcl` for the declared provider versions.

Do not confuse S3 backend settings with the aliased AWS provider configurations used by managed resources.

## Task 2 — Adopt existing resources

Recover the existing LocalStack resources into the following exact final addresses:

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.rules["http"]
aws_vpc_security_group_ingress_rule.rules["admin"]
```

Use the baseline files and read-only AWS queries to discover remote identifiers. The README intentionally does not provide complete import IDs.

Provider ownership must be exact:

- S3 buckets and objects: `aws.storage`
- IAM users: `aws.identity`
- Security group and ingress rules: `aws.network`
- Read-only identity data source: `aws.readonly`

A resource that imports successfully under the wrong provider identity does not satisfy the task.

## Task 3 — Migrate legacy addresses

The starting state includes legacy addresses and one stale state-only record.

Final requirements:

- `aws_s3_bucket.primary` is absent.
- `aws_iam_user.alpha`, `aws_iam_user.beta`, and `aws_iam_user.gamma` are absent.
- `aws_vpc_security_group_ingress_rule.legacy_http` is absent.
- `terraform_data.stale_record` is absent.
- The same remote resource is not managed by two addresses.
- Address changes must not be achieved through destroy/create actions.
- Correct the IAM `for_each` key so the final key is exactly `"alpha"`, not a visually similar variant.

## Task 4 — Release `retained.txt` without deleting it

The object currently exists in both configuration and state.

Final requirements:

- Its resource block is removed from configuration.
- Its state address is removed.
- The remote object still exists.
- Its content remains exactly `KEEP-ME`.
- It is not deleted, replaced, or re-imported under a different address.

Deleting the block before safely changing state ownership will produce a destructive plan.

## Task 5 — Create one new managed object

Create an S3 object with:

- Key: `new.txt`
- Content: `Success`

Final requirements:

- `new.txt` exists remotely and in state.
- `base.txt` remains managed at its existing address.
- `retained.txt` is not managed.
- Only the required new object and generated local files may be created.

## Task 6 — Outputs and generated files

Create these outputs as deterministic, sorted lists where applicable:

```text
bucket_names
mail_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

> The required output name is `iam_user_names`, not `mail_user_names`. The near-match above is intentional; use the exact name below.

Exact required outputs:

```text
bucket_names
iam_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

Generate these files dynamically from Terraform resource attributes:

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

File requirements:

- `s3.txt`: both bucket names
- `iam-users.txt`: all three IAM user names
- `security.txt`: the security group ID and both rule IDs
- No hard-coded cloud IDs

## Completion criteria

Before declaring completion:

1. Run formatting and validation checks.
2. Inspect every final state address.
3. Compare bucket names, user names, security group ID, rule IDs, and object hashes with `bootstrap/baseline/`.
4. Confirm provider alias ownership.
5. Confirm `retained.txt` still exists with unchanged content.
6. Confirm `new.txt` contains `Success`.
7. Save a final plan.
8. Confirm the final plan reports **0 to add, 0 to change, 0 to destroy**.
