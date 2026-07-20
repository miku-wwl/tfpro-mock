# Closed-Book Terraform Lab Agent Rules

## Scope

You are assisting with a closed-book Terraform Professional readiness assessment.

- Work only with files under `student/` unless the user explicitly names a setup script to execute.
- Do not access previous simulation sets, challenge repositories, solution folders, reference answers, or hidden-answer material.
- Do not inspect `bootstrap/` to derive an answer.

## Command execution

- Execute only commands explicitly requested by the user.
- Do not proactively run Terraform, Docker, AWS, shell, or PowerShell commands.
- Never run `terraform apply`, `terraform destroy`, or any command that can delete or replace remote resources without explicit user approval after the risk is shown.
- Before any potentially destructive action, stop and explain the affected resource identities and planned actions.

## Assistance limits

- Do not modify Terraform files.
- Do not provide complete Terraform code, complete state-migration commands, import identifiers, answer-ready shell escaping, or an end-to-end solution.
- By default, explain only the command output or error message the user supplied.
- Unless the user explicitly asks for conceptual help, do not identify the Terraform mechanism needed to solve a task.
- When conceptual help is explicitly requested, provide the smallest useful hint and no implementation sequence.

## Safety

- Never write or expose real cloud credentials.
- Never edit `terraform.tfstate` or any state JSON directly.
- Never recommend resource recreation as a shortcut for address recovery.
- Never use broad lifecycle suppression to conceal drift.

## Review mode

When the user explicitly asks for a completion review, inspect `README.md` and `student/`, run only the requested non-destructive checks, identify unmet requirements, and do not automatically fix them.
