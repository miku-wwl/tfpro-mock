# Lab 04 — State Recovery Under Exact Constraints

> Independent Terraform Professional simulation. This is not an official exam question.

## Scenario

A partial migration left a LocalStack environment in an inconsistent but recoverable condition. Some remote resources are recorded at legacy addresses, some exist without state, one state entry no longer has a remote object, and the backend configuration points to the wrong location. Recover the configuration and state **without replacing existing AWS resources**.

Target time: **45–55 minutes**. Target difficulty: **90–94/100**.

Run `scripts/setup.sh` or `scripts/setup.ps1` before starting. The setup process creates an isolated LocalStack environment, writes a runtime baseline, and prepares the damaged local state. It requires explicit confirmation because it runs Terraform apply against LocalStack.

## Authoritative implementation contract

The final implementation is assessed by configuration structure and state identity, not only by the visible LocalStack result.

| File | Required resource type | Exact block count | Required final labels or keys |
|---|---:|---:|---|
| `student/storage.tf` | `aws_s3_bucket` | 2 | `assets`, `logs` |
| `student/storage.tf` | `aws_s3_object` | 2 | `base`, `new` |
| `student/identity.tf` | `aws_iam_user` | 1 | `members` using `for_each` |
| `student/security.tf` | `aws_security_group` | 1 | `application` |
| `student/security.tf` | `aws_vpc_security_group_ingress_rule` | 1 | `application` using `for_each` |
| `student/generated.tf` | `local_file` | 3 | one block for each required generated file |

No child module is permitted. Every resource, provider, output, generated file, and backend declaration belongs to the **root module** in `student/`. A child module that produces the same infrastructure does not satisfy this lab.

Use exactly one unaliased default `aws` provider in `student/providers.tf`. It must target LocalStack in `us-east-1`. Do not put access keys or secret keys in any provider block or Terraform variable. The setup scripts use disposable `test` credentials through environment variables.

The backend type must be `s3`, declared in `student/versions.tf`, with runtime settings in `student/backend.hcl`. The final backend key is exactly:

```text
tfpro-sim/lab-04/terraform.tfstate
```

The final state must not remain local and must not use any near-match key.

## Task 1 — Repair and migrate the backend

The supplied backend settings contain a plausible but incorrect key and incorrect connection details. Repair the configuration and migrate the current local state into the existing LocalStack state bucket.

The migration must preserve every valid state record. Do not start with an empty remote state, do not create duplicate resources, and do not leave a second active local state as the final result.

## Task 2 — Adopt all required existing resources

The final state must contain these exact addresses:

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.application["admin-console"]
aws_vpc_security_group_ingress_rule.application["service-http"]
aws_s3_object.base
aws_s3_object.new
```

Derive import identities from the runtime baseline, provider documentation, remote inspection, and existing state. This README intentionally does not provide complete import IDs or complete import commands.

After adoption, align configuration with the remote resources. A successful import is not sufficient when a subsequent plan still proposes an unintended change.

## Task 3 — Migrate legacy addresses without recreation

The damaged state begins with independent IAM user addresses and a legacy bucket address. Move the existing identities into the target addresses.

The following addresses must be absent at completion:

```text
aws_s3_bucket.primary
aws_iam_user.alpha
aws_iam_user.beta
aws_iam_user.gamma
aws_s3_object.retired_marker
aws_s3_object.retained
```

An address change achieved by destroying and recreating the remote resource receives no credit. The same real resource must never remain managed by both a legacy address and a target address.

## Task 4 — Stop managing the retained object

`retained.txt` is currently managed by Terraform. Remove its resource block and state record while preserving the existing remote object.

At completion:

- the object still exists in the assets bucket;
- its body is exactly `KEEP-ME`;
- it has not been deleted and uploaded again;
- no Terraform state address manages it.

Deleting the block and accepting a remote delete is incorrect, even if a later upload restores identical content.

## Task 5 — Create the new managed object

Create `new.txt` in the assets bucket with exact body `Success`, using the required `aws_s3_object.new` block in `student/storage.tf`.

`base.txt` must retain its existing remote identity and management relationship. The final managed object set is `base.txt` and `new.txt`; `retained.txt` remains remote but unmanaged.

## Output contract

Define all outputs in `student/outputs.tf`. Values must be computed from Terraform resources and must not hardcode remote IDs or runtime names.

| Output name | Exact result type | Required content |
|---|---|---|
| `bucket_names` | `list(string)` | assets and logs bucket names, sorted |
| `iam_user_names` | `list(string)` | three user names, sorted |
| `security_group_id` | `string` | application security group ID |
| `security_group_rule_ids` | `list(string)` | two rule IDs ordered by stable rule key |
| `managed_object_keys` | `set(string)` | exactly `base.txt` and `new.txt` |

Set/list differences matter. A visually similar CLI rendering with the wrong Terraform type is incomplete.

## Generated file contract

Use exactly three separate `local_file` resource blocks in `student/generated.tf`:

- `generated/s3.txt`: two bucket names, one per line, sorted;
- `generated/iam-users.txt`: three IAM user names, one per line, sorted;
- `generated/security.txt`: security group ID followed by the two rule IDs, one value per line, with rule IDs in stable key order.

The content must be derived from resource attributes. A single `local_file` block with `for_each` may create the correct files but violates the required block count. Shell redirection or manually written files also violates the contract.

## State and safety constraints

You may use normal Terraform state and import operations. You must not edit state JSON directly.

Do not use broad `lifecycle.ignore_changes` rules to conceal drift. Do not substitute deprecated or alternative resource types. In particular, the ingress rules must use exactly one `aws_vpc_security_group_ingress_rule` block with `for_each`; multiple blocks, `count`, `aws_security_group_rule`, or index-based keys do not satisfy the task.

Before applying, inspect a saved plan. Existing AWS resources must have no delete or replace action. The only intended AWS create during recovery is `aws_s3_object.new`. The three `local_file` resources are expected local creates. After the approved apply, the final plan must report **0 to add, 0 to change, 0 to destroy**.

## Partial-credit traps

These approaches can appear functional but are explicitly noncompliant:

- keeping local state because Terraform still runs;
- destroying and recreating resources under the target names;
- deleting and re-uploading `retained.txt`;
- using one `local_file` block with `for_each`;
- using three IAM user blocks or `count` instead of the required `for_each` block;
- producing outputs by hardcoding baseline values;
- using alternate security-group rule resource types;
- suppressing differences with broad lifecycle ignores.

## Completion evidence

Collect and review:

1. final backend configuration and state location;
2. `terraform state list` with all target addresses and no legacy addresses;
3. `terraform state show` for critical resources;
4. a saved final plan showing 0/0/0;
5. LocalStack checks for retained and new object bodies;
6. output type/value inspection with `terraform output -json`;
7. generated file contents;
8. baseline identity comparison for buckets, users, security group, rules, and `base.txt`.
