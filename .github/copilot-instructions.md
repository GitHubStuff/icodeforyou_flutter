# Copilot Merge Instructions for icodeforyou_flutter

## 1. Monorepo Structure
- `/packages/*` = stable Dart/Flutter packages  
- `/plugins/*` = Flutter plugins  
- `/programs/*` = experimental apps/tools (tests are broken)  
- Only `/packages/*/test/**` and `/plugins/*/test/**` contain valid tests.  
- Copilot must never run or reference tests inside `/programs/*`.

## 2. CI/CD Rules
- Pull request validation workflows may run automatically when relevant files change.  
- Release/deployment CI/CD runs automatically **only** on merges into `main`.  
- For non‑main branches, when release/deployment CI/CD is requested, Copilot must output:  
  **“Non‑main branch detected — CI/CD requires manual request.”**  
- Copilot must not trigger CI/CD for non‑main branches.

## 3. Intent Extraction
For every merge conflict, Copilot must:
- Summarize the intent of both sides.  
- Identify whether the change affects a package, plugin, program, or shared infrastructure.  
- Ask for clarification if intent is unclear.

## 4. Authority Rules
- **HEAD branch is authoritative** for public APIs, stable behavior, and architectural boundaries.  
- **Incoming branch is authoritative** for new features, bug fixes, and performance improvements.  
- If both branches modify the same logic, unify them while preserving correctness.

## 5. Merge Behavior
Copilot must:
- Produce a single unified code block with no conflict markers.  
- Preserve data structures, Riverpod providers, build_runner artifacts, error handling, null‑safety guards, DI boundaries, and plugin platform‑channel safety checks.  
- Not remove or rewrite architectural patterns.

## 6. Safety Rules
Copilot must not auto‑merge conflicts involving:
- authentication  
- payment flows  
- build_runner configuration  
- Melos workspace configuration  
- platform channels  
- CI/CD configuration  
- secrets or tokens  

Instead, Copilot must output an analysis and request human review.

## 7. Test Rules
- Recommend tests only for packages/plugins.  
- Never recommend or run tests for `/programs/*`.  
- Suggest regression tests when behavior changes.  
- List which packages/plugins should be tested.

## 8. Required Output Format
Copilot must output:

**A. Unified code block**  
**B. Explanation (3–6 sentences)**  
**C. List of affected packages/plugins**  
**D. Test recommendations (packages/plugins only)**  
**E. CI/CD behavior based on branch**  
**F. Risks or follow‑ups**

Copilot must not output anything outside this structure.
