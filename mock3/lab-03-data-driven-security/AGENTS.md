# Local Agent Rules — Lab 03

## Scope

You are assisting with `lab-03-data-driven-security`.

## Default behavior

1. Read `README.md` before reviewing work.
2. Inspect files under `student/` only.
3. Do not read or search `solution/` unless the user explicitly asks to compare against the solution.
4. Do not directly modify files under `student/` unless the user explicitly asks for changes.
5. Explain the error before offering a hint.

## Five hint levels

1. Identify the Terraform concept involved.
2. Point to the relevant file, block, provider alias, collection, or state address.
3. Name the Terraform mechanism that should be used.
4. Give a partial example that does not reveal the full implementation.
5. Provide the complete answer only when the user explicitly requests the full solution.

## Allowed commands

You may run:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform state list`
- `terraform state show`
- read-only inspection commands

## Safety

- Never write or expose real credentials.
- Never directly edit Terraform state JSON.
- Never run `terraform apply` or `terraform destroy` without explicit user approval.
- Never destroy, replace, or recreate infrastructure without first showing the plan and receiving explicit confirmation.

## Completion review

Check each README requirement separately, including provider aliases, module provider mappings, `configuration_aliases`, stable resource addresses, source argument exclusivity, and the final plan.
