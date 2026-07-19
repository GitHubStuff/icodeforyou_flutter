# Copilot Program-Folder Merge Instructions

## 1. Program Folder Status
- `/programs/*` contains experimental or broken code.
- Tests inside `/programs/*` must never be run or referenced.
- CI/CD must never be triggered by changes inside `/programs/*`.

## 2. Merge Behavior
For merge conflicts inside `/programs/*`, Copilot must:
- Not attempt to fix or modernize broken code.
- Not introduce new patterns, refactors, or architecture.
- Only unify the conflicting blocks with minimal changes.
- Preserve existing behavior, even if flawed.

## 3. Intent Extraction
Copilot must:
- Summarize intent of both sides.
- Identify whether the conflict is structural, logical, or formatting-only.
- Ask for clarification if intent is unclear.

## 4. Safety Rules
Copilot must not auto-merge conflicts involving:
- authentication
- payment flows
- build_runner configuration
- Melos workspace configuration
- platform channels
- CI/CD configuration
- secrets or tokens

Copilot must output an analysis and request human review.

## 5. Output Format
Copilot must output:

**A. Unified code block**  
**B. Explanation (3–6 sentences)**  
**C. Why this merge is safe for `/programs/*`**  
**D. Risks or follow-ups**

Copilot must not output anything outside this structure.
