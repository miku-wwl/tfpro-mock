# Lab 03 — Data-Driven Network Policy

> Independent Terraform Professional practice lab. This is not an official exam question and does not reproduce any official exam content.

## Objective

Repair a partially completed Terraform configuration that reads equivalent network-policy records from CSV, JSON, or YAML and creates AWS VPC security-group ingress rules with stable resource addresses.

**Target time:** 45–55 minutes  
**Difficulty target:** advanced Terraform Professional practice

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or PowerShell

The bootstrap configuration creates the infrastructure that already exists before the lab starts:

- one VPC;
- two subnets, representing a public segment and an administration segment;
- three security groups, representing edge, records, and control workloads.

Physical AWS names contain a generated suffix. Discover resources from tags and relationships; do not depend on a generated name or an ID copied from state.

## Candidate workspace

Work only in `student/`.

Do not modify:

- `bootstrap/`;
- `student/data/`;
- `docker-compose.yml`;
- the provider endpoint and test credential settings;
- pre-created VPCs, subnets, or security groups.

Do not create replacement VPCs, subnets, or security groups. Do not use real cloud credentials.

## Setup

From the lab root:

```bash
./scripts/setup.sh
cd student
terraform init
terraform validate
terraform plan
```

PowerShell:

```powershell
./scripts/setup.ps1
Set-Location student
terraform init
terraform validate
terraform plan
```

The starter is intentionally incorrect. A successful `terraform validate` does not prove the tasks are complete.

## Data contract

`student/data/rules.csv`, `rules.json`, and `rules.yaml` express the same policy records. Each record contains:

- `direction`
- `source`
- `destination`
- `from_port`
- `to_port`
- `protocol`
- `source_selector`
- `description`
- `enabled`

When `source` is `-`, `source_selector` identifies a subnet CIDR. Otherwise, `source` identifies another security group.

## Task 1 — Read external data

Define `variable "rules_format"` with:

- allowed values: `csv`, `json`, `yaml`;
- default value: `csv`.

Read exactly one selected file:

- use `csvdecode` for CSV;
- use `jsondecode` for JSON;
- use `yamldecode` for YAML.

Do not create separate resource blocks or separate policy pipelines for each format.

## Task 2 — Normalize the input

Create `local.normalized_rules` so every selected format produces the same Terraform value shape.

Every normalized object must contain:

- `direction`
- `source`
- `destination`
- `from_port`
- `to_port`
- `protocol`
- `source_selector`
- `description`
- `enabled`

Requirements:

- ports are numbers or `null`;
- `enabled` is a boolean;
- protocol and routing labels are normalized consistently;
- no record may be handled by its list position or a hardcoded row number.

## Task 3 — Filter the policy

Only records meeting both conditions may create resources:

- `direction` is `ingress`;
- `enabled` is `true`.

The disabled ingress record and the egress record must not appear in the resource map.

## Task 4 — Create ingress rules

Use exactly one `aws_vpc_security_group_ingress_rule` resource block.

You must use:

- a `for` expression;
- `for_each`.

You must not use:

- `count`;
- one resource block per record;
- a list index as a persistent resource key.

The `for_each` key must be unique, deterministic, independent of input order, and able to distinguish source, destination, protocol, start port, and end port. The two TCP/8082 rules targeting the control security group must both exist and must have different addresses.

Resolve all VPC, subnet, subnet-CIDR, and security-group IDs through data sources.

For a subnet-CIDR source, set only `cidr_ipv4`. For a security-group source, set only `referenced_security_group_id`. These arguments are mutually exclusive.

For protocol `-1`, handle port arguments according to the provider schema instead of substituting an artificial port value.

## Task 5 — Produce outputs and prove stability

Create these outputs:

- `normalized_rules`
- `ingress_rule_keys`
- `rules_by_destination`
- `rules_count_by_protocol`
- `source_types`
- `created_rule_ids`

The outputs must make it possible to confirm that:

- ten ingress rules are enabled;
- two different sources create TCP/8082 rules for the control security group;
- the egress and disabled records are excluded;
- CSV, JSON, and YAML produce the same logical result.

After a successful apply, run the shuffle script and create another plan:

```bash
../scripts/shuffle-input.sh student
terraform plan -var='rules_format=csv'
```

PowerShell:

```powershell
../scripts/shuffle-input.ps1 -Target student
terraform plan -var='rules_format=csv'
```

Reordering any of the three input arrays must not change resource addresses or force rule replacement.

## Completion standard

A completed submission should pass:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

With LocalStack running and the solution applied, the final plan should report no resource changes. See `VALIDATION.md` in the instructor package for the full manual validation sequence.
