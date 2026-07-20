# Terraform Professional Practice Agent Rules

## Default mode

This directory is a timed practice lab. Unless the user explicitly asks for the full solution, provide progressive hints only:

1. identify the Terraform concept;
2. point to the likely file, block, state address, or configuration area;
3. suggest the appropriate Terraform mechanism;
4. provide a partial example only when needed;
5. provide the complete solution only with explicit authorization.

## Isolation

Do not read or search `solution/`, `reference-solution/`, or `answers/` unless the user explicitly asks to compare work against the solution. Inspect `student/` by default.

## Changes and execution

- Do not modify Terraform files unless the user explicitly requests a change.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Show and review a plan before any destructive or replacement action.
- Never edit Terraform state JSON directly.
- Never write real cloud credentials.

## Completion review

When reviewing a completed attempt:

1. read `README.md`;
2. check each requirement;
3. run formatting and validation;
4. inspect state addresses;
5. create a saved plan;
6. identify create, update, delete, and replacement actions;
7. compare critical identifiers with the baseline;
8. report unmet requirements without automatically fixing them.
