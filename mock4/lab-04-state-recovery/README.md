# Lab 04 — State Recovery and Stable Data Normalization

> Independent Terraform Professional practice simulation. This is not an official exam item.

**Target time:** 45–55 minutes  
**Target difficulty:** 90–94 / 100  
**Environment:** Terraform CLI 1.11.x, Docker Desktop, Docker Compose, LocalStack, AWS CLI, Bash or PowerShell

## Scenario

A partially managed LocalStack environment was handed to you after an interrupted migration. Some resources are recorded under legacy state addresses, some exist remotely but are absent from state, one state address is orphaned, the S3 backend configuration is wrong, and the configuration disagrees with the remote objects.

The recovery inventory is split across CSV, JSON, and YAML. Their raw value types intentionally differ. You must normalize them into one stable model before using them for `for_each` and import decisions.

Do not recreate existing infrastructure. Do not directly edit state JSON.

## Start

From the lab root:

```bash
./scripts/setup.sh
```

PowerShell:

```powershell
./scripts/setup.ps1
```

The setup creates LocalStack resources, saves `baseline/baseline.json`, and prepares a damaged local state in `student/`.

## Starting conditions

Expect all of the following:

- The local state contains only part of the real environment.
- The backend key, region, and S3 endpoint are wrong.
- The assets bucket is recorded as `aws_s3_bucket.primary`.
- IAM users are recorded as `aws_iam_user.alpha`, `aws_iam_user.beta`, and `aws_iam_user.gamma`.
- The logs bucket and application security group exist remotely but are not in state. One ingress rule is recorded under a legacy address; the other is remote-only.
- `aws_s3_object.retained` is managed and must be released without deleting the remote object.
- `aws_s3_object.retired_probe` is an orphaned state address.
- The target assets bucket configuration would replace the existing bucket if applied unchanged.
- Tags and provider settings do not match the baseline.
- The recovery inventory contains duplicate logical records and mixed raw types.

## Task 1 — Repair and migrate the backend

The final backend must be S3 and must use this exact key:

```text
tfpro-sim/lab-04/terraform.tfstate
```

Requirements:

- Use the backend bucket recorded in `student/baseline/backend.hcl`.
- Correct the region and LocalStack S3 endpoint.
- Migrate the current local state without losing records.
- Do not create duplicate resources.
- Do not continue using local state after migration.

## Task 2 — Normalize the recovery inventory

Read all three files under `student/data/`:

- `recovery.csv`
- `recovery.json`
- `recovery.yaml`

Normalize every enabled record to one object shape with these semantic fields:

- `kind`
- `address_key`
- nullable `remote_suffix`
- boolean `enabled`
- number `priority`
- boolean `keep_remote`
- `description`
- source format

Rules:

- CSV empty strings and JSON/YAML `null` must normalize consistently.
- A real `null` must not be silently changed to an empty string in the canonical object.
- Resolve duplicate logical identities deterministically. Higher priority wins; ties must also be deterministic.
- Do not use input row numbers as permanent keys.
- Input order changes must not alter resource addresses.
- Use appropriate collection functions such as `flatten`, `merge`, `distinct`/`toset`, `lookup`, or equivalent.

### Expression traps

A direct object comprehension keyed only by `kind:address_key` will hit a **duplicate object key** error because the inputs contain duplicate logical records.

A conditional such as “enabled record returns an object, disabled record returns a list” will hit a **conditional branches type mismatch**. Keep both branches type-compatible or filter with the `if` clause of a comprehension.

## Task 3 — Adopt existing resources

The final state must contain:

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.inbound["ops-tcp-8443"]
aws_vpc_security_group_ingress_rule.inbound["audit-tcp-9443"]
```

Requirements:

- Drive the ingress-rule import targets from a normalized map.
- Correctly distinguish a Terraform resource address from a remote import ID.
- Quote `for_each` string keys correctly in state commands.
- After import, continue repairing configuration until the plan no longer proposes changes to adopted resources.
- Do not reveal or guess IDs; use `baseline/baseline.json` and state inspection.

## Task 4 — Migrate legacy addresses

Final requirements:

- `aws_s3_bucket.primary` is absent.
- `aws_iam_user.alpha`, `aws_iam_user.beta`, and `aws_iam_user.gamma` are absent.
- `aws_s3_object.retired_probe` is absent.
- `aws_vpc_security_group_ingress_rule.legacy_ops` is absent.
- No real resource is managed by two addresses.
- Address migration must not use destroy/create replacement.

## Task 5 — Release `retained.txt`

Final requirements:

- The `retained.txt` resource block is absent from configuration.
- Its state address is absent.
- The remote object still exists.
- Its content remains exactly `KEEP-ME`.
- It is not deleted or recreated.

Removing only the resource block is unsafe because Terraform would plan deletion while the state entry remains.

## Task 6 — Create `new.txt`

Create a managed S3 object:

- key: `new.txt`
- content: `Success`

Keep `base.txt` managed and unchanged.

## Task 7 — Outputs and generated files

Create these outputs:

- `bucket_names`
- `iam_user_names`
- `security_group_id`
- `security_group_rule_ids`
- `managed_object_keys`

Create these files dynamically with Terraform:

- `generated/s3.txt` — both bucket names
- `generated/iam-users.txt` — all three IAM user names
- `generated/security.txt` — security group ID and both rule IDs

Requirements:

- Do not hardcode resource IDs.
- Generated line order must be stable.
- Set/list iteration order must not leak into file content.

## Task 8 — Final proof

Produce and inspect a saved plan.

The final result must be:

```text
0 to add, 0 to change, 0 to destroy
```

Then run the supplied shuffle test from the solution workflow or implement the equivalent test. Reordering CSV, JSON, and YAML inputs must not cause delete/create actions or resource-address churn.

## Prohibited shortcuts

- Direct edits to `terraform.tfstate` or remote state JSON
- Recreating existing buckets, users, security groups, or rules
- Broad `ignore_changes`
- Row-index-based `for_each` keys
- Hardcoded LocalStack-generated IDs
- Importing `retained.txt` again after releasing it
- Applying a plan that contains unexpected delete or replace actions
