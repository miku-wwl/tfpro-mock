# Lab 02 — Provider Matrix Recovery

> Independent Terraform Professional-style practice lab. This is not an official HashiCorp exam task.

## Scenario

A platform team split one AWS estate across three operating identities. A rushed provider upgrade and a partial resource migration left the working directory in an unsafe state. The existing LocalStack resources and Terraform state must be preserved while you repair the configuration.

**Target time:** 50–60 minutes  
**Target difficulty:** advanced, approximately 90–95/100

## Required tools

- Terraform CLI 1.11.x
- Docker Desktop or Docker Engine
- Docker Compose v2
- Bash or PowerShell
- Python 3 for the shuffle test

LocalStack is used for repeatable practice. It can exercise shared profile loading, provider aliases, module provider mapping, state addresses, object migration mechanics, lifecycle behavior, and planning. It does **not** prove real AWS IAM authorization boundaries.

## Start and reset

From the lab root:

```bash
./scripts/setup.sh student
```

PowerShell:

```powershell
./scripts/setup.ps1 -Target student
```

To rebuild the original starter, use the reset script. The reset command requires an explicit destructive confirmation flag because it removes the LocalStack practice estate.

## Existing baseline

The setup creates an existing estate with:

- three operator roles,
- one compute launch template and autoscaling group,
- one audit IAM user,
- one S3 bucket,
- `artifact.txt` containing exactly `ORIGINAL-CONTENT`,
- a legacy state address for that object,
- semantic `terraform_data` addresses keyed by profile purpose.

Do not edit `terraform.tfstate` JSON directly. Do not delete and recreate the S3 object.

## Task 1 — Normalize the external provider catalog

Repair the expressions in `student/locals.tf`.

The catalog is split across CSV, JSON, and YAML. Their raw values intentionally differ:

- CSV values are strings and include empty strings.
- JSON includes numbers, booleans, and null values.
- YAML includes numbers, booleans, and null values.
- one logical key appears more than once,
- a map key is intentionally different from its AWS profile name,
- one conditional currently returns incompatible branch types.

Produce one stable local map whose values have a consistent object shape. Requirements:

- use semantic keys, never source row positions,
- combine duplicate fragments deliberately rather than silently dropping data,
- preserve null until a documented default is applied,
- normalize booleans and numbers,
- normalize module targets into a deduplicated, stable collection,
- make input ordering irrelevant to resource addresses.

## Task 2 — Build shared AWS files

Create:

- `student/.aws/config`
- `student/.aws/credentials`

The config file must contain exactly these three role profiles and no default profile:

- `compute-operator`
- `identity-operator`
- `readonly-auditor`

Each role profile must use `us-east-1`, an appropriate role ARN, a source profile, and an output format. The credentials file must contain LocalStack-only test credentials for the source profile. Never place real AWS credentials in this lab.

The starter contains near-miss paths, an invalid default profile, and incorrect names. Remove or ignore the decoys after creating the correct files.

## Task 3 — Repair provider and module wiring

The root module must use three **fixed** provider aliases:

- `aws.compute`
- `aws.identity`
- `aws.readonly`

Provider blocks cannot be generated dynamically with `for_each`. Read profile names and settings from the normalized local map, but declare the aliases statically.

Required routing:

- compute module → `aws.compute`
- identity module → `aws.identity`
- storage module → an explicitly selected provider
- `data.aws_caller_identity.current` → `aws.readonly`

Use explicit module `providers` maps. Each child module must declare the alias it expects with `configuration_aliases`; child modules must not create uncontrolled default AWS provider configurations.

## Task 4 — Upgrade the AWS provider safely

Repair the incompatible provider constraint and dependency lock selection.

Requirements:

- use an explicit compatible range,
- do not remove version constraints,
- do not use an unbounded latest version,
- update the lock file through Terraform,
- `terraform init` must complete without a provider version conflict.

## Task 5 — Migrate the existing object without replacement

The remote object already exists. The starter has both a legacy resource type and a new resource type, with a subtle content difference.

Final requirements:

- only `aws_s3_object.artifact` manages the object,
- the legacy resource type and legacy state address are gone,
- bucket and key stay unchanged,
- content remains exactly `ORIGINAL-CONTENT`,
- the remote object is not deleted, recreated, or overwritten,
- the final plan contains no create, delete, or replace action.

Choose a supported state-mapping technique. The README intentionally does not provide the command, import identifier, or full answer.

## Task 6 — Preserve remote compute capacity

The existing autoscaling group has remote desired capacity `1`. The repaired configuration must declare desired capacity `2`, while Terraform must not plan to modify that one remote attribute.

Requirements:

- ignore only the precise attribute,
- do not ignore the whole resource,
- do not remove the resource from state,
- unrelated drift must remain visible.

## Task 7 — Prove key stability with the shuffle test

After the repaired solution has reached a clean plan, run:

```bash
./scripts/shuffle-test.sh student
```

or:

```powershell
./scripts/shuffle-test.ps1 -Target student
```

The script deterministically reorders CSV, JSON, and YAML records, creates another plan, reports create/delete/replace actions, and restores the original files. Reordering must not change persistent resource addresses.

## Completion criteria

A completed lab has:

- valid normalized profile data,
- exactly three fixed root AWS aliases,
- explicit module provider mappings,
- child `configuration_aliases`,
- an updated provider lock selection,
- only the new S3 object address,
- exact object content preservation,
- precise desired-capacity lifecycle handling,
- a final `0 add / 0 change / 0 destroy` plan,
- a shuffle plan with no create, delete, or replace actions.

Use `VALIDATION.md` from the separate solution package only after completing your attempt.
