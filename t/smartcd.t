# Set up smartcd
mkdir -p tmphome
oldhome=$HOME
export HOME=$(pwd)/tmphome

# Load testing library
source t/tap-functions
source bash_arrays
source bash_varstash
source bash_smartcd

plan_tests 12

# One tier
dir=tmp_dir
mkdir -p $dir
smartcd_dir=$HOME/.smartcd/scripts$(pwd)/$dir
mkdir -p $smartcd_dir

echo -n >$smartcd_dir/bash_enter
output=$(smartcd cd $dir)
like "${output-_}" "smartcd: running" "smartcd informed user of script execution"
SMARTCD_QUIET=1
output=$(smartcd cd $dir)
is "_${output-_}_" "__" "quieted output"

cat >$smartcd_dir/bash_enter <<EOF
echo this is a test
EOF
output=$(smartcd cd $dir)
is "_$output" "_this is a test" "bash_enter executed successfully using smartcd"

output=$(smartcd pushd $dir)
like "${output-_}" "this is a test" "bash_enter executed successfully using smartcd pushd"

rm $smartcd_dir/bash_enter
cat >$smartcd_dir/bash_leave <<EOF
echo this is a leaving test
EOF
output=$(smartcd cd $dir; smartcd cd ..)
is "${output-_}" "this is a leaving test" "bash_leave executed successfully using smartcd"

output=$(smartcd pushd $dir; smartcd popd)
like "${output-_}" "this is a leaving test" "bash_leave executed successfully using smartcd popd"
rm $smartcd_dir/bash_leave

linkdest="$(pwd)/$dir/destination"
link="$dir/symlink"
mkdir -p "$linkdest"
ln -s destination "$link"
smartcd cd -P $link
is "_$(pwd)" "_$linkdest" "cd -P still works"
smartcd cd ../..

spacedir="dir with a space"
mkdir -p "$spacedir"
smartcd_spacedir="$HOME/.smartcd/scripts$(pwd)/$spacedir"
mkdir -p "$smartcd_spacedir"
echo 'echo -n "1 "' > "$smartcd_spacedir/bash_enter"
echo 'echo 2' > "$smartcd_spacedir/bash_leave"
output=$(smartcd cd "$spacedir"; smartcd cd ..)
is "${output-_}" "1 2" "could enter and leave a directory with a space"

echo 'echo 4' > "$smartcd_spacedir/bash_leave"
spacedir2="dir with a space/subdir"
mkdir -p "$spacedir2"
smartcd_spacedir2="$HOME/.smartcd/scripts$(pwd)/$spacedir2"
mkdir -p "$smartcd_spacedir2"
echo 'echo -n "2 "' > "$smartcd_spacedir2/bash_enter"
echo 'echo -n "3 "' > "$smartcd_spacedir2/bash_leave"
output=$(smartcd cd "$spacedir2"; smartcd cd ../..)
is "${output-_}" "1 2 3 4" "could enter and leave a subdirectory of a directory with a space"

dir2=$dir/another_dir
smartcd_dir2=$smartcd_dir/another_dir
mkdir -p $dir2
mkdir -p $smartcd_dir2
echo "echo -n \"1 \"" > $smartcd_dir/bash_enter
echo "echo 2" > $smartcd_dir2/bash_enter
output=$(smartcd cd $dir2; smartcd cd ../..)
is "_${output-_}" "_1 2" "ran two bash_enter scripts in correct order"

rm $smartcd_dir/bash_enter
rm $smartcd_dir2/bash_enter
echo "echo 1" > $smartcd_dir/bash_leave
echo "echo -n \"2 \"" > $smartcd_dir2/bash_leave
output=$(smartcd cd $dir2; smartcd cd ../..)
is "_${output-_}" "_2 1" "ran two bash_leave scripts in correct order"

mkdir deleted_dir
output=$(smartcd cd deleted_dir; rmdir ../deleted_dir; smartcd cd .. 2>&1)
unlike "_$output" "No such file or directory" "smartcd doens't try to re-enter a deleted directory"

# Clean up
rm -rf $dir
rm -rf "$spacedir"
rm -rf tmphome
export HOME=$oldhome
