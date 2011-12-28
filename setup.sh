#!/bin/bash
#

function setup_file() {
    local file="$1"

    function _setup_conditionally() {
        cond=$1; shift
        if [[ ! $cond =~ $yes ]]; then
            local comment="# "
        fi
        config="$config\n${comment}$*"
    }

    local config=

    config="\n# Load and configure smartcd\nsource ~/.bash_arrays\nsource ~/.bash_varstash\nsource ~/.bash_smartcd"

    _setup_conditionally "$setup_cd"            "smartcd setup cd"
    _setup_conditionally "$setup_pushd"         "smartcd setup pushd"
    _setup_conditionally "$setup_pushd"         "smartcd setup popd"
    _setup_conditionally "$enable_prompt_hook"  "smartcd setup prompt-hook"
    _setup_conditionally "$enable_exit_hook"    "smartcd setup exit-hook"
    _setup_conditionally "$autoconfigure"       "VARSTASH_AUTOCONFIGURE=1"
    _setup_conditionally "$autoedit"            "VARSTASH_AUTOEDIT=1"
    _setup_conditionally "$automigrate"         "SMARTCD_AUTOMIGRATE=1"
    _setup_conditionally "$legacy"              "SMARTCD_LEGACY=1"

    # Add commented-out quiet settings so the user can enable them later
    _setup_conditionally ""                "SMARTCD_QUIET=1"
    _setup_conditionally ""                "VARSTASH_QUIET=1"

    if ! grep "smartcd" "$file" >/dev/null 2>&1; then
        echo "Configuring $file"
        echo -e $config >> $file
    else
        echo "$file already appears to be configured, please check it for correctness"
        echo "This is what you configured:"
        echo -e $config
    fi

    unset -f _setup_conditionally
}

yes="^y"
echo "It looks like you're running $SHELL"
echo -n "Which shell would you like to configure? [$SHELL] "
read which_shell < /dev/tty
which_shell=${which_shell:=$SHELL}

if [[ $which_shell =~ 'bash' ]]; then
    possible_files=".bashrc .bash_profile .profile"
elif [[ $which_shell =~ 'zsh' ]]; then
    possible_files=".zshrc"
else
    echo "Unknown shell, sorry!  Only bash and zsh are supported at this time"
    exit 1
fi

echo
echo "[ smartcd setup cd ]"
echo -n "Would you like to wrap cd with smartcd?  This is the recommended way to run smartcd [Y/n] "
read setup_cd < /dev/tty
setup_cd=$(echo $setup_cd | tr 'A-Z' 'a-z')
: ${setup_cd:=y}

echo
echo "[ smartcd setup pushd ]"
echo "[ smartcd setup popd  ]"
echo -n "Would you like to wrap pushd and popd? [Y/n] "
read setup_pushd < /dev/tty
setup_pushd=$(echo $setup_pushd | tr 'A-Z' 'a-z')
: ${setup_pushd:=y}

echo
echo "[ setup_smartcd_prompt_hook ]"
echo "Would you like to enable prompt-command hooks?  (This is only recommended if you are an"
echo -n "\"autocd\" user, say no if you are unsure [y/N] "
read enable_prompt_hook < /dev/tty
enable_prompt_hook=$(echo $enable_prompt_hook | tr 'A-Z' 'a-z')
: ${enable_prompt_hook:=n}

echo
echo "[ setup_smartcd_exit_hook ]"
echo "Would you like to enable the shell exit hook?  This will cause bash_leave scripts to run"
echo -n "from your current directory down to / when exiting your shell [y/N] "
read enable_exit_hook < /dev/tty
enable_exit_hook=$(echo $enable_exit_hook | tr 'A-Z' 'a-z')
: ${enable_exit_hook:=n}

echo
echo "[ VARSTASH_AUTOCONFIGURE=1 ]"
echo -n "Would you like to automatically configure smartcd when you run stash or autostash manually? [y/N] "
read autoconfigure < /dev/tty
autoconfigure=$(echo $autoconfigure | tr 'A-Z' 'a-z')
: ${autoconfigure:=n}

if [[ $autoconfigure =~ $yes ]]; then
    echo
    echo "[ VARSTASH_AUTOEDIT=1 ]"
    echo -n "Would you also like to edit the smartcd config after it is automatically configured? [y/N] "
    read autoedit < /dev/tty
    autoedit=$(echo $autoedit | tr 'A-Z' 'a-z')
    : ${autoedit:=n}
fi

echo
echo "[ADVANCED USAGE]"

echo
echo "[ SMARTCD_AUTOMIGRATE=1 ]"
echo -n "Would you like to automigrate legacy smartcd scripts? [y/N] "
read automigrate < /dev/tty
automigrate=$(echo $automigrate | tr 'A-Z' 'a-z')
: ${automigrate:=n}

echo
echo "[ SMARTCD_LEGACY=1 ]"
echo -n "Would you like to allow legacy scripts to run in-place? (DISCOURAGED) [y/N] "
read legacy < /dev/tty
legacy=$(echo $legacy | tr 'A-Z' 'a-z')
: ${legacy:=n}

echo
for file in $possible_files; do
    if [[ -f "$HOME/$file" ]]; then
        echo -n "I see you have a $file, would you like to set that up? [Y/n] "
        read answer < /dev/tty
        answer=$(echo $answer | tr 'A-Z' 'a-z')
        : ${answer:=y}
        if [[ $answer =~ $yes ]]; then
            setup_file "$HOME/$file"
            setup=1
        fi
    fi
done

if [[ -z $setup ]]; then
    echo -n "You did not configure any files, which file would you like to set up? "
    read filename < /dev/tty
    if [[ -n "$filename" ]]; then
        real_filename=$(readlink -f $(eval echo $filename))
        if [[ -f "$real_filename" ]]; then
            setup_file "$real_filename"
        else
            echo "Sorry, I can't find $filename"
        fi
    else
        echo "Ok, nevermind then"
    fi
fi
