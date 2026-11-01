# Command line for creating a flutter app

## CLI

```zsh
flutter create --platforms=android,ios,web,windows,macos,linux --org com.icodeforyou [app name]
```

grep -r -l -F -I \                                                 
  --include="*.dart" \
  --include="*.yaml" \
  --exclude-dir=".git" \
  --exclude-dir=".dart_tool" \
  --exclude-dir="build" \
  "publish_to" . | head -3