# Lab 03 — Data-Driven Security Rules

## Purpose

This is an independent Terraform Professional practice lab. It is designed to test data decoding, normalization, collection types, stable resource addressing, data sources, and explicit provider identity boundaries. It does **not** reproduce or claim to reproduce any official certification question.

**Target time:** 45–55 minutes  
**Target difficulty:** 92–96/100  
**Terraform CLI:** 1.11.x  
**Runtime:** Docker Desktop, Docker Compose, LocalStack, Bash or PowerShell

## Scenario

A platform team has already created a VPC, two subnets, and three security groups. You are not allowed to recreate those resources in the student configuration. You must discover them through data sources and then create ingress rules from an external file.

The same logical rule set is supplied in CSV, JSON, and YAML. Your configuration must support all three formats without duplicating resource blocks or maintaining three separate implementations.

The environment intentionally separates three AWS identities:

- `readonly`: discovers existing networking resources.
- `rules`: creates security-group ingress rules.
- `audit`: reads provider-derived caller identity information.

Passing `terraform apply` is not sufficient. Provider aliases and module mappings must match the required identity boundary.

## Start the environment

From the lab root:

### Bash

```bash
./scripts/setup.sh
```

### PowerShell

```powershell
./scripts/setup.ps1
```

The setup script starts LocalStack, prepares the bootstrap configuration, shows a plan, and asks for explicit confirmation before applying the pre-created infrastructure.

Then work only in `student/`.

## Pre-created infrastructure

The bootstrap configuration creates resources with randomized physical names and these logical tags:

| Resource | Logical tag value |
|---|---|
| VPC | `core` |
| Public subnet | `public` |
| Administration subnet | `administration` |
| Frontend security group | `frontend` |
| Datastore security group | `datastore` |
| Operations security group | `operations` |

Your student configuration must dynamically discover:

- VPC ID
- subnet IDs
- subnet CIDR blocks
- security-group IDs
- caller account ID

Do not hardcode IDs, CIDRs, or a provider-derived account ID.

---

## Task 1 — Read external data

Define a variable named `rules_format`.

Allowed values:

- `csv`
- `json`
- `yaml`

Default value: `csv`

Requirements:

- Use `csvdecode` for CSV.
- Use `jsondecode` for JSON.
- Use `yamldecode` for YAML.
- Select one decoded rule set from `rules_format`.
- Do not create separate resource implementations for each format.

## Task 2 — Normalize the input

Create `local.normalized_rules` with a consistent object shape containing exactly these logical fields:

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

- Convert ports to `number` or `null`.
- Convert `enabled` to `bool`.
- Normalize protocol values consistently.
- CSV, JSON, and YAML must produce equivalent Terraform values.
- Do not hardcode logic by file row number.

## Task 3 — Filter rules

Only retain rules where:

- `direction` is `ingress`
- `enabled` is `true`

The supplied egress rule and disabled ingress rule must not create resources.

## Task 4 — Discover existing infrastructure with the required identity

Use the `inventory` child module and data sources to discover all pre-created resources.

Requirements:

- Networking data sources must use the `readonly` provider alias.
- Caller identity must use the `audit` provider alias.
- The root module must pass providers explicitly with a `providers` map.
- The child module must declare the aliases with `configuration_aliases`.
- Do not replace either alias with the default provider merely because the configuration can run.

## Task 5 — Create security-group rules

There must be exactly one `aws_vpc_security_group_ingress_rule` resource block in the implementation.

Requirements:

- Use `for_each` and a `for` expression.
- Do not use `count`.
- Do not create one resource block per rule.
- Do not use a list index as a permanent resource key.
- Create rules through the `rule_engine` child module.
- The root module must explicitly map the `rules` provider alias into the module.
- The child module must declare its alias with `configuration_aliases`.

The `for_each` key must be:

- unique
- stable
- independent of input ordering
- able to distinguish source, destination, protocol, from-port, and to-port

Source behavior:

- When `source` is `-`, use `source_selector` to resolve a subnet CIDR and set only `cidr_ipv4`.
- When `source` names a security group, set only `referenced_security_group_id`.
- `cidr_ipv4` and `referenced_security_group_id` must be mutually exclusive.
- `protocol = -1` must use valid port arguments.
- The rule description must use the caller account ID returned by the `audit` provider; do not hardcode it.

The input contains two rules targeting `operations` on TCP port `8082`. They have different source security groups and both must exist.

## Task 6 — Create outputs

Create these outputs:

- `normalized_rules`
- `ingress_rule_keys`
- `rules_by_destination`
- `rules_count_by_protocol`
- `source_types`
- `created_rule_ids`

`ingress_rule_keys` must make it clear that the two `operations:8082` rules have different stable keys.

## Task 7 — Prove address stability

Use the supplied shuffle script to randomize row order in CSV, JSON, and YAML.

### Bash

```bash
./scripts/shuffle-input.sh
```

### PowerShell

```powershell
./scripts/shuffle-input.ps1
```

After shuffling:

- resource addresses must remain unchanged
- no existing rule may be deleted and recreated solely because the input order changed
- a final plan must be stable

## Completion conditions

A complete solution should produce 10 active ingress rules for each input format and a final plan of `0 to add, 0 to change, 0 to destroy` after apply. Follow `VALIDATION.md` from the solution package for the full review process.

## Reset

### Bash

```bash
./scripts/reset.sh
```

### PowerShell

```powershell
./scripts/reset.ps1
```

Both scripts require explicit confirmation before running destroy operations.
