# Lab 04 — State Recovery and Address Preservation

> Independent Terraform Professional-style practice lab. This is not an official exam question.

## Objective

Recover a deliberately inconsistent Terraform workspace without deleting or replacing any pre-existing cloud resource. The exercise is designed for **45–55 minutes** and assumes Terraform CLI 1.11.x, Docker Desktop, Docker Compose, LocalStack, Bash or PowerShell.

The environment contains resources that are distributed across configuration, Terraform state, and LocalStack in different ways. Treat the saved baseline as the source of truth for resource identity.

## Safety rules

- Never edit a `terraform.tfstate` file as JSON.
- Do not delete, replace, or recreate any pre-existing bucket, IAM user, security group, security-group rule, or object.
- Do not use broad `ignore_changes` rules to hide drift.
- Before any apply, inspect a saved plan and confirm that no pre-existing resource has a delete or replace action.
- The final plans for both workspaces must be clean.

## Start the lab

Bash:

```bash
./scripts/setup.sh
./scripts/corrupt-state.sh
```

PowerShell:

```powershell
./scripts/setup.ps1
./scripts/corrupt-state.ps1
```

The setup creates an isolated LocalStack environment, saves identity data under `bootstrap/baseline/`, and prepares a damaged local state in `student/`.

## Required final backend

The primary workspace must use the pre-created S3 backend bucket and this exact key:

```text
tfpro-sim/lab-04/terraform.tfstate
```

The auxiliary workspace under `student/auxiliary/` must use the same backend bucket and this exact key:

```text
tfpro-sim/lab-04/auxiliary.tfstate
```

Both backend migrations must preserve the existing lineage, serial progression, and resource-to-address mapping. The final primary workspace must not continue using local state.

## Task 1 — Repair provider and backend configuration

Repair the LocalStack provider settings and both backend configurations. Migrate the current local state records rather than creating a fresh empty remote state.

Confirm before and after migration that:

- the same real resources remain mapped;
- the backend key is exact;
- the state lineage is preserved;
- backend migration itself does not create duplicate resources.

## Task 2 — Adopt existing resources

Reconcile the configuration and state so the primary state contains all of these exact addresses:

```text
aws_s3_bucket.assets
aws_s3_bucket.logs
aws_iam_user.members["alpha"]
aws_iam_user.members["beta"]
aws_iam_user.members["gamma"]
aws_security_group.application
aws_vpc_security_group_ingress_rule.application["https-public"]
aws_vpc_security_group_ingress_rule.application["ops-vpn"]
```

The logs bucket, security group, and one ingress rule already exist in LocalStack. Derive their identifiers from the baseline and remote APIs. Do not create replacements.

## Task 3 — Recover resource addresses without churn

The damaged state includes legacy ordinary addresses, count addresses, and addresses that no longer have matching configuration. Reach the final model without deleting and recreating the real resources.

Required outcomes:

- the three independent IAM user addresses disappear;
- IAM users are represented by the required `for_each` addresses;
- the assets bucket legacy address disappears;
- two count-indexed seed objects are represented by stable string-keyed `for_each` addresses;
- the base object is managed inside `module.content`;
- no real resource is simultaneously managed by two addresses;
- every stale address is resolved safely.

The final seed object addresses must be:

```text
aws_s3_object.seeded["warm-up"]
aws_s3_object.seeded["cold-path"]
```

Input ordering must not affect these addresses.

## Task 4 — Split one resource into a second state

The existing manifest object begins in the primary local state at a root resource address. It must end in the auxiliary state at this multi-level module address:

```text
module.operations.module.inventory.aws_s3_object.manifest
```

The object must remain the same remote object throughout the split. It must not remain in the primary state and must not be imported or managed twice.

The base object must end at this one-level module address in the primary state:

```text
module.content.aws_s3_object.base
```

## Task 5 — Stop managing retained.txt without deleting it

At completion:

- the configuration block for `retained.txt` is absent;
- its state address is absent;
- the remote object still exists;
- its content is still exactly `KEEP-ME`;
- it was not deleted or recreated.

Simply deleting the block before reconciling state is unsafe.

## Task 6 — Create one new managed object

Create `new.txt` in the assets bucket with exact content:

```text
Success
```

`new.txt` must be managed in the primary state. Existing `base.txt`, seed objects, the manifest object, and `retained.txt` must preserve their remote identities and content.

## Task 7 — Outputs and generated files

Create these outputs:

```text
bucket_names
iam_user_names
security_group_id
security_group_rule_ids
managed_object_keys
```

Generate the following files from Terraform-managed values, not hard-coded resource IDs:

```text
generated/s3.txt
generated/iam-users.txt
generated/security.txt
```

Expected content:

- `s3.txt`: both managed bucket names;
- `iam-users.txt`: all three IAM user names;
- `security.txt`: the security group ID and both rule IDs.

Normalize ordering so repeated plans do not oscillate.

## Completion conditions

- Both backend keys are exact.
- All required final addresses exist in their correct state.
- All legacy, stale, and duplicate addresses are gone.
- No pre-existing resource ID changed.
- `retained.txt` remains remote and unmanaged.
- `new.txt` exists and is managed.
- Generated files are dynamic and stable.
- `terraform plan` reports `0 to add, 0 to change, 0 to destroy` in both primary and auxiliary workspaces.

Use `VALIDATION.md` from the Solution package only after completing the lab or when performing a formal review.
