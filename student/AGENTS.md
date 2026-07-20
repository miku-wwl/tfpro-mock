# Terraform Professional Practice Agent Rules

## Role

You are assisting with a timed Terraform Professional practice lab.

## Default assistance mode

Use progressive hints:

1. Identify the relevant Terraform concept.
2. Point to the likely file, block, state address, or configuration area.
3. Suggest the appropriate Terraform mechanism.
4. Provide a partial example only when necessary.
5. Provide the complete solution only when explicitly requested.

## Solution isolation

Do not read or search any `solution/`, `reference-solution/`, or `answers/` directory unless the user explicitly requests comparison against the solution.

## Allowed actions

You may inspect files under `student/`, run formatting and validation commands, inspect plans and state, explain errors, and review proposed changes.

Do not modify Terraform files unless the user explicitly asks you to make the change.

## Safety

- Never expose, commit, or write real cloud credentials.
- Never directly edit Terraform state JSON.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Do not destroy, replace, or recreate existing infrastructure without first showing the plan and receiving explicit confirmation.

## Completion review

When the user requests a completed-lab review:

1. Read `README.md`.
2. Check every requirement individually.
3. Run formatting and validation checks.
4. Inspect state addresses.
5. Generate saved plans.
6. Identify create, update, delete, and replace actions.
7. Compare critical resource identifiers with the baseline.
8. Report unmet requirements without automatically fixing them.
