# Lab 03 — Data-Driven Security Rules

> Independent Terraform Professional practice material. This lab is not an official HashiCorp exam question and does not claim to reproduce one.

## Scenario

A platform team already provisioned a VPC, two subnets, and three security groups in a LocalStack AWS account. Security policy rows now arrive in CSV, JSON, or YAML. Your job is to repair the starter configuration so that one Terraform implementation produces the same security-group rules from every supported format.

The starter is intentionally close to complete but contains implementation traps. A result that merely looks correct in AWS is not sufficient: the required resource type, block count, file ownership, data sources, output contracts, and stable resource addresses are all assessed.

**Target time:** 45–55 minutes  
**Target difficulty:** Terraform Professional 92–96/100

## Working boundaries

- Run the infrastructure bootstrap from `bootstrap/`; treat that directory as read-only during the exercise.
- Make candidate changes only under `student/`.
- The candidate configuration is a **root-module-only** implementation. Do not introduce child modules.
- All AWS data sources and the ingress resource must remain in the candidate root module. A child module that reads or owns them is non-compliant even if it works.
- Do not create the VPC, subnets, or security groups in `student/`; discover them dynamically.
- Do not edit Terraform state JSON directly.

## Execution contract

| Item | Required contract |
|---|---|
| Terraform CLI | `1.11.x` |
| Provider identity | The unaliased/default `hashicorp/aws` provider configured for the LocalStack endpoint |
| Backend | Local backend only |
| Backend key | **Not applicable for the local backend**; do not add S3, HCP Terraform, or another remote backend. The active state filename remains `terraform.tfstate` in the working directory. |
| Candidate module boundary | Root module only; no child modules |
| Resource type | `aws_vpc_security_group_ingress_rule` |
| Resource block count | Exactly **one** candidate ingress resource block |
| Resource location | `student/main.tf` |
| Iteration | `for_each` fed by a `for` expression |
| Forbidden iteration | `count`, `count.index`, or an input-list index used as a persistent key |
| Data-source location | `student/data_sources.tf` |
| Normalization location | `student/locals.tf` |
| Output location | `student/outputs.tf` |

Alternative resource types, repeated resource blocks, manually declared rules, or a broad `lifecycle.ignore_changes` do not satisfy this contract.

## Environment setup

Prerequisites:

- Docker Desktop with Docker Compose
- Terraform CLI 1.11.x
- Bash or PowerShell
- Python 3 for the shuffle helper

Start LocalStack and create the pre-existing resources:

```bash
./scripts/setup.sh
```

PowerShell:

```powershell
./scripts/setup.ps1
```

The bootstrap creates one tagged VPC, two tagged subnets (`public` and `administration` roles), and three tagged security groups (`frontend`, `datastore`, and `operations` roles). Their AWS names include a generated suffix. Candidate code must use data sources and tags rather than copied IDs or fixed names.

## Task 1 — Read one external format

Define and retain `variable "rules_format"` in `student/variables.tf`.

- Allowed values: `csv`, `json`, `yaml`
- Default: `csv`
- CSV must be decoded with `csvdecode`.
- JSON must be decoded with `jsondecode`.
- YAML must be decoded with `yamldecode`.
- Do not create three copies of the resource logic.

The files under `student/data/` describe the same policy set. CSV ports and booleans arrive as strings; JSON and YAML may contain numbers, booleans, or `null`.

## Task 2 — Discover the existing network

Use AWS data sources to obtain, at runtime:

- the VPC ID;
- both subnet IDs and CIDR blocks;
- all three security-group IDs.

Use the bootstrap tags to identify resources. The starter contains deliberate fixed-value fallbacks that must not survive in the completed solution. Do not copy IDs from CLI output into Terraform code.

## Task 3 — Normalize the policy objects

Create `local.normalized_rules` in `student/locals.tf`. Every element must expose exactly these attributes with consistent Terraform types across CSV, JSON, and YAML:

