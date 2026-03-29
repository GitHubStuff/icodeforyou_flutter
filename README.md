# Super command

```zsh
melos clean && melos bootstrap && melos coverage_clean && melos test_coverage && melos test_programs_coverage && melos coverage_merge_all

melos list --json | jq '.[] | {name: .name, description: .description, version: .version}'
```
