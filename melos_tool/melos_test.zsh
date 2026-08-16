#!/usr/bin/env zsh
# melos_tool/melos_test.zsh
# Unified test/coverage runner for the icodeforyou_flutter monorepo.
# Version: 1.3.0
#
# Usage:
#   melos_test.zsh test_one      <category> <name>   — single package/plugin/program
#   melos_test.zsh test_all      <category>          — all in category, sequential
#   melos_test.zsh test_coverage <category>          — coverage for all in category
#   melos_test.zsh coverage_merge <category>         — merge LCOV for category
#   melos_test.zsh coverage_merge_all                — merge LCOV across everything
#   melos_test.zsh coverage_clean                    — wipe all coverage data
#
# Categories: packages | plugins | programs
# Env flags:  STRICT=true  → fail-fast on first package failure (test_all only)
#
# 1.3.0 — coverage completeness and SDK pinning:
#   * Pure Dart packages now produce coverage/lcov.info. `dart test
#     --coverage=coverage` emits only VM JSON, which the merge steps never
#     saw, so every non-Flutter package silently contributed zero lines to
#     the workspace reports. VM JSON is now converted via
#     coverage:format_coverage. One-time setup:
#       fvm dart pub global activate coverage
#   * All flutter/dart invocations now go through fvm, so tests always run
#     against the project-pinned SDK instead of whatever is first on PATH.
#   * run_tests_in_dir aborts if `cd` into the package fails, rather than
#     running the test command from the workspace root — the exact working-
#     directory condition that produces "Undefined name 'main'" listener
#     errors.
#
# 1.2.0 — lcov 2.x compatibility:
#   * Dart/Flutter lcov.info files carry line records only (no FN:/FNDA:).
#     lcov 2.x enables function-coverage processing by default and hard-fails
#     with "(empty) function coverage enabled but no corresponding coverpoints"
#     on every merge. All lcov/genhtml invocations now pass the appropriate
#     --ignore-errors categories.
#   * Genuinely empty tracefiles (a package whose tests failed to load) are
#     skipped with a warning instead of aborting the merge, so one broken
#     package can no longer torpedo the workspace report.
#   * Merge failures are surfaced per-file instead of silently discarding
#     the remainder of the tracefile list.

set -uo pipefail

readonly ACTION="${1:-}"
readonly VALID_CATEGORIES=(packages plugins programs)

# lcov 2.x error categories that Dart tracefiles legitimately trigger:
#   empty        — function coverage enabled, zero FN records (every Dart file)
#   inconsistent — minor record-count mismatches across merged files
#   format       — tolerant parsing of older tracefile dialects
#   unused       — --remove patterns that match nothing
readonly LCOV_IGNORE="empty,inconsistent,format,unused"
# genhtml 2.x raises its own variants on function-less tracefiles.
readonly GENHTML_IGNORE="source,empty,inconsistent,category"

# ─── helpers ────────────────────────────────────────────────────────────────
validate_category() {
  local cat="$1"
  if (( ! ${VALID_CATEGORIES[(Ie)$cat]} )); then
    print -u2 "❌ Invalid category '$cat' (expected: ${VALID_CATEGORIES[*]})"
    exit 64
  fi
}

# Echoes "flutter" or "dart" depending on the package's pubspec.
detect_runner() {
  local dir="$1"
  if grep -q "^[[:space:]]*flutter:" "${dir}/pubspec.yaml" 2>/dev/null; then
    print "flutter"
  else
    print "dart"
  fi
}

# Convert Dart VM coverage JSON into coverage/lcov.info so the merge steps
# can see pure Dart packages. Runs from inside the package directory.
# Requires package:coverage — one-time setup:
#   fvm dart pub global activate coverage
convert_dart_coverage() {
  print "🔁 Converting VM coverage JSON → coverage/lcov.info"
  if ! fvm dart pub global run coverage:format_coverage \
      --lcov \
      --in=coverage \
      --out=coverage/lcov.info \
      --report-on=lib; then
    print -u2 "⚠️  lcov conversion failed. Is package:coverage activated?"
    print -u2 "   Run once: fvm dart pub global activate coverage"
    return 1
  fi
}

