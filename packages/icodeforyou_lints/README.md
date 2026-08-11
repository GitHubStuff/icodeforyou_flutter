# icodeforyou_lints

The only purpose of this package is to have single/unified pointer to common linter for all other
packages and programs.

There is no code just an 'analysis_options.yam' in the /lib that can be used by any package/program/plugin by
including

```yaml
dependencies:
   :
  icodeforyou_lints: ^1.0.0
   :
```

in the ```pubspec.yaml``` file.