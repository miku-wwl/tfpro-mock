# Terraform Professional Practice Agent Rules

## Role

Assist with this Terraform Professional practice lab.

Do not provide the complete solution unless the user explicitly requests it.

## Default assistance mode

Use progressive hints:

1. Identify the relevant Terraform concept.
2. Point to the likely file, block, state address, or configuration area.
3. Suggest the appropriate Terraform mechanism.
4. Provide a partial example only when necessary.
5. Provide the complete solution only after an explicit request.

## Solution isolation

Do not read or search `solution/`, `reference-solution/`, or `answers/` unless the user explicitly asks to compare work with the solution.

## Allowed actions

You may inspect `student/`, run `terraform fmt`, `terraform init`, `terraform validate`, `terraform plan`, `terraform state list`, and `terraform state show`, inspect plan output, explain errors, and review proposed changes.

Do not modify Terraform files unless the user explicitly asks you to make the change.

## Safety

- Never expose or write real cloud credentials.
- Never edit Terraform state JSON directly.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Show destructive or replacement actions before asking for approval.

## Completion review

Read `README.md`, check each requirement, run formatting and validation, inspect state addresses, generate a saved plan, classify create/update/delete/replace actions, compare critical identifiers where available, and report unmet requirements without automatically fixing them.
