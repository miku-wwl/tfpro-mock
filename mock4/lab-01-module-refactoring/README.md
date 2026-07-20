# Terraform Professional Simulation — Lab 01: Module Refactoring and Stable Data Normalization

> Independent practice material. This is not an official HashiCorp exam item.

## Scenario

A legacy LocalStack environment is managed by one root module. The configuration is operational, but it mixes network, security, identity, compute, storage, naming, and external-data transformation in one state. You must refactor it without replacing any existing infrastructure.

The exercise is intentionally time constrained. Target completion time: **70–80 minutes**. Target difficulty: **90–95 / 100** for Terraform Professional preparation.

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or Windows PowerShell

Run the setup script from the repository root before starting. The setup process creates the LocalStack resources, copies the baseline state into the student root through Terraform CLI state commands, and records baseline identifiers.

## Constraints

- Preserve every existing remote object and its identifier.
- Do not edit Terraform state JSON directly.
- Do not use broad `ignore_changes` rules to conceal drift.
- Do not hard-code VPC, subnet, security group, instance profile, instance, bucket, or object identifiers.
- Child modules must not read another child module's internal resources.
- Only root modules may read remote state.
- The final `for_each` keys must be semantic and stable. Input row numbers or list indexes are not acceptable permanent identities.
- Reordering CSV, JSON, or YAML input must not cause resource replacement.
- Preserve `null` as `null`; do not silently convert it to an empty string.

## Input data

The `student/data` directory contains CSV, JSON, and YAML records. Their raw scalar types differ intentionally:

- CSV represents every value as a string and contains empty strings.
- JSON contains numbers, booleans, and `null`.
- YAML contains numbers, booleans, `null`, and maps.
- The same semantic object key can appear in more than one source. Later source precedence is CSV < JSON < YAML.

Normalize all sources into one consistent object shape before passing data to modules.

## Task 1 — Establish the baseline

1. Inspect the current configuration and state.
2. Confirm the starter root has no planned create, update, delete, or replacement actions.
3. Record the legacy addresses for ordinary resources, `count` instances, and `for_each` instances.
4. Compare critical identifiers with `baseline/baseline-resource-ids.json`.
5. Preserve all existing infrastructure.

## Task 2 — Refactor into child modules

Complete the child modules under `student/modules`:

| Module | Responsibility |
|---|---|
| `network` | VPC and subnets |
| `security` | Security groups and security group rules |
| `identity` | IAM role and instance profile |
| `compute` | EC2 instances |

Each child module must have `main.tf`, `variables.tf`, and `outputs.tf`.

The network and compute module inputs must use maps of typed objects. The root module must transform decoded lists into stable maps before passing them to child modules. At least one child-module object attribute must be optional.

## Task 3 — Repair data and module dependencies

The provided refactor scaffold is deliberately incomplete and contains semantic defects. Correct it so that:

- the security module receives the VPC ID through a root-module value;
- the compute module receives subnet IDs as a map;
- the compute module receives security group IDs as a map;
- the compute module receives the instance profile name;
- shared naming is passed to the identity and compute modules;
- module outputs are consumed through declared output contracts;
- duplicate semantic keys across decoded inputs are resolved using the documented source precedence;
- conditional expressions return compatible types;
- sets are not accessed by numeric index;
- object attributes use their declared names;
- `null` descriptions remain null;
- one output is reconstructed as a map keyed by the actual resource key.

Use Terraform collection functions where they fit the problem. The final implementation should include justified use of functions such as `flatten`, `merge`, `distinct`, `toset`, or `lookup` rather than procedural duplication.

## Task 4 — Migrate resource addresses

Move all legacy state addresses to their final module addresses without recreating remote resources. The final addresses must cover:

- an ordinary resource;
- legacy `count` addresses mapped to stable semantic keys;
- existing `for_each` addresses;
- resources transferred to a different root state.

The final plan must contain no legacy resource addresses and no create, delete, or replacement action caused only by refactoring.

## Task 5 — Split root modules and states

Complete these independent root modules:

- `student/infra/shared`
- `student/infra/application`

The S3 backend keys must be exactly:

- `tfpro-sim/lab-01/shared.tfstate`
- `tfpro-sim/lab-01/application.tfstate`

The shared root must manage network, security, shared naming, artifact storage, and the LocalStack state bucket. The application root must manage identity and compute.

The application root must obtain shared outputs through `terraform_remote_state`. Only the application root may access that remote state; child modules must not.

## Completion conditions

- Shared root plan: 0 add, 0 change, 0 destroy.
- Application root plan: 0 add, 0 change, 0 destroy.
- No critical identifier differs from the baseline.
- No legacy monolithic address remains.
- Reordering all three input files causes no create, delete, or replacement action.
- Outputs expose normalized object maps, stable resource-keyed inventories, and nullable descriptions correctly.
