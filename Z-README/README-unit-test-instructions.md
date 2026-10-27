# Unit Test instructions

How to build/complete testing

## Complete test coverage


```zshz
# writes package test to console
./melos_tool/melos_test test_coverage packages

# writes package test to file
./melos_tool/melos_test test_coverage packages > test_coverage.log 2>&1
```

When the test completes and if no errors are reported, to generate
and display the HTML report

```zsh
./melos_tool/melos_test coverage_merge_all
```
