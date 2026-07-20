# Lab 03 — Data-Driven Security Rules

## Scenario

A platform team already operates a small network baseline in LocalStack. The VPC, two subnets, and three security groups already exist. Your job is to read a rule catalogue supplied in CSV, JSON, or YAML, normalize it into one Terraform shape, and create only the enabled ingress rules.

This is an original practice lab. It is not an official exam question and does not claim to reproduce one.

**Target time:** 45–55 minutes  
**Target difficulty:** Terraform Professional, 92–96/100

## Environment

- Terraform CLI 1.11.x
- Docker Desktop with Docker Compose
- LocalStack
- Bash or PowerShell
- Python 3 only for the input-shuffle helper

## Start the lab

Bash:

```bash
./scripts/setup.sh
cd student
terraform plan
```

PowerShell:

```powershell
./scripts/setup.ps1
Set-Location student
terraform plan
```

The bootstrap configuration creates the baseline. Do not recreate the VPC, subnets, or security groups in `student/`.

## Baseline resources

The environment contains:

- one VPC;
- a `public` subnet;
- an `administration` subnet;
- a `frontend` security group;
- a `datastore` security group;
- an `operations` security group.

Discover their identifiers and subnet CIDRs through data sources. Do not hardcode generated IDs.

## Task 1 — Read external data

Define `variable "rules_format"` with these accepted values:

- `csv`
- `json`
- `yaml`

The default must be `csv`.

Read the matching file from `data/`:

- CSV with `csvdecode`;
- JSON with `jsondecode`;
- YAML with `yamldecode`.

Use one downstream rule-processing path. Do not create three copies of the security-group-rule resource.

## Task 2 — Normalize the input

Create `local.normalized_rules`. Every element must have this consistent object shape:

- `direction`
- `source`
- `destination`
- `from_port`
- `to_port`
- `protocol`
- `source_selector`
- `description`
- `enabled`

Normalization requirements:

- ports become `number` or `null`;
- `enabled` becomes `bool`;
- protocol and direction use a consistent case;
- CSV, JSON, and YAML produce equivalent normalized values;
- do not special-case individual row numbers.

## Task 3 — Filter rules

Keep only rules where:

- `direction` is `ingress`;
- `enabled` is `true`.

The egress row and disabled ingress row must not create resources.

## Task 4 — Create security-group rules

Use exactly one `aws_vpc_security_group_ingress_rule` resource block.

Requirements:

- use `for_each` and a `for` expression;
- do not use `count`;
- do not create one resource block per input row;
- do not use the list position as the long-lived resource key;
- keys must be unique, stable, and independent of input order;
- keys must distinguish source, destination, protocol, `from_port`, and `to_port`;
- two rules targeting `operations` on TCP/8082 must coexist because their sources differ;
- another rule intentionally shares source, destination, and port with one TCP/8082 rule but uses UDP;
- when `source` is `-`, resolve `source_selector` to a subnet CIDR and set only `cidr_ipv4`;
- when `source` is a security-group role, set only `referenced_security_group_id`;
- `cidr_ipv4` and `referenced_security_group_id` must be mutually exclusive;
- protocol `-1` must use the provider-compatible representation for ports.

## Task 5 — Outputs

Create these outputs:

- `normalized_rules`
- `ingress_rule_keys`
- `rules_by_destination`
- `rules_count_by_protocol`
- `source_types`
- `created_rule_ids`

`ingress_rule_keys` must make it possible to verify that the two TCP/8082 rules for `operations` have different addresses.

## Task 6 — Prove address stability

After a successful apply, shuffle the order of all three data files:

```bash
../scripts/shuffle-input.sh
terraform plan -var='rules_format=csv'
terraform plan -var='rules_format=json'
terraform plan -var='rules_format=yaml'
```

PowerShell:

```powershell
../scripts/shuffle-input.ps1
terraform plan -var='rules_format=csv'
terraform plan -var='rules_format=json'
terraform plan -var='rules_format=yaml'
```

Changing input order must not change resource addresses, delete rules, or recreate rules. A completed format should converge to a clean plan.

## Completion conditions

A completed solution should show:

- 10 enabled ingress rules;
- protocol counts of 8 TCP, 1 UDP, and 1 all-protocol rule;
- two TCP/8082 rules for `operations` with different source security groups;
- no egress or disabled rule;
- no resource address churn after shuffling;
- a final plan of `0 to add, 0 to change, 0 to destroy` after apply.

## Reset

The baseline resources use `prevent_destroy`. The reset scripts stop and remove the ephemeral LocalStack environment, then delete only local generated state and cache files.

```bash
./scripts/reset.sh
```

```powershell
./scripts/reset.ps1
```
