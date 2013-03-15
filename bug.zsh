#!/usr/bin/zsh -if

mkdir -p a b

source ~/dotfiles/smartcd/lib/core/arrays
source ~/dotfiles/smartcd/lib/core/varstash
source ~/dotfiles/smartcd/lib/core/smartcd
smartcd setup chpwd-hook

(
cd -q a
echo 'echo A' | smartcd edit enter
)

(
cd -q b
echo 'echo B' | smartcd edit enter
)

# Expected output: Output of hooks of a and b
# Current output: Output of hook of a, but no further hooks
cd a
cd ..
cd b
cd ..
