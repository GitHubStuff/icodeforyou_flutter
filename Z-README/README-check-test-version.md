# Finding the `test` version your Flutter SDK allows

`flutter_test` (shipped inside the Flutter SDK) pins `test_api` to an exact
version. `test` and `test_api` are released in lockstep, so the Flutter SDK
dictates the highest `test` the workspace can resolve. If any package in the
monorepo asks for a newer `test`, the whole Melos/pub-workspace solve fails
with "version solving failed" and names a random Flutter package as the
culprit — the real cause is the SDK pin.

Run everything from the monorepo root.

## 1. Confirm which Flutter SDK is pinned

```bash
cat .fvmrc
fvm flutter --version
```

## 2. See which `test_api` that SDK pins

```bash
grep test_api .fvm/flutter_sdk/packages/flutter_test/pubspec.yaml
```

*Patch releases of Flutter do not bump this pin; only minor/major releases do.*

## 3. Let the solver pick the `test` version

In the offending package's `pubspec.yaml` (last time: `template_dart`), set:

```yaml
  test: any
```

Then resolve the workspace:

```bash
melos bootstrap
```

## 4. Read the resolved version from the root lockfile

```bash
grep -A8 '^  test:' pubspec.lock
```

Look for the `version:` line near the bottom of the block.

## 5. Pin the package to that version

Replace `test: any` in the same `pubspec.yaml` with a caret on the resolved
version, e.g.:

```yaml
  test: ^1.31.1
```

To get a list of what versions of "test: ^?.?.?" is in the mono repo:

```zsh
 find . -name pubspec.yaml -not -path '*/.*' -not -path '*/build/*' -exec grep -Hn -E '^ *test: ' {} +
```
Edit any other packages, programs,... to put in the latest/greatest version

Then rebuild the workspace from scratch to confirm:

```bash
melos clean && melos bootstrap
```

## Do not

- Add a `dependency_overrides` entry for `test_api`. `flutter_test` pins it
  exactly because its internals track `test_api`'s internals; overriding it
  makes pub stop complaining while handing you a mismatched test harness.

## Last known result (Flutter 3.47.8, 2026-10-25)

| Flutter | test_api pin | highest `test` |
| ------- | ------------ | -------------- |
| 3.47.8  | 0.7.12       | 1.31.1         |