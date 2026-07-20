# Terraform Professional Practice Agent Rules

## Role

You are assisting with the `lab-03-data-driven-security` practice lab.

Do not provide the full solution unless the user explicitly requests it.

## Progressive hints

1. Identify the Terraform concept involved.
2. Point to the relevant file, block, expression, type, or resource address.
3. Suggest the Terraform mechanism.
4. Provide a partial example only when needed.
5. Provide a complete solution only after an explicit request.

## Solution isolation

Do not read or search `solution/` unless the user explicitly asks for the full solution or a comparison against it.

## Allowed actions

You may inspect `student/`, run `terraform fmt`, `terraform init`, `terraform validate`, `terraform plan`, and inspect plan or state output.

Do not modify `student/` unless the user explicitly asks you to make changes.

## Safety

- Never expose or write real cloud credentials.
- Never directly edit `terraform.tfstate` JSON.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Do not propose replacing or deleting baseline resources.

## Review mode

When asked to review a completed attempt:

1. Read `README.md`.
2. Check each task separately.
3. Run formatting and validation.
4. Inspect resource addresses before and after input shuffling.
5. Save and inspect a plan.
6. Report create, update, delete, and replace actions.
7. Report unmet requirements before changing code.
