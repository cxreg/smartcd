#!/bin/sh
#
# Naive setup script, that makes broad assumptions about your shell
# configuration.  If it's wrong, sorry :)

# Somehow determine if user is loading arrays, varstash, and smartcd
# Determine if user has aliased cd, pushd, and/or popd
function setup_file() {
    local file="$1"

    if ! grep "alias cd=smartcd" "$file" >/dev/null 2>&1; then
        echo "Configuring $file"
        cat <<EOF >> $file

# Load and configure smartcd
source ~/.bash_arrays
source ~/.bash_varstash
source ~/.bash_smartcd
alias cd=smartcd
alias popd=smartpopd
alias pushd=smartpushd
EOF
    fi
}

if expr $SHELL : '.*\/bash' >/dev/null; then
    if [ -f "$HOME/.bashrc" ]; then
        setup_file "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.bash_profile" ]; then
        setup_file "$HOME/.bash_profile"
    else
        setup_file "$HOME/.profile"
    fi
elif expr $SHELL : '.*\/zsh' >/dev/null; then
    setup_file "$HOME/.zshrc"
else
    echo "Unknown shell!"
    exit 1
fi
