# Set up smartcd
mkdir -p tmphome
oldhome=$HOME
export HOME="$(pwd)/tmphome"

# Load testing library
source t/tap-functions
source lib/core/arrays
source lib/core/varstash
source lib/core/smartcd

plan_tests 13

# One tier
dir=tmp_dir
mkdir -p "$dir"

echo | smartcd edit enter "$dir"
SMARTCD_QUIET=0
output=$(smartcd cd "$dir")
like "_${output-_}" "_smartcd: running" "smartcd informed user of script execution"
SMARTCD_QUIET=1
output=$(smartcd cd "$dir")
is "_${output-_}_" "__" "quieted output"

cat << EOF | smartcd edit enter "$dir"
echo this is a test
EOF
output=$(smartcd cd "$dir")
is "_$output" "_this is a test" "bash_enter executed successfully using smartcd"

output=$(smartcd pushd "$dir")
like "${output-_}" "this is a test" "bash_enter executed successfully using smartcd pushd"

echo -n | smartcd edit enter "$dir"
cat << EOF | smartcd edit leave "$dir"
echo this is a leaving test
EOF
output=$(smartcd cd "$dir"; smartcd cd ..)
is "${output:-_}" "this is a leaving test" "bash_leave executed successfully using smartcd"

output=$(smartcd pushd "$dir"; smartcd popd)
like "${output-_}" "this is a leaving test" "bash_leave executed successfully using smartcd popd"

# Clean up
echo | smartcd edit enter "$dir"
echo | smartcd edit leave "$dir"

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

dir2="$dir/another_dir"
mkdir -p "$dir2"
echo "echo -n \"1 \"" | smartcd edit enter "$dir"
echo "echo 2" | smartcd edit enter "$dir2"
output=$(smartcd cd "$dir2"; smartcd cd ../..)
is "_${output-_}" "_1 2" "ran two bash_enter scripts in correct order"

# Clean up
echo | smartcd edit enter "$dir"
echo | smartcd edit leave "$dir"
echo | smartcd edit enter "$dir2"
echo | smartcd edit leave "$dir2"

echo "echo 1" | smartcd edit leave "$dir"
echo "echo -n \"2 \"" | smartcd edit leave "$dir2"
output=$(smartcd cd $dir2; smartcd cd ../..)
is "_${output-_}" "_2 1" "ran two bash_leave scripts in correct order"

mkdir deleted_dir
output=$(smartcd cd deleted_dir; rmdir ../deleted_dir; smartcd cd .. 2>&1)
unlike "_$output" "No such file or directory" "smartcd doesn't try to re-enter a deleted directory"


if [[ -n $ZSH_VERSION ]]; then
    echo "echo -n 1" | smartcd edit enter "$dir"
    echo "echo -n 2" | smartcd edit enter "$dir2"
    echo "echo -n 3" | smartcd edit leave "$dir2"
    echo "echo 4" | smartcd edit leave "$dir"
    smartcd setup chpwd-hook
    output=$(cd "$dir2"; cd ../..)
    like "${output:-_}" "1234" "zsh chpwd hook works"
else
    is 1 1 "not running zsh, no chpwd-hook"
fi

# Clean up
rm -rf "$dir"
rm -rf "$dir2"
rm -rf "$spacedir"
rm -rf tmphome
export HOME=$oldhome
