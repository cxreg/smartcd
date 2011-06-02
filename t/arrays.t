# Load testing library
source t/tap-functions
source bash_arrays

plan_tests 12

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
