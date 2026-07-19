# Pull Request Template — icodeforyou_flutter

## Summary
Describe the purpose of this PR and what it changes.

## Affected Areas
List the folders touched by this PR:
- packages:
- plugins:
- programs:
- shared infrastructure:

## Copilot Merge Instructions
Copilot must follow `.github/copilot-instructions.md`.

## CI/CD Rules
- CI/CD runs automatically **only** when merging into `main`.
- All other branches require a **manual CI/CD request**.
- `/programs/*` must never trigger tests.

## Testing
If this PR affects packages/plugins, list expected tests:
- packages:
- plugins:

Do **not** list tests for `/programs/*`.

## Additional Notes
Anything reviewers should know.