- `direction` — string
- `source` — string
- `destination` — string
- `from_port` — number or `null`
- `to_port` — number or `null`
- `protocol` — string
- `source_selector` — string
- `description` — string
- `enabled` — bool

Normalize case where appropriate and do not special-case rows by their line number or current position.

## Task 4 — Filter before resource creation

Only rows where both conditions are true may reach the resource:

- `direction == "ingress"`
- `enabled == true`

The supplied data intentionally includes an egress row and a disabled ingress row. Both must be absent from the managed resource instances.

## Task 5 — Build stable rule instances

In `student/main.tf`, retain exactly one block of type `aws_vpc_security_group_ingress_rule` and use `for_each`.

The permanent instance key must be unique, deterministic, and independent of input order. It must distinguish at least:

- source identity;
- destination;
- protocol;
- from port;
- to port.

Two enabled rules target the `operations` security group on TCP port `8082`, but they come from different security groups. Both must exist with different resource addresses.

Source semantics:

- When `source == "-"`, use `source_selector` to select a discovered subnet CIDR. Set only `cidr_ipv4`.
- When `source` names a security-group role, set only `referenced_security_group_id`.
- `cidr_ipv4` and `referenced_security_group_id` are mutually exclusive for every instance.
- For protocol `-1`, port arguments must be handled as absent rather than empty strings.

Using `count`, multiple ingress resource blocks, index-based keys, or a different security-group-rule resource type is a partial-completion failure even if the remote rules look similar.

## Task 6 — Produce the exact outputs

Create all six outputs in `student/outputs.tf`. Values must be computed from decoded data, data sources, locals, or managed resources; hard-coded output payloads are forbidden.

| Output name | Required Terraform type |
|---|---|
| `normalized_rules` | `list(object({ direction=string, source=string, destination=string, from_port=number|null, to_port=number|null, protocol=string, source_selector=string, description=string, enabled=bool }))` |
| `ingress_rule_keys` | `list(string)` sorted deterministically |
| `rules_by_destination` | `map(list(object(...)))` grouped from the enabled ingress rules |
| `rules_count_by_protocol` | `map(number)` |
| `source_types` | `set(string)` containing the source categories represented by enabled ingress rules |
| `created_rule_ids` | `map(string)` keyed by the permanent `for_each` keys |

`ingress_rule_keys` must make it possible to verify that both `operations:8082` rules have different keys.

## Task 7 — Prove format and order independence

For each format:

```bash
terraform -chdir=student plan -var='rules_format=csv'
terraform -chdir=student plan -var='rules_format=json'
terraform -chdir=student plan -var='rules_format=yaml'
```

After a correct apply, all three plans must describe the same ten enabled ingress rules.

Then randomize the row/list order:

```bash
./scripts/shuffle-input.sh
```

PowerShell:

```powershell
./scripts/shuffle-input.ps1
```

A correct implementation keeps every `aws_vpc_security_group_ingress_rule.managed["..."]` address stable. Reordering must not cause delete/create actions or output-only drift.

## Completion standard

A completed lab must satisfy all implementation contracts, not just remote AWS state:

- exactly one required ingress resource block in the required file;
- only `for_each`, with a stable semantic key;
- data-source-based VPC, subnet, CIDR, and security-group lookup;
- equivalent CSV, JSON, and YAML normalization;
- ten enabled ingress instances;
- two distinct `operations` TCP/8082 instances from different source security groups;
- no egress or disabled instance;
- mutual exclusivity of CIDR and referenced-SG source arguments;
- correct all-protocol handling;
- all six outputs with the stated names and types;
- clean plan after format switching and input shuffling.

Use `VALIDATION.md` from the separately supplied solution package for the full review procedure. There is no automatic grader.

## Cleanup

```bash
./scripts/reset.sh
```

PowerShell:

```powershell
./scripts/reset.ps1
```
