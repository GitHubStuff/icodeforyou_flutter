# TLDR

## lcov

lcov report on everything in the mono-repo, automatically {if successful} opens report in browser


```zsh
cd <mono-repo root>

LOG="$(pwd)/Z_coverage_run_$(date +%Y%m%d_%H%M%S).txt" && \
print "📝 Log: $LOG" && \
{
  melos test_coverage && \
  melos test_plugin_coverage && \
  melos test_programs_coverage && \
  NO_HTML=true melos coverage_merge_all && \
  rm -rf coverage/html && \
  genhtml --ignore-errors source,empty,inconsistent,category coverage/all_lcov.info -o coverage/html && \
  TS=$(date +%s) && \
  find coverage/html -name '*.html' -exec sed -i '' -E "s/(href=\"[^\"#]+\.html)\"/\1?v=${TS}\"/g" {} + && \
  open "file://$(pwd)/coverage/html/index.html"
} > "$LOG" 2>&1 && \
print "✅ Done" || print "❌ Failed — check $LOG"








melos clean && \
melos bootstrap && \
melos coverage_clean && \
melos test_coverage && \
melos test_plugin_coverage && \
melos test_programs_coverage && \
NO_HTML=true melos coverage_merge_all && \
rm -rf coverage/html && \
genhtml --ignore-errors source,empty,inconsistent,category coverage/all_lcov.info -o coverage/html && \
TS=$(date +%s) && \
find coverage/html -name '*.html' -exec sed -i '' -E "s/(href=\"[^\"#]+\.html)\"/\1?v=${TS}\"/g" {} + && \
open "file://$(pwd)/coverage/html/index.html"





melos clean && \
melos bootstrap && \
melos coverage_clean && \
melos test_coverage && \
melos test_plugin_coverage && \
melos test_programs_coverage && \
melos coverage_merge_all && \
rm -rf coverage/html && \
genhtml --ignore-errors source,empty,inconsistent,category coverage/all_lcov.info -o coverage/html && \
TS=$(date +%s) && \
find coverage/html -name '*.html' -exec sed -i '' -E "s/(href=\"[^\"#]+\.html)\"/\1?v=${TS}\"/g" {} + && \
open "file://$(pwd)/coverage/html/index.html"

melos list --json | jq '.[] | {name: .name, description: .description, version: .version}'
```
