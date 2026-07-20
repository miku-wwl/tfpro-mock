# Lab 01 — Boundary-Aware Module Refactoring

> Independent Terraform Professional-style practice lab. This is not an official HashiCorp exam question.

## Time box

70–80 minutes

## Scenario

A platform team has inherited one working Terraform root module. The configuration currently manages networking, security boundaries, provider-access roles, compute workloads, and an artifact archive in one state file. The infrastructure already exists before the timed exercise begins.

Your job is to refactor the configuration without replacing any managed infrastructure. The final design must also preserve strict AWS identity boundaries. A configuration that merely applies successfully but uses the wrong profile, alias, region, provider mapping, state location, or lock-file constraint does not meet the requirements.

## Environment

- Terraform CLI 1.11.x
- Docker Desktop and Docker Compose
- LocalStack
- Bash or Windows PowerShell

Run the setup script before starting the timer:

```bash
./scripts/setup.sh
```

```powershell
./scripts/setup.ps1
```

The setup creates pre-existing LocalStack resources, copies their state into the student root, and records a baseline. The credentials stored in this lab are LocalStack-only dummy values.

## Required identity contract

The final roots must load these files through exact paths relative to each root module:

- Shared config: `${path.root}/../../.aws/config`
- Shared credentials: `${path.root}/../../.aws/credentials`

The files must contain the following contract:

| Profile | `source_profile` | Exact role ARN | Region | Intended use |
|---|---|---|---|---|
| `fabric-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01NetworkOperator` | `us-east-1` | VPC, subnets, security groups, state bucket |
| `workload-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01WorkloadOperator` | `us-east-1` | IAM and EC2 |
| `archive-admin` | `local-base` | `arn:aws:iam::000000000000:role/Lab01ArchiveOperator` | `us-west-2` | Artifact bucket and object |
| `observer` | `local-base` | `arn:aws:iam::000000000000:role/Lab01ReadOnlyObserver` | `us-east-1` | Read-only data sources |

The credentials file must contain only the `local-base` source profile. Do not add a `default` profile. Do not replace the required profiles with static credentials in provider blocks.

## Provider contract

Use the following AWS provider aliases in the final configuration:

- `aws.network`
- `aws.workload`
- `aws.archive`
- `aws.readonly`

Every child module must declare the aliases it consumes, and every root module call must include an explicit `providers` map. At least two child modules must use `configuration_aliases`. The caller-identity data source must use `aws.readonly`, even though an unaliased high-privilege provider could also return a result.

The archive resources must remain in `us-west-2`; the other AWS resources remain in `us-east-1`.

## Initial layout

The timed exercise starts in `student/` with a valid monolithic configuration. Most managed resources are in `combined.tf`. The `refactor-draft/` folder contains realistic but incorrect fragments supplied by the fictional platform team. Those fragments are not loaded by Terraform until you adapt them into the target layout.

Confirm the initial plan shows no managed-resource actions before changing configuration or state.

## Target layout

```text
student/
├── .aws/
├── infra/
│   ├── shared/
│   └── application/
└── modules/
    ├── network/
    ├── security/
    ├── identity/
    └── compute/
```

Each child module must contain `main.tf`, `variables.tf`, and `outputs.tf`.

## Task 1 — Establish the baseline

1. Inspect the active configuration and state.
2. Confirm the initial plan has `0 to add, 0 to change, 0 to destroy`.
3. Record the current addresses for ordinary, `count`, and `for_each` resources.
4. Preserve the IDs recorded under `baseline/`.
5. Do not remove, replace, or recreate any existing managed resource.

## Task 2 — Refactor into child modules

Move responsibilities as follows:

| Module | Responsibilities | Required AWS aliases |
|---|---|---|
| `network` | VPC and subnets | `aws.network` |
| `security` | Security groups, ingress rules, egress rules, read-only caller identity | `aws.network`, `aws.readonly` |
| `identity` | Provider-access roles, workload role, instance profile | `aws.workload` |
| `compute` | EC2 instances | `aws.workload` |

Rules:

- Child modules must not refer directly to resources inside sibling modules.
- Cross-module values must pass through a root module using typed inputs and outputs.
- Do not hardcode cloud resource IDs or a provider-derived AWS account ID.
- Do not declare an unintended default AWS provider inside a child module.
- Root module calls must explicitly map every required provider alias.

## Task 3 — Repair dependencies and draft defects

Repair the supplied refactoring fragments while constructing the target layout. The final data flow must include all of the following:

- The security module receives the VPC ID from the network module.
- The compute module receives subnet IDs, security-group IDs, and the instance-profile name.
- The identity module receives the shared naming value and the observed AWS account ID.
- A child module consumes a map output produced by another module.
- The shared naming value continues to affect resources in both final states.

The draft contains multiple independent defects, including collection misuse, an incorrect object attribute, a variable-contract mismatch, an undeclared argument, an omitted provider mapping, and a data source that can run under the wrong identity. Correct the defects rather than hiding them with broad `ignore_changes` rules.

## Task 4 — Migrate resource addresses

Align every existing state object with its final module address without recreating infrastructure.

The completed state migration must cover:

- ordinary resources
- `count` instances
- `for_each` instances with string keys
- resources crossing into child-module addresses
- resources later separated into different root states

The final states must contain no legacy root addresses from `student/combined.tf`.

## Task 5 — Split roots and states

Create two independent roots:

### `infra/shared`

Manages:

- network module
- security module
- shared random naming resource
- artifact bucket and object
- remote-state bucket

Its backend key must be exactly:

```text
tfpro-sim/lab-01/shared.tfstate
```

### `infra/application`

Manages:

- identity module
- compute module

Its backend key must be exactly:

```text
tfpro-sim/lab-01/application.tfstate
```

The application root must consume shared outputs through `terraform_remote_state`. Only the application root may read the shared state; child modules may not contain remote-state data sources.

No resource may remain managed by both states. Shared resources must not remain in the application state, and application resources must not remain in the shared state.

## Task 6 — Provider version and lock file

The inherited root uses a deliberately broad AWS provider constraint. In both final roots:

- require AWS provider `~> 5.90.0`
- require Random provider `3.6.3` only where it is used
- refresh `.terraform.lock.hcl`
- preserve a lock entry for AWS `5.90.0`
- do not commit provider binaries or `.terraform/`

A stale lock constraint, missing platform checksum, or silently selected AWS 6.x provider is not acceptable.

## Completion conditions

The lab is complete only when all of the following are true:

1. Both final roots initialize successfully with their exact backend keys.
2. Both final roots validate successfully.
3. Both final plans contain `0 to add, 0 to change, 0 to destroy`.
4. No baseline resource ID changes.
5. The final provider aliases, profiles, source profile, role ARNs, regions, file paths, module provider maps, and state provider addresses match this README.
6. The caller-identity data source is evaluated through `aws.readonly`.
7. No legacy address remains.
8. No broad lifecycle rule masks a dependency or state error.

Use `CHECKS.md` for non-answer validation commands. The complete state-migration procedure is intentionally excluded from the Student package.
