# Help-full GREP commands

## Finding folders in and down the current tree

```zsh
grep -r -l \
  --include="*.dart" \
  --include="*.yaml" \
  --exclude-dir=".git" \
  --exclude-dir=".dart_tool" \
  --exclude-dir="build" \
  "[Search String]" .
```

