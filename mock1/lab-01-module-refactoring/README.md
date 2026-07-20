# Terraform Professional Simulation — Lab 01: Module Refactoring

> Independent practice material. This is not an official HashiCorp exam question.

## Scenario

A platform team has a working monolithic Terraform configuration that manages an existing LocalStack environment. The configuration currently produces a no-change plan. Your task is to refactor it into reusable child modules and then split management into two independent root modules without replacing any existing infrastructure.

**Target time:** 70–80 minutes  
**Recommended Terraform CLI:** 1.11.x

## Safety and completion conditions

- Treat all currently managed resources as existing production-like resources.
- Do not destroy, replace, or recreate any managed resource.
- Do not edit Terraform state JSON directly.
- Do not use broad lifecycle suppression to hide configuration drift.
- Preserve the resource identifiers recorded by the setup process.
- The final plan in both root modules must report no additions, changes, or deletions.

## Environment

From the lab root, run the setup script for your shell:

```bash
./scripts/setup.sh
```

```powershell
./scripts/setup.ps1
```

The setup process starts LocalStack, creates the baseline infrastructure, prepares the monolithic student state, and records baseline evidence under `student/baseline/`.

---

## Task 1 — Establish the baseline

1. Inspect the Terraform configuration under `student/`.
2. Inspect the current state addresses and the saved baseline evidence.
3. Confirm that the monolithic configuration produces a no-change plan before refactoring.
4. Record the addresses of the VPC, both subnets, the three security groups, the instance profile, and both `for_each` EC2 instances.
5. Keep all baseline resource identifiers unchanged throughout the lab.

## Task 2 — Refactor into child modules

Refactor the monolithic configuration into these direct child modules under `student/modules/`:

| Child module | Must manage |
|---|---|
| `network` | VPC and subnets |
| `security` | Security groups and ingress rules |
| `identity` | IAM role and instance profile |
| `compute` | EC2 instances |

Requirements:

- Each child module must contain `main.tf`, `variables.tf`, and `outputs.tf`.
- Do not add another module nesting layer.
- Child modules must not reference resources inside sibling modules.
- Cross-module data must pass through a root module using explicit inputs and outputs.
- Do not hard-code VPC, subnet, security group, instance profile, or instance identifiers.
- Keep the shared S3 resources and `random_pet` at the shared root level in the final design.

The supplied module drafts are intentionally inconsistent. Repair them as part of the refactor rather than replacing the exercise with unrelated code.

## Task 3 — Repair module dependencies and contracts

The final module contracts must satisfy all of the following:

- The security module receives one VPC ID as a string.
- The network module exposes subnet IDs as a map keyed by the logical subnet keys used by the instance definitions.
- The security module exposes security group IDs as a map keyed by security group name.
- The identity module receives the shared naming object and derives exactly the same role and instance-profile names as the baseline.
- The compute module receives the subnet-ID map, security-group-ID map, and instance-profile name.
- The compute module selects values by stable string keys; it must not index a set or treat a map as a list.
- The EC2 resource remains a single `for_each` resource with the keys `gateway` and `worker`.

## Task 4 — Migrate resource addresses

Update state ownership so every existing object is managed at its final address without replacement.

The final configuration must cover:

- a normal singleton resource moving into a child module;
- both count-indexed subnet instances moving into the network module;
- all string-keyed `for_each` security-group and EC2 instances moving into child modules;
- security-group rules whose source and destination IDs come from module outputs;
- the IAM instance profile moving into the identity module and then being consumed by compute.

After the address migration, no legacy monolithic resource address may remain.

## Task 5 — Split root modules and remote state

Create exactly two root modules:

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

### Shared root

The `infra/shared` root must manage:

- `random_pet` and shared naming;
- the network module;
- the security module;
- the artifact S3 bucket and object;
- the S3 bucket used by the Terraform backends.

Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/shared.tfstate
```

### Application root

The `infra/application` root must manage:

- the identity module;
- the compute module.

Its S3 backend key must be exactly:

```text
tfpro-sim/lab-01/application.tfstate
```

The application root must read shared outputs through `terraform_remote_state`. Only the application root may access remote state; child modules must not contain remote-state data sources or backend configuration.

## Final verification

Your final evidence must show:

- no resource is managed in both states;
- shared resources are absent from the application state;
- application resources are absent from the shared state;
- both final plans are no-change plans;
- all identifiers in `student/baseline/baseline-resource-ids.json` are preserved.
