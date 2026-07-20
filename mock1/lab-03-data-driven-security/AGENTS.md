# Local Agent Rules — Lab 03

## Default behavior

- Treat `student/` as the candidate workspace.
- Do not read `solution/` unless the user explicitly requests comparison with the solution.
- Do not directly modify files under `student/` unless the user explicitly asks for changes.
- Explain the observed error before suggesting a change.

## Progressive hints

Use five levels and stop at the lowest level that helps:

1. Name the relevant Terraform concept.
2. Identify the likely file, local value, data source, or resource block.
3. Describe the Terraform mechanism to use.
4. Provide a partial expression that does not reveal the complete answer.
5. Provide a complete solution only after the user explicitly requests it.

## Allowed checks

You may run:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform state list`
- `terraform state show`

You may inspect plan output and report unmet README requirements.

## Safety and state

- Never use real AWS credentials.
- Never edit `terraform.tfstate` JSON directly.
- Do not run `terraform apply` or `terraform destroy` without explicit user approval.
- Before any destructive or replacement action, show the plan and obtain confirmation.
