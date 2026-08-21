# TLDR

## lcov

lcov report on everything in the mono-repo, automatically {if successful} opens report in browser


```zsh
cd <mono-repo

# for coverage in a <date>.txt file
LOG="$(pwd)/Z_coverage_run_$(date +%Y%m%d_%H%M%S).txt"LOG="$(pwd)/Z_coverage_run_$(date +%Y%m%d_%H%M%S).txt"
print "📝 Log: $LOG"
{
melos test_coverage
melos test_plugin_coverage
melos test_programs_coverage
NO_HTML=true melos coverage_merge_all
lcov \
  --remove coverage/all_lcov.info \
  '*.g.dart' \
  '*.gr.dart' \
  '*.gen.dart' \
  '*.freezed.dart' \
  '*.mocks.dart' \
  '*.config.dart' \
  --output-file coverage/all_lcov.info \
  --ignore-errors empty,inconsistent,format,unused
rm -rf coverage/html
genhtml --ignore-errors source,empty,inconsistent,category coverage/all_lcov.info -o coverage/html
TS=$(date +%s)
find coverage/html -name '*.html' -exec sed -i '' -E "s/(href=\"[^\"#]+\.html)\"/\1?v=${TS}\"/g" {} +
open "file://$(pwd)/coverage/html/index.html"
} > "$LOG" 2>&1 && print "✅ Done" || print "❌ Failed — check $LOG"


# for doing a '% fvm dart pub upgrade' copy/paste:
LOG="$(pwd)/Z_coverage_run_$(date +%Y%m%d_%H%M%S).txt"
print "📝 Log: $LOG"
{
fvm dart pub upgrade
./melos_tool/melos_test test_all packages
./melos_tool/melos_test test_all plugins
./melos_tool/melos_test test_all programs
./melos_tool/melos_audit --local --dependencies --fail-fast
} > "$LOG" 2>&1 && print "✅ Done" || print "❌ Failed — check $LOG"




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
