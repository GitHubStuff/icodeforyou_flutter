# Super command

```zsh
melos clean && \
melos bootstrap && \
melos coverage_clean && \
melos test_coverage && \
melos test_plugin_coverage && \
melos test_programs_coverage && \
melos coverage_merge_all && \
rm -rf coverage/html && \
genhtml coverage/all_lcov.info -o coverage/html && \
TS=$(date +%s) && \
find coverage/html -name '*.html' -exec sed -i '' -E "s/(href=\"[^\"#]+\.html)\"/\1?v=${TS}\"/g" {} + && \
open "file://$(pwd)/coverage/html/index.html"

melos list --json | jq '.[] | {name: .name, description: .description, version: .version}'
```
