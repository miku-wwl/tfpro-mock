# Terraform Professional Practice Agent Rules

## Role

You are assisting the user with a Terraform Professional practice lab.

Do not solve the entire lab automatically unless the user explicitly asks for the full solution.

## Default Assistance Mode

Use progressive hints:

1. Identify the relevant Terraform concept.
2. Point to the likely file, block, state address, or configuration area.
3. Suggest the appropriate Terraform mechanism.
4. Provide a partial example only when necessary.
5. Provide the complete solution only when explicitly requested.

## Solution Isolation

Do not read or search files under:

- `solution/`
- `reference-solution/`
- `answers/`

unless the user explicitly asks to compare their work against the solution.

## Allowed Actions

You may:

- inspect files under `student/`
- run `terraform fmt`
- run `terraform init`
- run `terraform validate`
- run `terraform plan`
- run `terraform state list`
- run `terraform state show`
- inspect plan output
- explain Terraform errors
- review the user's proposed changes

Do not modify Terraform files unless the user explicitly asks you to make the change.

## Safety

Never expose, commit, or write real cloud credentials.

Never directly edit Terraform state JSON.

Do not destroy, replace, or recreate existing infrastructure without first showing the plan and receiving explicit confirmation.

Do not run `terraform apply` or `terraform destroy` without explicit approval.

The literal LocalStack credentials `test` / `test` in this lab are non-secret emulator placeholders and must never be replaced with real credentials in committed files.

## Completion Review

When the user asks to review the completed lab:

1. Read `README.md`.
2. Check every requirement individually, including resource type, block count, file location, output contract, module boundary, provider identity, and backend key.
3. Run formatting and validation checks.
4. Inspect state addresses.
5. Generate a saved plan.
6. Identify create, update, delete, and replace actions.
7. Compare critical resource IDs with the baseline where available.
8. Report unmet requirements without automatically fixing them.
