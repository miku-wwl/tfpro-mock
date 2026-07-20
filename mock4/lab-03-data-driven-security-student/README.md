# Lab 03 — Data-Driven Security Rules

## Scenario

A platform team already operates a small network in LocalStack. The VPC, two subnets, and three security groups were created before your shift began. Your task is to repair a Terraform configuration that reads the same rule catalogue from CSV, JSON, or YAML and creates only the required ingress rules.

This is an original practice exercise. It is not an official exam question and does not reproduce any official assessment.

**Target time:** 45–55 minutes  
**Target difficulty:** Terraform Professional, 92–96/100

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or PowerShell

The setup creates randomized resource names. Do not hardcode generated AWS identifiers or CIDR values in the lab configuration.

## Start

Bash:

```bash
./scripts/setup.sh
cd student
terraform init
```

PowerShell:

```powershell
./scripts/setup.ps1
Set-Location student
terraform init
```

The starter is intentionally defective. A failing validation or plan is part of the exercise.

## Existing infrastructure

Discover all infrastructure through data sources. The bootstrap stack creates:

- one VPC tagged with `Lab = lab-03-data-driven-security` and `Role = network`
- two subnets tagged with roles `public` and `administration`
- three security groups tagged with roles `edge`, `ledger`, and `control`

Do not create replacements for these resources in the lab configuration.

## Task 1 — Read external data

Define `variable "rules_format"` with allowed values `csv`, `json`, and `yaml`; its default must be `csv`.

- Use `csvdecode` for CSV.
- Use `jsondecode` for JSON.
- Use `yamldecode` for YAML.
- Select one input format without duplicating resource blocks or maintaining three independent implementations.

The three catalogues describe the same logical rules, but their raw scalar types intentionally differ.

## Task 2 — Normalize the catalogue

Create `local.normalized_rules` and normalize every item to the same object shape:

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

- ports are numbers or `null`
- `enabled` is a boolean
- protocol and selector values are normalized consistently
- JSON/YAML `null` and CSV empty strings have identical meaning
- a missing selector must remain `null`; do not silently turn it into a meaningful empty-string value
- do not special-case input row numbers

## Task 3 — Filter rules

Only retain records where:

- `direction == "ingress"`
- `enabled == true`

The egress record and disabled ingress record must not create resources.

## Task 4 — Resolve sources and create rules

Use exactly one `aws_vpc_security_group_ingress_rule` resource block.

You must use:

- `for_each`
- one or more `for` expressions
- data sources for VPC, subnet CIDRs, and security group IDs

You must not use:

- `count`
- repeated resource blocks
- manually authored resources per input row
- list positions as permanent resource keys

Source semantics:

- `source == "-"` means a CIDR source selected by `source_selector`
- any other source is a security-group role
- CIDR rules set only `cidr_ipv4`
- security-group rules set only `referenced_security_group_id`
- the two arguments must be mutually exclusive
- `protocol == "-1"` must use valid port handling

The `for_each` key must be unique, stable, independent of input order, and distinguish every field that determines resource identity. In particular, the two `control` rules on TCP/8082 must have different addresses.

## Task 5 — Outputs

Create these outputs:

- `normalized_rules` — a map of normalized objects
- `ingress_rule_keys`
- `rules_by_destination`
- `rules_count_by_protocol`
- `source_types`
- `created_rule_ids`
- `unique_protocols`

The outputs must make it easy to prove that:

- both TCP/8082 rules targeting `control` exist
- CIDR and security-group sources are resolved differently
- all three input formats produce the same logical result

## Shuffle test

After a successful apply, run the shuffle script from the package root:

```bash
./scripts/shuffle-input.sh
```

or:

```powershell
./scripts/shuffle-input.ps1
```

The script reorders CSV rows, the JSON array, and the YAML list. A correct solution keeps the same Terraform resource addresses and produces no delete/create actions solely because input ordering changed.

## Completion criteria

- formatting passes
- initialization succeeds
- validation succeeds after repairs
- CSV, JSON, and YAML produce equivalent plans
- there are 15 enabled ingress resources
- exactly two enabled TCP/8082 rules target `control`, with different source security groups
- egress and disabled records create nothing
- the all-protocol rule uses null ports
- shuffle testing causes no infrastructure changes

Use `VALIDATION.md` from the Solution package only after completing your closed-book attempt.
