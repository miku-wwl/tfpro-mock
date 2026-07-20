# Closed-Book Lab Agent Rules

## Scope

You are assisting with the active Terraform practice lab in this directory.

## Command Control

- Execute only commands the user explicitly requests.
- Do not proactively run Terraform, Docker, AWS, LocalStack, file mutation, or state mutation commands.
- Explain command output and error messages only after the user provides them or explicitly requests execution.

## Assistance Limits

- Do not modify Terraform files unless the user explicitly requests a specific edit.
- Do not provide complete Terraform resources, complete module implementations, complete migration sequences, import identifiers, state addresses, or answer-ready command lists.
- When the user has not explicitly asked for a named Terraform mechanism, do not give guidance more specific than the relevant configuration area or observed error.
- Do not reveal hidden assumptions, deliberate inconsistencies, or likely trap locations.

## State and Infrastructure Safety

- Never write or expose real cloud credentials.
- Never directly edit Terraform state JSON.
- Never run apply, destroy, or any operation that can create, replace, delete, forget, or reassign infrastructure without explicit user approval for that exact command.
- Before an approved infrastructure-changing action, show and explain the available plan output.

## Isolation

- Do not access previous simulation sets, previous lab solutions, external answer repositories, or any directory named `solution`, `reference-solution`, `answers`, or `hidden-answer`.
- Treat `bootstrap/` as environment provisioning material, not as an answer source.

## Review Mode

When the user explicitly asks for a completion review:

1. Read the examination requirements.
2. Check requirements individually.
3. Run only the validation commands the user authorizes.
4. Report observed create, update, delete, replace, and state-ownership issues.
5. Report unmet requirements without automatically fixing them.
