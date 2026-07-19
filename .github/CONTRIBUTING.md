# Contributing — icodeforyou_flutter

## How to Contribute
- Use feature branches for all work.
- Keep changes scoped to a single concern.
- Follow existing architecture and patterns.

## Branch Rules
- `main` is protected.
- CI/CD runs only on merges into `main`.
- All other branches require manual CI/CD requests.

## Commit Guidelines
- Write clear, descriptive commit messages.
- Reference issues when applicable.

## Pull Requests
- Use the PR template.
- Ensure Copilot follows `.github/copilot-instructions.md`.
- Do not include tests for `/programs/*`.

## Code Style
- Follow Dart and Flutter best practices.
- Run `melos bootstrap` before testing.
- Keep formatting consistent.

## Review Process
- All PRs require approval from code owners.
- High‑risk areas (auth, payments, CI/CD, platform channels) require manual review.
