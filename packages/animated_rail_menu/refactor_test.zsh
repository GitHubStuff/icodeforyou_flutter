#!/usr/bin/env zsh
# animated_rail_menu/refactor_test.zsh
#
# Renames and rewrites test/ files to match the AnimatedRailMenu* naming.
# Also patches a stray unnecessary import in lib/.
#
# Run from the package root:  zsh refactor_test.zsh
#
# Idempotent: safe to re-run. Only renames files when the source filename
# still uses the old naming.

set -e
set -u

if [[ ! -f pubspec.yaml ]] || ! grep -q '^name: animated_rail_menu' pubspec.yaml; then
  print -u2 "ERROR: must be run from the animated_rail_menu package root"
  exit 1
fi

print "==> Patching lib/ — removing stray unnecessary import"
# Remove the unused 'package:flutter/services.dart' import from the widget
# library (HapticIntensity comes from package:extensions).
if [[ -f lib/src/widget/animated_rail_menu_widget.dart ]]; then
  sed -i.bak "/^import 'package:flutter\/services.dart';$/d" \
    lib/src/widget/animated_rail_menu_widget.dart
  rm -f lib/src/widget/animated_rail_menu_widget.dart.bak
fi

print "==> Refactoring test/"

# ---------------------------------------------------------------------------
# 1. Rename files (only if old name still exists)
# ---------------------------------------------------------------------------
print "  - renaming test files"

typeset -A renames
renames=(
  test/src/cubit/rail_menu_cubit_test.dart    test/src/cubit/animated_rail_menu_cubit_test.dart
  test/src/cubit/rail_menu_state_test.dart    test/src/cubit/animated_rail_menu_state_test.dart
  test/src/model/rail_menu_entry_test.dart    test/src/model/animated_rail_menu_entry_test.dart
  test/src/theme/rail_menu_theme_test.dart    test/src/theme/animated_rail_menu_theme_test.dart
  test/src/widget/more_inline_button_test.dart test/src/widget/more_inline_button_test.dart
  test/src/widget/rail_navigation_adaptive_test.dart      test/src/widget/animated_rail_menu_adaptive_test.dart
  test/src/widget/rail_navigation_animated_test.dart      test/src/widget/animated_rail_menu_animated_test.dart
  test/src/widget/rail_navigation_corner_radius_test.dart test/src/widget/animated_rail_menu_corner_radius_test.dart
  test/src/widget/rail_navigation_haptic_test.dart        test/src/widget/animated_rail_menu_haptic_test.dart
  test/src/widget/rail_navigation_horizontal_test.dart    test/src/widget/animated_rail_menu_horizontal_test.dart
  test/src/widget/rail_navigation_overflow_test.dart      test/src/widget/animated_rail_menu_overflow_test.dart
  test/src/widget/rail_navigation_safe_area_test.dart     test/src/widget/animated_rail_menu_safe_area_test.dart
  test/src/widget/rail_navigation_theme_test.dart         test/src/widget/animated_rail_menu_theme_widget_test.dart
  test/src/widget/rail_navigation_vertical_test.dart      test/src/widget/animated_rail_menu_vertical_test.dart
)

for old new in ${(kv)renames}; do
  if [[ "$old" != "$new" && -f "$old" ]]; then
    mv "$old" "$new"
  fi
done

# ---------------------------------------------------------------------------
# 2. Rewrite content of all test files
# ---------------------------------------------------------------------------
print "  - rewriting test file contents"

# Find every test file and apply the substitutions.
# Order matters: longer/more-specific patterns first so prefixes don't shadow.
for f in $(find test -name '*.dart' -type f | sort); do
  sed -i.bak \
    -e "s|package:animated_rail_menu/src/cubit/rail_menu_cubit\.dart|package:animated_rail_menu/src/cubit/animated_rail_menu_cubit.dart|g" \
    -e "s|package:animated_rail_menu/src/cubit/rail_menu_state\.dart|package:animated_rail_menu/src/cubit/animated_rail_menu_state.dart|g" \
    -e "s|package:animated_rail_menu/src/cubit/rail_menu_controller\.dart|package:animated_rail_menu/src/cubit/animated_rail_menu_controller.dart|g" \
    -e "s|package:animated_rail_menu/src/model/rail_menu_entry\.dart|package:animated_rail_menu/src/model/animated_rail_menu_entry.dart|g" \
    -e "s|package:animated_rail_menu/src/theme/_rail_menu_theme_dark\.dart|package:animated_rail_menu/src/theme/animated_rail_menu_theme_dark.dart|g" \
    -e "s|package:animated_rail_menu/src/theme/_rail_menu_theme_light\.dart|package:animated_rail_menu/src/theme/animated_rail_menu_theme_light.dart|g" \
    -e "s|package:animated_rail_menu/src/theme/rail_menu_theme\.dart|package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart|g" \
    -e "s|RailMenuThemeDark|AnimatedRailMenuThemeDark|g" \
    -e "s|RailMenuThemeLight|AnimatedRailMenuThemeLight|g" \
    -e "s|RailMenuTheme|AnimatedRailMenuTheme|g" \
    -e "s|RailMenuController|AnimatedRailMenuController|g" \
    -e "s|RailMenuCubit|AnimatedRailMenuCubit|g" \
    -e "s|RailMenuState|AnimatedRailMenuState|g" \
    -e "s|RailMenuEntry|AnimatedRailMenuEntry|g" \
    -e "s|RailNavigationWidget|AnimatedRailMenu|g" \
    "$f"
  rm -f "${f}.bak"
done

# ---------------------------------------------------------------------------
# 3. Replace path-comment headers with the new filename
# ---------------------------------------------------------------------------
print "  - normalising path-comment headers"

for f in $(find test -name '*.dart' -type f | sort); do
  # Replace the entire first-line comment if it starts with "// " and ends in ".dart".
  if head -n 1 "$f" | grep -qE '^// .*\.dart\s*$'; then
    sed -i.bak "1c\\
// animated_rail_menu/$f
" "$f"
    rm -f "${f}.bak"
  fi
done

print "==> Done."
print ""
print "Files in test/:"
find test -name '*.dart' -type f | sort | sed 's/^/  /'
