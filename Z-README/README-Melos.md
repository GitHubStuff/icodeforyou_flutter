# Melos Commands — `icodeforyou_flutter`

Quick reference for every `melos run` script defined in `pubspec.yaml`.
All test/coverage logic is delegated to `melos_tool/melos_test.zsh`.

> **One-time setup:** `chmod +x melos_tool/melos_test.zsh`

---

## Workspace bootstrap

```bash
melos bootstrap
```

Run this after cloning, after pulling changes that touch `pubspec.yaml` files, and after adding a new package to the workspace.

---

## Analyze

| Command | What it does |
|---|---|
| `melos run analyze` | Run `dart analyze .` from the workspace root |
| `melos run analyze_all` | Run `dart analyze .` inside every workspace member |

---

## Build

| Command | What it does |
|---|---|
| `melos run build` | Run `build_runner build --delete-conflicting-outputs` in every package that depends on `build_runner` |

---

## Tests — Packages

| Command | What it does |
|---|---|
| `PKG=<name> melos run test_package` | Test + coverage for one package (auto-detects Flutter vs Dart) |
| `melos run test_all` | Test every package sequentially |
| `STRICT=true melos run test_all` | Same, but stop on first failure |
| `melos run test_coverage` | Run tests with coverage in every package (auto-detects Flutter vs Dart) |
| `melos run coverage_merge` | Merge package LCOVs → `coverage/html/index.html` (auto-opens) |

**Example:**
```bash
PKG=since_when melos run test_package
```

---

## Tests — Plugins

| Command | What it does |
|---|---|
| `PRG=<name> melos run test_plugin` | Test + coverage for one plugin |
| `melos run test_plugins` | Test every plugin sequentially |
| `STRICT=true melos run test_plugins` | Same, but stop on first failure |
| `melos run test_plugin_coverage` | Run tests with coverage in every plugin |
| `melos run coverage_merge_plugins` | Merge plugin LCOVs → `coverage/plugins_html/index.html` (auto-opens) |

**Example:**
```bash
PRG=status_bar_chameleon melos run test_plugin
```

---

## Tests — Programs

| Command | What it does |
|---|---|
| `PRG=<name> melos run test_program` | Test + coverage for one program |
| `melos run test_programs` | Test every program sequentially |
| `STRICT=true melos run test_programs` | Same, but stop on first failure |
| `melos run test_programs_coverage` | Run tests with coverage in every program |
| `melos run coverage_merge_programs` | Merge program LCOVs → `coverage/programs_html/index.html` (auto-opens) |

**Example:**
```bash
PRG=startup_demo melos run test_program
```

---

## Coverage — Workspace-wide

| Command | What it does |
|---|---|
| `melos run coverage_clean` | Wipe `coverage/` at root **and** every per-package `coverage/` directory |
| `melos run coverage_merge_all` | Merge LCOVs from packages + plugins + programs → `coverage/all_html/index.html` (auto-opens). Excludes `widgetbook_workspace`. |

---

## Widgetbook

| Command | What it does |
|---|---|
| `melos run widgetbook` | Launch widgetbook in Chrome |
| `melos run widgetbook_build` | Run `build_runner build --delete-conflicting-outputs` for widgetbook |
| `melos run widgetbook_clean` | Clean widgetbook generated files |

---

## Utilities

| Command | What it does |
|---|---|
| `melos run list_packages` | List every package, plugin, and program in the workspace |

---

## Common workflows

### Full coverage report across the entire workspace
```bash
melos run coverage_clean
melos run test_coverage
melos run test_plugin_coverage
melos run test_programs_coverage
melos run coverage_merge_all
```

### Quick check on one package
```bash
PKG=animated_widgets melos run test_package
```

### CI-style strict run
```bash
STRICT=true melos run test_all
STRICT=true melos run test_plugins
STRICT=true melos run test_programs
```

---

## Environment variables

| Variable | Used by | Purpose |
|---|---|---|
| `PKG` | `test_package` | Package name under `packages/` |
| `PRG` | `test_plugin`, `test_program` | Plugin or program name |
| `STRICT` | All `test_all*` scripts | `true` = stop on first failure |

---

## Architecture

```
icodeforyou_flutter/
├── pubspec.yaml              ← thin script wrappers
└── melos_tool/
    └── melos_test.zsh        ← all test/coverage logic
```

Every test and coverage script in `pubspec.yaml` delegates to `melos_tool/melos_test.zsh` with one of these actions:

- `test_one <category> <name>`
- `test_all <category>`
- `test_coverage <category>`
- `coverage_merge <category>`
- `coverage_merge_all`
- `coverage_clean`

Categories: `packages | plugins | programs`