# Run tests in a single directory. Args: <dir> [--coverage]
run_tests_in_dir() {
  local dir="$1"
  local with_coverage="${2:-}"
  local runner
  runner=$(detect_runner "$dir")

  if ! cd "$dir"; then
    print -u2 "❌ Could not enter ${dir} — aborting rather than testing from the wrong directory"
    return 1
  fi

  local rc=0
  if [[ "$runner" == "flutter" ]]; then
    print "🦋 Flutter package — running fvm flutter test"
    if [[ "$with_coverage" == "--coverage" ]]; then
      fvm flutter test --coverage
      rc=$?
    else
      fvm flutter test
      rc=$?
    fi
  else
    print "🎯 Dart package — running fvm dart test"
    if [[ "$with_coverage" == "--coverage" ]]; then
      fvm dart test --coverage=coverage
      rc=$?
      if (( rc == 0 )); then
        convert_dart_coverage
        rc=$?
      fi
    else
      fvm dart test
      rc=$?
    fi
  fi

  cd - > /dev/null
  return $rc
}

# ─── actions ────────────────────────────────────────────────────────────────

action_test_one() {
  local category="$1"
  local name="${2:-}"

  validate_category "$category"

  if [[ -z "$name" ]]; then
    print -u2 "❌ Name not set."
    case "$category" in
      packages) print -u2 "   Usage: PKG=package_name melos test_package" ;;
      plugins)  print -u2 "   Usage: PRG=plugin_name melos test_plugin" ;;
      programs) print -u2 "   Usage: PRG=program_name melos test_program" ;;
    esac
    exit 1
  fi

  local target_dir="${category}/${name}"

  [[ -d "$target_dir" ]] || { print -u2 "❌ '${name}' not found at ${target_dir}"; exit 1; }
  [[ -d "${target_dir}/test" ]] || { print -u2 "❌ No test directory found in ${target_dir}"; exit 1; }

  print ""
  print "📦 Testing ${name}..."
  run_tests_in_dir "$target_dir" --coverage
  local rc=$?
  print ""
  if (( rc == 0 )); then
    print "✅ Done: ${name}"
  else
    print "❌ Failed: ${name}"
  fi
  return $rc
}

action_test_all() {
  local category="$1"
  validate_category "$category"

  print "🧪 Running tests sequentially to avoid Flutter lock conflicts..."
  [[ "${STRICT:-}" == "true" ]] && print "⚠️  STRICT mode — stopping on first failure"

  local failed_items=""
  local total=0
  local tested=0

  for target_dir in ${category}/*/; do
    local name=$(basename "$target_dir")

    if [[ -d "${target_dir}test" ]]; then
      print ""
      print "📦 Testing ${name}..."
      total=$((total + 1))
      tested=$((tested + 1))

      if ! run_tests_in_dir "${target_dir%/}"; then
        print "❌  Tests failed in ${name}"
        if [[ "${STRICT:-}" == "true" ]]; then
          print ""
          print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          print "🛑 STRICT mode — stopping at ${name}"
          print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          exit 1
        fi
        if [[ -z "$failed_items" ]]; then
          failed_items="$name"
        else
          failed_items="$failed_items, $name"
        fi
      fi
    else
      print "⏭️  Skipping ${name} (no test directory)"
      total=$((total + 1))
    fi
  done

  print ""
  print "✅ Test run completed!"
  print ""
  print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print "📊 SUMMARY (${category})"
  print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print "Total:  ${total}"
  print "Tested: ${tested}"

  if [[ -n "$failed_items" ]]; then
    print "❌ FAILED: ${failed_items}"
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
  else
    print "✅ All tests passed!"
    print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
}

action_test_coverage() {
  local category="$1"
  validate_category "$category"

  print "🧪 Running coverage tests for ${category}..."
  for target_dir in ${category}/*/; do
    local name=$(basename "$target_dir")

    if [[ -d "${target_dir}test" ]]; then
      print ""
      print "📦 Testing ${name}..."
      run_tests_in_dir "${target_dir%/}" --coverage || true
    else
      print "⏭️  Skipping ${name} (no test directory)"
    fi
  done
  print "✅ Coverage generation completed for all ${category}!"
}

