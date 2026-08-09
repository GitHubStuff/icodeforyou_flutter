# Mason Package Template Cookbook

Step-by-step instructions for creating a Mason brick that scaffolds Flutter **packages** (in `{repo}/packages/`) inside a Melos-managed monorepo.

The governing principle: build a real, compiling reference package first, then convert it into a brick. A brick you can't compile before templatization is a brick you can't trust.

---

## Step 1 — Create the reference package

Create a genuine, analyzable package at `packages/velvet_package_reference` (a real name is better than `template`). Keep it **out of the workspace** `workspace:` list so it never ships.

Full structure:

```
packages/velvet_package_reference/
├── pubspec.yaml
├── analysis_options.yaml        # very_good_analysis include
├── README.md
├── CHANGELOG.md
├── lib/
│   ├── velvet_package_reference.dart      # barrel file
│   └── src/
│       └── velvet_package_reference_placeholder.dart
└── test/
    └── velvet_package_reference_test.dart
```

## Step 2 — Customize with house conventions

Apply every convention the generated packages must carry:

- `very_good_analysis` in `dev_dependencies` and `analysis_options.yaml`
- Dartdoc on all public and private members
- `final class` for non-widget classes, `abstract base class` for framework bases
- `_k`-prefixed constants
- Single widget per file
- `resolution: workspace` in `pubspec.yaml`
- Starting version `0.1.0`

**Verify green before proceeding:** run analysis and tests against the reference package. After Step 3 it becomes mustache and no longer compiles, so this is the last point it can be validated directly.

```zsh
melos analyze
fvm flutter test
```

## Step 3 — Templatize into the brick

Copy the package tree into the brick and replace every occurrence of the concrete name with mustache variables:

```
bricks/velvet_package/
└── __brick__/
    └── {{package_name.snakeCase()}}/
        ├── pubspec.yaml
        ├── analysis_options.yaml
        ├── README.md
        ├── CHANGELOG.md
        ├── lib/
        │   ├── {{package_name.snakeCase()}}.dart
        │   └── src/
        │       └── {{package_name.snakeCase()}}_placeholder.dart
        └── test/
            └── {{package_name.snakeCase()}}_test.dart
```

Replace in three places:

1. **Directory name** — `{{package_name.snakeCase()}}/`
2. **File names** — `{{package_name.snakeCase()}}.dart`, `{{package_name.snakeCase()}}_test.dart`
3. **File contents** — `name: {{package_name.snakeCase()}}` in the pubspec, class names as `{{package_name.pascalCase()}}`, the description variable, and imports (`package:{{package_name.snakeCase()}}/...`)

## Step 4 — Write `brick.yaml`

At `bricks/velvet_package/brick.yaml`:

```yaml
name: velvet_package
description: Scaffolds an icodeforyou Flutter package with house conventions.
version: 0.1.0

vars:
  package_name:
    type: string
    description: The package name (snake_case).
    prompt: Package name?
  package_description:
    type: string
    description: One-line pubspec description.
    prompt: Description?
```

## Step 5 — Write the post-generation hook

At `bricks/velvet_package/hooks/post_gen.dart`: append `packages/{{package_name}}` to the root `pubspec.yaml` `workspace:` list. Same hook shape as an app brick, targeting `packages/` instead of `programs/`.

To share one hook implementation across app and package bricks, make the target directory a variable (`content_type: packages | plugins | programs`) — a single brick can then serve all three monorepo content types.

## Step 6 — Register in root `mason.yaml`

```yaml
bricks:
  velvet_package:
    path: bricks/velvet_package
```

`mason.yaml` is the only Mason file edited by hand.

## Step 7 — Resolve bricks

```zsh
fvm dart run mason_cli:mason get
```

This regenerates `.mason/bricks.json` and `mason-lock.json`. Nothing in `.mason/` is ever touched manually.

## Step 8 — Generate and verify

```zsh
fvm dart run mason_cli:mason make velvet_package -o packages
fvm dart pub get
melos analyze
```

The first generation is the acceptance test. The generated package must:

- Resolve (`pub get` succeeds against the workspace)
- Analyze clean under `very_good_analysis`
- Pass its placeholder test

...with **zero manual edits**. If it fails: fix the *brick*, delete the generated package, regenerate. Never patch the output.

## Step 9 — Delete or archive the reference package

The brick is now the source of truth. Keeping the Step 1 reference package alongside it means the two drift. Remove it (or archive it outside the repo).

---

## Design guidance

Keep the brick minimal: barrel file, one placeholder source file, one placeholder test. Resist templating framework machinery (Cubits, storage interfaces, etc.) into it — packages diverge immediately after scaffolding, and a fat brick rots. The stable, universal part is the conventions shell; that is what belongs in the template.

## Ownership summary

| File / directory              | Who writes it | Committed? |
| ----------------------------- | ------------- | ---------- |
| `bricks/velvet_package/`      | You           | Yes        |
| `mason.yaml`                  | You           | Yes        |
| `mason-lock.json`             | `mason get`   | Yes        |
| `.mason/`                     | `mason get`   | No         |
| Generated `packages/<name>/`  | `mason make`  | Yes        |
