# Load testing library
source t/tap-functions
source bash_arrays
source bash_varstash
source bash_smartcd

plan_tests 10

# Set up smartcd
mkdir -p tmphome
oldhome=$HOME
export HOME=$(pwd)/tmphome

# One tier
dir=tmp_dir
mkdir -p $dir
smartcd_dir=$HOME/.smartcd$(pwd)/$dir
mkdir -p $smartcd_dir

echo -n >$smartcd_dir/bash_enter
output=$(smartcd $dir)
like "${output-_}" "smartcd: running" "smartcd informed user of script execution"
SMARTCD_QUIET=1
output=$(smartcd $dir)
is "_${output-_}_" "__" "quieted output"

cat >$smartcd_dir/bash_enter <<EOF
echo this is a test
EOF
output=$(smartcd $dir)
is "${output-_}" "this is a test" "bash_enter executed successfully using smartcd"

output=$(smartpushd $dir)
like "${output-_}" "this is a test" "bash_enter executed successfully using smartpushd"

rm $smartcd_dir/bash_enter
cat >$smartcd_dir/bash_leave <<EOF
echo this is a leaving test
EOF
output=$(smartcd $dir; smartcd ..)
is "${output-_}" "this is a leaving test" "bash_leave executed successfully using smartcd"

output=$(smartpushd $dir; smartpopd)
like "${output-_}" "this is a leaving test" "bash_leave executed successfully using smartpopd"

spacedir="dir with a space"
mkdir -p "$spacedir"
smartcd_spacedir="$HOME/.smartcd$(pwd)/$spacedir"
mkdir -p "$smartcd_spacedir"
echo 'echo -n "1 "' > "$smartcd_spacedir/bash_enter"
echo 'echo 2' > "$smartcd_spacedir/bash_leave"
output=$(smartcd "$spacedir"; smartcd ..)
is "${output-_}" "1 2" "could enter and leave a directory with a space"

echo 'echo 4' > "$smartcd_spacedir/bash_leave"
spacedir="dir with a space/subdir"
mkdir -p "$spacedir"
smartcd_spacedir="$HOME/.smartcd$(pwd)/$spacedir"
mkdir -p "$smartcd_spacedir"
echo 'echo -n "2 "' > "$smartcd_spacedir/bash_enter"
echo 'echo -n "3 "' > "$smartcd_spacedir/bash_leave"
output=$(smartcd "$spacedir"; smartcd ../..)
is "${output-_}" "1 2 3 4" "could enter and leave a subdirectory of a directory with a space"

dir2=$dir/another_dir
smartcd_dir2=$smartcd_dir/another_dir
mkdir -p $dir2
mkdir -p $smartcd_dir2
rm $smartcd_dir/bash_leave
echo "echo -n \"1 \"" > $smartcd_dir/bash_enter
echo "echo 2" > $smartcd_dir2/bash_enter
output=$(smartcd $dir2; smartcd ../..)
is "${output-_}" "1 2" "ran two bash_enter scripts in correct order"

rm $smartcd_dir/bash_enter
rm $smartcd_dir2/bash_enter
echo "echo 1" > $smartcd_dir/bash_leave
echo "echo -n \"2 \"" > $smartcd_dir2/bash_leave
output=$(smartcd $dir2; smartcd ../..)
is "${output-_}" "2 1" "ran two bash_leave scripts in correct order"

# Clean up
rm -rf $dir
rm -rf "$spacedir"
rm -rf tmphome
export HOME=$oldhome
