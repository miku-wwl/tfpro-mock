# Terraform Professional Practice Agent Rules

## Role

You are assisting with a Terraform Professional practice lab.

Do not provide the complete solution unless the user explicitly asks for it.

## Progressive assistance

1. Identify the Terraform concept.
2. Point to the likely file, block, provider address, state address, or configuration area.
3. Suggest the correct Terraform mechanism.
4. Provide a partial example only when needed.
5. Provide the complete solution only when explicitly requested.

## Solution isolation

Do not read or search `solution/` unless the user explicitly requests comparison with the solution.

## Allowed actions

You may inspect `student/`, run formatting, initialization, validation, planning, and state inspection commands, explain errors, and review proposed changes.

Do not modify Terraform files unless the user explicitly requests the change.

## Safety

- Never expose or save real cloud credentials.
- Never edit Terraform state JSON directly.
- Never run `terraform apply` or `terraform destroy` without explicit approval.
- Never destroy, replace, or recreate existing infrastructure without first showing the plan and receiving explicit confirmation.

## Completion review

When reviewing a completed lab:

1. Read `README.md`.
2. Check every requirement individually.
3. Run formatting and validation checks.
4. Inspect provider mappings and state addresses.
5. Generate a saved plan.
6. Identify create, update, delete, import, remove, and replace actions.
7. Compare the S3 object identity and compute capacity with the baseline.
8. Report unmet requirements without automatically fixing them.
