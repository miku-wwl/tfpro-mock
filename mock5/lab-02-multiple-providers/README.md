# Lab 02 — Multiple Providers, Profiles, and Zero-Recreation Migration

> Independent Terraform Professional practice material. This is not an official HashiCorp exam question.

## Scenario

A platform team split AWS operations among compute, identity, and audit personas. The current project can appear functional while silently using the wrong credentials, implicit providers, an outdated dependency selection, and a destructive S3 object migration. Repair it without changing the existing remote objects.

**Target time:** 50–60 minutes  
**Target difficulty:** 90–95/100  
**Terraform CLI:** 1.11.x  
**Environment:** Docker Desktop, Docker Compose, LocalStack, Bash or PowerShell

LocalStack verifies file loading, aliases, module provider mapping, state addresses, S3 object preservation, lifecycle behavior, and plan output. It does **not** prove real AWS IAM authorization boundaries; those limitations are documented in the solution review.

## Start and reset

From the lab root:

```bash
./scripts/setup.sh
```

or:

```powershell
./scripts/setup.ps1
```

The setup creates the foundation and seeds the exam state. Work only in `student/`. Use the matching reset script to discard your changes and rebuild the starter environment.

Do not place real AWS credentials anywhere in this project. Values named `test` are LocalStack-only credentials.

## State and backend contract

The candidate root module is `student/`. Its only backend is the root-level `backend "s3"` block in `student/versions.tf`.

- Backend bucket: `tfpro-lab02-state`
- Backend key: `set-05/lab-02/terraform.tfstate`
- Region: `us-east-1`
- LocalStack S3 endpoint: `http://localhost:4566`

Do not add a backend block to any child module, do not retain a local state as the final state, and do not change the backend key.

## Task 1 — Repair the shared AWS files

Create exactly these files:

- `student/.aws/config`
- `student/.aws/credentials`

`student/.aws/config` must contain exactly three role profiles and no `[default]` section:

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

Each role profile must use `region = us-east-1`, `output = json`, the matching LocalStack role ARN, and `source_profile = localstack-seed`. The role names are discoverable from the bootstrap outputs and are also listed in `bootstrap/foundation/outputs.tf`.

`student/.aws/credentials` must contain exactly one source profile named `localstack-seed` with LocalStack-only static values. Do not add access keys to any Terraform provider block. A solution that falls back to environment/default credentials may run but does not satisfy this task.

Remove the misleading profile files after the correct files exist. The final provider configuration must reference the two exact paths above.

## Task 2 — Enforce provider identity and module boundaries

The root module must contain exactly three `provider "aws"` blocks in `student/providers.tf`. All three must be aliased; a final unaliased/default AWS provider is not allowed.

| Root provider | Required profile | Authorized use |
|---|---|---|
| `aws.compute` | `compute-operator` | Compute module, storage module, and the root S3 object |
| `aws.identity` | `identity-operator` | Identity module only |
| `aws.readonly` | `readonly-auditor` | `data.aws_caller_identity.current` only |

The root module must pass providers explicitly with each module block's `providers` map. Every child module must declare its required aliased provider through `configuration_aliases`; child modules must not create their own provider configuration.

Keep this final **Resource Type**, file-location, module-boundary, and resource-block-count contract:

- `student/modules/compute/main.tf`: exactly one `aws_launch_template` block and exactly one `aws_autoscaling_group` block.
- `student/modules/identity/main.tf`: exactly one `aws_iam_user` block.
- `student/modules/storage/main.tf`: exactly one `aws_s3_bucket` block.
- `student/main.tf`: exactly three module blocks, exactly one `aws_caller_identity` data block, and exactly one final S3 object resource block.

Do not merge modules even if a two-module design can produce the same infrastructure.

## Task 3 — Upgrade and lock the AWS provider

Set an explicit compatible AWS provider constraint that selects the `5.100.x` release line. Do not use `latest`, an unconstrained provider, or a `6.x` release.

Update `.terraform.lock.hcl` so it agrees with the final constraint. `terraform init -upgrade` must complete without a version-selection conflict. The final root and every child module must use `hashicorp/aws` as the provider source.

## Task 4 — Preserve and migrate `artifact.txt`

The existing object has these fixed properties:

- Bucket: `tfpro-lab02-artifacts`
- Key: `artifact.txt`
- Content: `ORIGINAL-CONTENT`
- Initial state address: `aws_s3_bucket_object.legacy_artifact`
- Final state address: `aws_s3_object.artifact`

The final code must contain exactly one `aws_s3_object` resource block named `artifact` in `student/main.tf`. No `aws_s3_bucket_object` block may remain anywhere under `student/`.

Preserve the remote bucket, object key, content, and object identity. The migration must not issue a remote delete, replacement, or re-upload. Directly changing only the resource type is not sufficient because it produces a create/delete plan. Do not edit the state JSON directly.

The README intentionally does not provide the migration command or import identifier. Determine the safe state operation, then prove preservation using the generated baseline files in `bootstrap/baseline/`.

## Task 5 — Accept desired-capacity drift precisely

The final configuration in `student/modules/compute/main.tf` must declare `desired_capacity = 2`, while the existing remote autoscaling group remains at `1`.

Use a lifecycle rule on the `aws_autoscaling_group` resource that ignores only `desired_capacity`. `ignore_changes = all`, ignoring an unrelated block, removing the resource from state, or changing the configured value back to `1` does not satisfy this task.

## Required root outputs

Define exactly these root outputs in `student/outputs.tf`; each must evaluate to a Terraform `string` and must be derived from resources, module outputs, or the read-only data source rather than hard-coded text:

- `compute_group_name`
- `identity_user_arn`
- `artifact_object_key`
- `readonly_account_id`

A correct-looking hard-coded output receives no credit.

## Completion standard

After the migration and configuration repairs:

1. `terraform fmt -check -recursive` passes.
2. `terraform init -upgrade` succeeds using the stated backend key.
3. `terraform validate` succeeds.
4. `terraform state list` contains `aws_s3_object.artifact` and does not contain `aws_s3_bucket_object.legacy_artifact`.
5. The saved plan reports **0 to add, 0 to change, 0 to destroy**.
6. The baseline and final S3 key, content hash, and ETag/identity field match.
7. The remote desired capacity remains `1`, while configuration declares `2`.

Use `scripts/validate.sh` or `scripts/validate.ps1` for non-scoring structural checks. It does not grade the implementation.

## Partial-credit traps

Terraform running successfully is not enough. These implementations are intentionally non-compliant even when the resource result looks correct:

- using default/environment credentials instead of the named profiles;
- embedding test or real access keys in provider blocks;
- relying on implicit provider inheritance instead of explicit module maps;
- replacing the old S3 object rather than remapping its state;
- using a broad lifecycle ignore rule;
- keeping a local backend or changing the required key;
- using alternative resource types or hard-coded outputs.
