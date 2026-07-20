# Lab 01 — State-Preserving Module Refactoring

> Independent Terraform Professional-style practice lab. This is not an official HashiCorp exam question.

## Scenario

A small operations platform already exists in AWS-compatible infrastructure. Its Terraform configuration is a single legacy root module, and its local state contains all resources. Your assignment is to refactor the configuration into four child modules, divide ownership between two root modules, migrate the state to two S3 backend keys, and finish with no infrastructure replacement.

**Target time:** 70–80 minutes  
**Difficulty target:** 90–95 / 100  
**Primary environment:** Terraform CLI 1.11.x, Docker Desktop, Docker Compose, and LocalStack

The visible AWS result is not the only acceptance criterion. Exact implementation requirements below are independently checked.

## Start and safety rules

1. Run the environment setup instructions in `ENVIRONMENT.md`.
2. Work only in `student/`.
3. Treat every existing remote object and identifier as retained infrastructure.
4. Do not manually edit Terraform state JSON.
5. Do not use broad `lifecycle.ignore_changes` rules to hide drift.
6. Do not replace a required resource type with a different type, even when the resulting AWS object appears equivalent.
7. Do not hardcode an ID, generated name, or intermediate output value.
8. Before accepting any plan, inspect create, update, delete, and replace actions.

## Required final directory layout

Your final work under `student/` must use exactly these ownership roots and child-module directories:

```text
student/
├── infra/
│   ├── application/
│   └── shared/
└── modules/
    ├── compute/
    ├── identity/
    ├── network/
    └── security/
```

Each child-module directory must contain `main.tf`, `variables.tf`, and `outputs.tf`. Draft module files are supplied, but their interfaces are not guaranteed to satisfy this specification.

## Task 1 — Establish the baseline

Inspect the legacy root module in `student/`. Confirm that its state contains the existing VPC, two indexed subnets, three keyed security groups, keyed ingress rules, IAM resources, two keyed instances, two buckets, one retained object, and one generated naming resource.

Record the initial resource addresses and confirm that the initial plan reports **0 to add, 0 to change, and 0 to destroy**. The following physical identifiers must remain unchanged throughout the exercise:

- VPC ID
- both subnet IDs
- all security group IDs
- both EC2 instance IDs
- IAM role and instance profile names
- artifact bucket name
- retained object key

## Task 2 — Refactor into exact child-module boundaries

The final child modules must meet every row in this table. Block counts refer to Terraform `resource` blocks, not instance counts.

| Child module | Required file | Required resource type and block count | Required ownership |
|---|---|---|---|
| `modules/network` | `main.tf` | exactly 1 `aws_vpc` block and exactly 1 `aws_subnet` block | the existing VPC and both existing subnets; the subnet block must use `count` |
| `modules/security` | `main.tf` | exactly 1 `aws_security_group` block and exactly 1 `aws_vpc_security_group_ingress_rule` block | all three groups and every existing ingress rule; both blocks must use `for_each` |
| `modules/identity` | `main.tf` | exactly 1 `aws_iam_role` block and exactly 1 `aws_iam_instance_profile` block | the existing runtime role and profile |
| `modules/compute` | `main.tf` | exactly 1 `aws_instance` block | both existing instances; the block must use `for_each` with the original stable string keys |

The four modules above are mandatory. Combining their responsibilities into fewer modules is non-compliant even when Terraform produces the correct infrastructure.

Child modules must not read sibling-module internals. Cross-module values must be passed through a root module. Child modules must contain no provider blocks, no backend blocks, and no `terraform_remote_state` data source.

## Task 3 — Repair interfaces and dependency flow

Use these exact child-module output contracts:

| Module | Output name | Required type and meaning |
|---|---|---|
| `network` | `vpc_id` | `string`, derived from the managed VPC |
| `network` | `subnet_ids` | `map(string)`, keyed by the segment keys from the input definitions |
| `security` | `security_group_ids` | `map(string)`, keyed by tier name |
| `identity` | `role_name` | `string`, derived from the managed IAM role |
| `identity` | `instance_profile_name` | `string`, derived from the managed instance profile |
| `compute` | `instance_ids` | `map(string)`, keyed by workload role |

Required dependency flow:

- `security` receives the VPC ID from the shared root.
- `compute` receives subnet IDs as a map.
- `compute` receives security group IDs as a map.
- `compute` receives the instance profile name from `identity`.
- `identity` receives the generated shared naming token through the application root.
- No hardcoded ID or copied state value may substitute for one of these interfaces.

Some supplied draft interfaces can be made to run by reshaping values in the root. That workaround is not accepted when it violates the exact input/output semantics above.

## Task 4 — Preserve all resources while changing addresses

Move every legacy state address to the address implied by the final ownership model. Your result must cover:

- a normal singleton address,
- indexed `count` addresses,
- keyed `for_each` addresses,
- addresses that move from the legacy root into a child module,
- addresses that move into different final state files.

The final state must contain no legacy managed-resource address from the original root module. A same-name destroy-and-recreate result is a failure. Re-uploading the retained S3 object is also a failure even when its content is unchanged.

## Task 5 — Split ownership into two root modules

### Shared root

`student/infra/shared` must call `network` and `security`. It also exclusively owns:

- exactly 1 `random_pet` block,
- exactly 2 `aws_s3_bucket` blocks,
- exactly 1 `aws_s3_object` block.

Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/shared.tfstate
```

The shared root must expose these exact root outputs:

| Output name | Required type |
|---|---|
| `network_id` | `string` |
| `subnet_ids_by_zone` | `map(string)` |
| `security_group_ids_by_tier` | `map(string)` |
| `shared_name_token` | `string` |
| `artifact_bucket_name` | `string` |
| `retained_object_key` | `string` |

Every value must be derived from managed resources or child-module outputs. Hardcoded output values are non-compliant.

### Application root

`student/infra/application` must call `identity` and `compute`. Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/application.tfstate
```

The application root must read the shared root through exactly 1 `terraform_remote_state` data block located in a root-module `.tf` file. No child module may read remote state.

It must expose these exact root outputs:

| Output name | Required type |
|---|---|
| `instance_ids_by_role` | `map(string)` |
| `instance_profile_name` | `string` |

## Provider identity and backend requirements

Both roots must use only the default `hashicorp/aws` provider configuration declared in that root. All managed AWS resources, including resources inside child modules, must inherit that default provider identity. Provider aliases, child-module provider blocks, default host credentials, and credentials embedded directly in a managed resource are outside this lab's required implementation.

For LocalStack, root provider configuration must use the emulator endpoint and the non-secret placeholder credentials documented in `ENVIRONMENT.md`. Both S3 backends must use the pre-existing bucket named `tfpro-lab01-state-archive`, path-style access, and their exact keys stated above. Keeping either final state local is non-compliant.

## Final acceptance conditions

1. Shared and application state contain only the resources assigned to their ownership boundaries.
2. No resource ID listed in the baseline changes.
3. The retained object is not deleted, replaced, or re-uploaded.
4. Both final plans report 0 add, 0 change, 0 destroy.
5. Required resource types, block counts, file locations, output names, output types, module boundaries, provider identity, and backend keys all match this document.
6. No broad `ignore_changes`, hardcoded intermediate output, duplicate ownership, or child-level remote-state access remains.
