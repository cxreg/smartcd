# Load testing library
source t/tap-functions
source bash_arrays

plan_tests 19

apush foo 1 2 3
is "$(alen foo)" 3 "created 3 element array"

apush foo "4 5"
is "$(alen foo)" 4 "extended array by one quoted element"
is "$(alast foo)" "4 5" "quoted element is in-tact"

aunshift foo 0
is "$(alen foo)" 5 "unshift extended array"
is "$(afirst foo)" 0 "unshift put element at beginning of array"
is "$(alast foo)" "4 5" "quoted element is still last and still in-tact"

apop foo >/dev/null
is "$(alen foo)" 4 "array shrunk by one element from pop"
is "${_apop_return-_}" "4 5" "got correct element from pop"

ashift foo >/dev/null
is "$(alen foo)" 3 "array shrunk by one element from shift"
is "${_ashift_return-_}" 0 "got correct element from shift"

# reverse
areverse foo
is "$(afirst foo)" 3 "array reversed, last is now first"
is "$(alast foo)" 1 "array reversed, first is now last"

acopy foo bar
is "x${foo[*]}" "x${bar[*]}" "copied array"

is "x$(is_array foo)" "x1" "array detected"
non_array=test
is "x$(is_array non_array)" "x" "non-array detected"

foo=("bar  baz")
is "x$(afirst foo)" "xbar  baz" "afirst works with element with double-space"
is "x$(alast foo)" "xbar  baz" "alast works with element with double-space"
is "x$(apop foo)" "xbar  baz" "apop works with element with double-space"
is "x$(ashift foo)" "xbar  baz" "ashift works with element with double-space"
