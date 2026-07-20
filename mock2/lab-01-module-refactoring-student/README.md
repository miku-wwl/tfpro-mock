# Terraform Professional Simulation — Lab 01: State-Safe Module Refactoring

> Independent practice material. This is not an official HashiCorp exam question.

## Scenario

A platform team owns a working but tightly coupled Terraform root module. All infrastructure already exists in the target account, and the current local state matches the legacy configuration. The team wants two independently operated root modules without changing any remote object.

You have **70–80 minutes**. Treat any create, delete, or replacement proposal for a pre-existing object as a failed migration.

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or Windows PowerShell

Run the provided setup script before starting. The script creates the pre-existing resources, copies the matching state into `student/`, and records real baseline identifiers. Do not place real AWS credentials anywhere in this lab.

## Starting Point

- `student/combined.tf` is the active, valid monolithic configuration.
- `student/infra/` and `student/modules/` contain an incomplete refactoring draft. The draft is intentionally not connected to the active root module and contains several dependency and type defects.
- Every managed object is protected against destruction.
- The initial active root module must produce a clean plan before you change it.

## Required Final Layout

```text
student/
├── infra/
│   ├── shared/
│   └── application/
└── modules/
    ├── network/
    ├── security/
    ├── identity/
    └── compute/
```

Nested implementation inside one of these modules is allowed when it preserves clear ownership.

## Task 1 — Establish the Baseline

1. Inspect the active configuration and current state.
2. Confirm that the initial plan has no infrastructure actions.
3. Record all ordinary, indexed, keyed, module-ready, and nested-module resource addresses in `student/ADDRESS-WORKSHEET.md`.
4. Record the baseline IDs produced by setup.
5. Do not continue if any pre-existing object is already proposed for creation, deletion, or replacement.

## Task 2 — Refactor into Child Modules

Create and connect the four required child modules.

- `network` owns the VPC and subnets.
- `security` owns the security groups and ingress rules.
- `identity` owns the IAM role and instance profile.
- `compute` owns the EC2 instances.

Each required module must contain `main.tf`, `variables.tf`, and `outputs.tf`. Child modules must not reach into sibling module internals. Pass all cross-module values through root-module inputs and outputs. Do not hard-code remote IDs.

The final shared root must call the network module with the module name `shared`. The final application root must call the identity module with the module name `application`.

## Task 3 — Repair Dependencies and Contracts

Repair every defect in the draft while preserving the existing remote configuration.

The final design must satisfy all of the following:

- The security module receives the VPC ID through an input.
- The compute module receives subnet IDs as a **map keyed by segment name**.
- The compute module receives security group IDs as a map.
- The compute module receives the instance profile name through an input.
- The identity module receives the shared naming token through an input.
- At least one module consumes a map output from another module through the root module.
- The final subnet collection is keyed by stable segment names and is independent of the original list order.
- The legacy ordered subnet output is replaced by a keyed map contract.

## Task 4 — Preserve Resource Identity While Changing Addresses

Move the existing objects to their final ownership without recreating them.

Your final state layout must cover:

- an ordinary resource address;
- an indexed resource address converted to stable keyed instances;
- keyed resource instances containing hyphens or composite strings;
- a root resource owned by `module.shared`;
- a root resource owned by `module.application`;
- at least one nested module address.

The README intentionally states only the required result. Select appropriate Terraform state and configuration mechanisms yourself. Do not edit state JSON directly.

## Task 5 — Split the Root Modules and States

Create two independent root modules:

### Shared root

Path: `student/infra/shared`

Owns:

- shared naming;
- network;
- security;
- artifact bucket and retained object;
- remote-state bucket.

Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/shared.tfstate
```

### Application root

Path: `student/infra/application`

Owns:

- identity;
- compute.

Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/application.tfstate
```

The application root must read the shared contract through `terraform_remote_state`. Only a root module may access remote state. No child module may access it.

At the end, a resource may be managed by only one state. Shared resources must not remain in the application state, and application resources must not remain in the shared state.

## Completion Conditions

- Both final root modules initialize successfully.
- Both final root modules validate successfully.
- Both final plans show **0 to add, 0 to change, 0 to destroy**.
- No pre-existing resource ID changes.
- No legacy address remains.
- No broad `ignore_changes` rule is used to hide drift.
- No real credentials or provider binaries are added to the submission.
