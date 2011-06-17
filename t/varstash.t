# Load testing library
source t/tap-functions
source bash_varstash
source bash_arrays

plan_tests 27

thing=value

output=$(stash thing)
like "${output-_}" "You are manually stashing a variable" "manual stash warned"
stash thing>/dev/null
export thing=newvalue
varname=__varstash_variable__$(_mangle_var thing)
is "_$(eval echo \$$varname)" _value "stashed variable"

output=$(unstash thing)
like "${output-_}" "You are manually unstashing a variable" "manual unstash warned"
unstash thing>/dev/null
is "$thing" value "unstashed variable successfully"
is "_$(eval echo \${$varname-_})_" "___" "stash variable unset"
declare="$(declare -p thing)"
unlike "${declare-_}" "-x" "unexported on unstash"

unstash thing>/dev/null
is "$thing" value "double unstash did not delete value"

output=$(autostash thing)
like "${output-_}" "You are manually autostashing a variable" "manual autostash warned"
autostash thing>/dev/null
thing=newvalue
autounstash>/dev/null
is "${thing-_}" value "autounstashed variable successfully"
is "_$(eval echo \${$varname-_})_" "___" "stash variable unset"
autostash_var=$(_mangle_var AUTOSTASH)
is "_$(eval echo \${$autostash_var-_})_" "___" "autostash variable unset"

VARSTASH_QUIET=1
output=$(stash thing)
like "_${output}_" "__" "quieted warning"

stash thing=newvalue
is "${thing-_}" "newvalue" "stash-assigned value"
unstash thing
is "${thing-_}" "value" "could unstash from stash-assignment"
autostash thing=newvalue
is "${thing-_}" "newvalue" "autostash-assigned value"
autounstash thing
is "${thing-_}" "value" "could unstash from autostash-assignment"

stash thing='complex"value(with) lots of"strange"things'
is "${thing-_}" 'complex"value(with) lots of"strange"things' "could stash-assign complex quoted expression"
unstash thing

export thing
stash thing
unset thing
unstash thing
declare=$(declare -p thing)
like "${declare-_}" "-x" "variable exported on unstash"

alias test_cmd="echo test alias"
function test_cmd() { echo "test function"; }
stash test_cmd
alias test_cmd="echo broken alias"
function test_cmd() { echo "broken function"; }
unstash test_cmd
output=$(alias test_cmd)
like "${output-_}" "test alias" "unstashed alias"
unalias test_cmd
output=$(test_cmd)
is "${output-_}" "test function" "unstashed function at the same time as alias"

thing=(one two "three four")
stash thing
thing="not an array"
unstash thing
is "_$(alast thing)" "_three four" "unstashed array"

oldhome=$HOME
stash HOME
mkdir -p tmphome
export HOME=$(pwd)/tmphome

VARSTASH_AUTOCONFIG=1
oldshell=$SHELL
autostash SHELL
config_file="$HOME/.smartcd$(pwd)/bash_enter"
config_file_exists=$([[ -f $config_file ]] && echo "yes")

like "${config_file_exists-_}" "yes" "created smartcd file"
is "$(cat ${config_file-_})" "autostash SHELL" "correctly configured autostash"
SHELL=temp
autounstash
is "$SHELL" "$oldshell" "restored variable"
rm $config_file

VARSTASH_AUTOEDIT=1
EDITOR=cat
output=$(autostash RANDOM_VARIABLE)
is "${output-_}" "smartcd not loaded, cannot run smartcd_edit" "warns user when smartcd not loaded"

source bash_smartcd
rm $config_file
output=$(autostash RANDOM_VARIABLE)
is "${output-_}" "autostash RANDOM_VARIABLE" "autoedit seems to work"

VARSTASH_AUTOEDIT=
unstash HOME
is "$HOME" "$oldhome" "restored \$HOME"
rm -rf tmphome
