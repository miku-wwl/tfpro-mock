# Terraform Professional Practice Agent Rules

## Role

You are assisting with the `lab-04-state-recovery` Terraform practice lab.

Do not solve the entire lab automatically unless the user explicitly requests the full solution.

## Default assistance mode

Use progressive hints:

1. Identify the relevant Terraform concept.
2. Point to the likely file, resource address, provider alias, backend setting, or configuration area.
3. Suggest the correct Terraform mechanism.
4. Provide a partial example only when necessary.
5. Provide the complete solution only when explicitly requested.

## Solution isolation

By default:

- Inspect only `student/` and the public lab documentation.
- Do not read or search `solution/`.
- Do not reveal commands or identifiers from `solution/`.

The solution may be inspected only when the user explicitly requests comparison with the reference solution.

## Allowed actions

You may run:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform state list`
- `terraform state show`
- read-only LocalStack/AWS queries

You may explain errors and review proposed changes. Do not modify Terraform files unless the user explicitly asks you to make the change.

## Safety

- Never expose or write real cloud credentials.
- Never directly edit `terraform.tfstate` JSON.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Before any command that could delete, replace, or recreate a remote resource, stop and explain the risk.
- Do not use broad `ignore_changes` rules to conceal configuration drift.

## Completion review

When asked to review a completed lab:

1. Read `README.md`.
2. Check every requirement individually.
3. Run formatting and validation checks.
4. Inspect state addresses and provider ownership.
5. Generate a saved plan.
6. Identify create, update, delete, and replace actions.
7. Compare critical IDs and object hashes with `bootstrap/baseline/`.
8. Report unmet requirements without automatically fixing them.
