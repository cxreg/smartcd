# Load testing library
source t/tap-functions
source bash_varstash

plan_tests 15

thing=value

output=$(stash thing)
like "${output-_}" "You are manually stashing a variable" "manual stash warned"
stash thing>/dev/null
thing=newvalue
varname=$(_mangle_var thing)
is "$(eval echo \$$varname)" value "stashed variable"

output=$(unstash thing)
like "${output-_}" "You are manually unstashing a variable" "manual unstash warned"
unstash thing>/dev/null
is "$thing" value "unstashed variable successfully"
is "_$(eval echo \${$varname-_})_" "___" "stash variable unset"

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

oldhome=$HOME
stash HOME
mkdir tmphome
export HOME=$(pwd)/tmphome

VARSTASH_AUTOCONFIG=1
oldshell=$SHELL
autostash SHELL
config_file=$(find $HOME/.smartcd -name bash_enter)
like "${config_file-_}" "bash_enter" "created smartcd file"
is "$(cat ${config_file-_})" "autostash SHELL" "correctly configured autostash"
SHELL=temp
autounstash
is "$SHELL" "$oldshell" "restored variable"
rm $config_file

VARSTASH_AUTOEDIT=1
EDITOR=cat
output=$(autostash RANDOM_VARIABLE)
is "${output-_}" "autostash RANDOM_VARIABLE" "autoedit seems to work"

VARSTASH_AUTOEDIT=
unstash HOME
is "$HOME" "$oldhome" "restored \$HOME"
rm -rf tmphome
