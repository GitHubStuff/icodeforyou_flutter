#!/usr/bin/env zsh
# animated_rail_menu/refactor_test_fix.zsh
#
# Repairs the AnimatedAnimatedRailMenu* damage caused by the previous
# refactor_test.zsh, and re-sorts the import directive block in
# animated_rail_menu_theme_test.dart.
#
# Run from the package root:  zsh refactor_test_fix.zsh
#
# Idempotent: substring AnimatedAnimated -> Animated only fires where present.

set -e
set -u

if [[ ! -f pubspec.yaml ]] || ! grep -q '^name: animated_rail_menu' pubspec.yaml; then
  print -u2 "ERROR: must be run from the animated_rail_menu package root"
  exit 1
fi

print "==> Repairing AnimatedAnimatedRailMenu* identifiers"

for f in $(find test -name '*.dart' -type f); do
  sed -i.bak \
    -e "s|AnimatedAnimatedRailMenuThemeDark|AnimatedRailMenuThemeDark|g" \
    -e "s|AnimatedAnimatedRailMenuThemeLight|AnimatedRailMenuThemeLight|g" \
    -e "s|AnimatedAnimatedRailMenu|AnimatedRailMenu|g" \
    "$f"
  rm -f "${f}.bak"
done

print "==> Sorting directive blocks in theme test"

# Sort the three theme-import directives in the affected test, since the
# substitution changed their alphabetical order.
target="test/src/theme/animated_rail_menu_theme_test.dart"
if [[ -f "$target" ]]; then
  python3 <<PY
import re
from pathlib import Path

p = Path("$target")
text = p.read_text()
lines = text.splitlines(keepends=True)

# Find the contiguous run of import directives starting at the first one.
start = None
end = None
for i, line in enumerate(lines):
    if line.startswith("import "):
        if start is None:
            start = i
        end = i
    elif start is not None and line.strip() == "":
        # blank line within import block — stop
        break
    elif start is not None and not line.startswith("import "):
        break

if start is not None and end is not None and end > start:
    block = lines[start : end + 1]
    block.sort()
    lines[start : end + 1] = block
    p.write_text("".join(lines))
    print(f"  sorted {end - start + 1} imports in {p}")
else:
    print(f"  no import block found in {p}")
PY
fi

print "==> Done."
