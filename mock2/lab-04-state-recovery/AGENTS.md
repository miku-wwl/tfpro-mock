# Terraform Professional Practice Agent Rules

## Role

Assist with this Terraform Professional practice lab. Do not provide the full solution unless the user explicitly requests it.

## Default mode

Use progressive hints:

1. Identify the Terraform concept.
2. Point to the likely file, block, state address, or backend area.
3. Suggest the appropriate Terraform mechanism.
4. Provide only a partial example when necessary.
5. Provide complete commands only after an explicit request.

## Isolation

By default, inspect only `student/`. Do not read or search `solution/`, `reference-solution/`, or `answers/` unless the user explicitly asks to compare against the solution.

## Allowed actions

You may run:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform state list`
- `terraform state show`

You may inspect plans and explain errors. Do not modify Terraform files unless the user explicitly asks.

## Safety

- Never write real cloud credentials.
- Never edit Terraform state JSON directly.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Before any command that might delete, replace, recreate, or unmanage a remote resource, stop and explain the risk.
- Do not conceal drift with broad `ignore_changes` settings.

## Completion review

1. Read `README.md`.
2. Check each requirement independently.
3. Run formatting, initialization, and validation.
4. Inspect both state address sets.
5. Generate saved plans for both workspaces.
6. Identify create, update, delete, and replace actions.
7. Compare critical identifiers with `bootstrap/baseline/`.
8. Report unmet requirements without silently fixing them.