# Internal: merge a list of lcov files into one output, with optional excludes.
# Args: <output_file> <html_dir> <find_path_glob> <not_path_glob> [exclude_patterns...]
#   not_path_glob: pass "" to skip path exclusion
_merge_coverage() {
  local output_file="$1"
  local html_dir="$2"
  local find_path="$3"
  local not_path="$4"
  shift 4
  local -a excludes=("$@")

  mkdir -p coverage
  rm -f "$output_file"

  local coverage_files
  if [[ -n "$not_path" ]]; then
    coverage_files=$(find . -path "./coverage" -prune -o \
      -name "lcov.info" -path "$find_path" -not -path "$not_path" -print)
  else
    coverage_files=$(find . -path "./coverage" -prune -o \
      -name "lcov.info" -path "$find_path" -print)
  fi

  if [[ -z "$coverage_files" ]]; then
    print "❌ No coverage files found matching: $find_path"
    print "   Run the corresponding test_coverage script first."
    return 1
  fi

  print "Found coverage files:"
  print "$coverage_files"

  local skipped_items=""
  local merged_count=0

  while IFS= read -r lcov_file; do
    [[ -z "$lcov_file" ]] && continue
    local source_path
    source_path=$(print -- "$lcov_file" | sed 's|^\./||' | sed 's|/coverage/lcov\.info$||')

    # A package whose tests failed to load produces an empty lcov.info.
    # Skip it with a warning rather than letting lcov abort the merge.
    if [[ ! -s "$lcov_file" ]]; then
      print "⚠️  Skipping ${source_path} — empty tracefile (tests likely failed to load)"
      if [[ -z "$skipped_items" ]]; then
        skipped_items="$source_path"
      else
        skipped_items="$skipped_items, $source_path"
      fi
      continue
    fi

    print "Processing coverage for ${source_path}..."

    local temp_file="coverage/temp_$(print -- "$source_path" | tr '/' '_').info"
    sed "s|SF:lib/|SF:${source_path}/lib/|g" "$lcov_file" > "$temp_file"

    if [[ -f "$output_file" ]]; then
      if lcov --ignore-errors "$LCOV_IGNORE" \
          --add-tracefile "$output_file" \
          --add-tracefile "$temp_file" \
          --output-file "$output_file"; then
        merged_count=$((merged_count + 1))
      else
        print "⚠️  Merge failed for ${source_path} — skipping this tracefile"
        if [[ -z "$skipped_items" ]]; then
          skipped_items="$source_path"
        else
          skipped_items="$skipped_items, $source_path"
        fi
      fi
    else
      cp "$temp_file" "$output_file"
      merged_count=$((merged_count + 1))
    fi

    rm "$temp_file"
  done <<< "$coverage_files"

  if (( merged_count == 0 )); then
    print "❌ No tracefiles could be merged."
    return 1
  fi

  if (( ${#excludes[@]} > 0 )); then
    lcov --ignore-errors "$LCOV_IGNORE" \
      --remove "$output_file" "${excludes[@]}" \
      --output-file "$output_file"
  fi

  genhtml --ignore-errors "$GENHTML_IGNORE" "$output_file" -o "$html_dir"
  print "✅ Merged coverage report: ${html_dir}/index.html"
  print "   Tracefiles merged: ${merged_count}"
  if [[ -n "$skipped_items" ]]; then
    print "⚠️  Skipped: ${skipped_items}"
  fi

  if [[ -f "${html_dir}/index.html" ]]; then
    open "${html_dir}/index.html"
  else
    print "⚠️  HTML file wasn't created"
    lcov --ignore-errors "$LCOV_IGNORE" --summary "$output_file"
  fi
}

action_coverage_merge() {
  local category="$1"
  validate_category "$category"

  case "$category" in
    packages)
      _merge_coverage \
        "coverage/lcov.info" \
        "coverage/html" \
        "*/packages/*/coverage/lcov.info" \
        "" \
        '*/lib/src/_app_settings_entry.dart'
      ;;
    plugins)
      _merge_coverage \
        "coverage/plugins_lcov.info" \
        "coverage/plugins_html" \
        "*/plugins/*/coverage/lcov.info" \
        ""
      ;;
    programs)
      _merge_coverage \
        "coverage/programs_lcov.info" \
        "coverage/programs_html" \
        "*/programs/*/coverage/lcov.info" \
        ""
      ;;
  esac
}

action_coverage_merge_all() {
  _merge_coverage \
    "coverage/all_lcov.info" \
    "coverage/all_html" \
    "*/coverage/lcov.info" \
    "*/widgetbook_workspace/*" \
    '*/lib/src/_app_settings_entry.dart'
}

action_coverage_clean() {
  rm -rf coverage/
  find . -name "coverage" -type d -not -path "./coverage" -exec rm -rf {} +
  print "🧹 Coverage data cleaned from entire workspace"
}

# ─── dispatch ───────────────────────────────────────────────────────────────
case "$ACTION" in
  test_one)            action_test_one "${2:-}" "${3:-}" ;;
  test_all)            action_test_all "${2:-}" ;;
  test_coverage)       action_test_coverage "${2:-}" ;;
  coverage_merge)      action_coverage_merge "${2:-}" ;;
  coverage_merge_all)  action_coverage_merge_all ;;
  coverage_clean)      action_coverage_clean ;;
  "")
    print -u2 "Usage: $0 <action> [category] [name]"
    print -u2 "  actions: test_one | test_all | test_coverage | coverage_merge | coverage_merge_all | coverage_clean"
    exit 64
    ;;
  *)
    print -u2 "❌ Unknown action: $ACTION"
    exit 64
    ;;
esac