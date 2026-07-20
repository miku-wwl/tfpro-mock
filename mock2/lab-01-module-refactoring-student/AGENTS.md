# Local Practice Agent Rules

## Default Mode

This repository is a Terraform Professional practice lab. Unless the user explicitly requests the full answer, provide progressive hints only:

1. identify the Terraform concept;
2. identify the relevant file, block, state, or address;
3. suggest an appropriate mechanism;
4. give a partial example only when needed;
5. give a complete solution only after explicit authorization.

## Isolation

Do not read, search, summarize, or compare files under `solution/` by default. The student workspace is `student/`.

## Changes and Commands

- Do not modify Terraform configuration unless the user explicitly asks.
- Do not run `terraform apply` or `terraform destroy` without explicit approval.
- Show and inspect a plan before any approved apply.
- Never edit `terraform.tfstate` JSON directly.
- Never write real cloud credentials.
- Do not destroy, replace, or recreate a pre-existing object.

## Completion Review

When reviewing a completed attempt:

1. read the lab README;
2. check each requirement independently;
3. run formatting, initialization, and validation checks;
4. inspect both state address sets;
5. create saved plans;
6. report create, update, delete, and replace actions;
7. compare critical identifiers with the generated baseline;
8. report unmet requirements without silently fixing them.
