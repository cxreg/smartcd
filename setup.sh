#!/bin/bash
#

function setup_file() {
    local file="$1"; shift
    local config="$1"; shift

    if ! grep "smartcd" "$file" >/dev/null 2>&1; then
        echo "Configuring $file"
        echo -e "$config" >> $file
    else
        echo "$file already appears to be configured, please check it for correctness"
        echo "This is what you configured:"
        echo -e "$config"
    fi
}

function write_config_file() {
    local config="$1"
    echo -e "$config" > "$HOME/.smartcd_config"
}

function generate_config() {
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

    unset -f _setup_conditionally

    echo -e "$config"
}

yes="^y"
function read_yesno() {
    read yesno < /dev/tty
    yesno=$(echo $yesno | tr 'A-Z' 'a-z')
    : ${yesno:=$1}
    echo $yesno
}

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
setup_cd=$(read_yesno y)

echo
echo "[ smartcd setup pushd ]"
echo "[ smartcd setup popd  ]"
echo -n "Would you like to wrap pushd and popd? [Y/n] "
setup_pushd=$(read_yesno y)

echo
echo "[ setup_smartcd_prompt_hook ]"
echo "Would you like to enable prompt-command hooks?  (This is only recommended if you are an"
echo -n "\"autocd\" user, say no if you are unsure [y/N] "
enable_prompt_hook=$(read_yesno n)

echo
echo "[ setup_smartcd_exit_hook ]"
echo "Would you like to enable the shell exit hook?  This will cause bash_leave scripts to run"
echo -n "from your current directory down to / when exiting your shell [y/N] "
enable_exit_hook=$(read_yesno n)

echo
echo "[ VARSTASH_AUTOCONFIGURE=1 ]"
echo -n "Would you like to automatically configure smartcd when you run stash or autostash manually? [y/N] "
autoconfigure=$(read_yesno n)

if [[ $autoconfigure =~ $yes ]]; then
    echo
    echo "[ VARSTASH_AUTOEDIT=1 ]"
    echo -n "Would you also like to edit the smartcd config after it is automatically configured? [y/N] "
    autoedit=$(read_yesno n)
fi

echo
echo "[ADVANCED USAGE]"

echo
echo "[ SMARTCD_AUTOMIGRATE=1 ]"
echo -n "Would you like to automigrate legacy smartcd scripts? [y/N] "
automigrate=$(read_yesno n)

echo
echo "[ SMARTCD_LEGACY=1 ]"
echo -n "Would you like to allow legacy scripts to run in-place? (DISCOURAGED) [y/N] "
legacy=$(read_yesno n)

config=$(generate_config)

echo

if [[ -f "$HOME/.smartcd_config" ]]; then
    config_file_exists=1
    echo -n "$HOME/.smartcd_config already exists, do you want to overwrite it? [y/N] "
    overwrite_config_file=$(read_yesno n)
    if [[ $overwrite_config_file =~ $yes ]]; then
        write_config_file "$config"
    else
        echo "Ok, here is the configuration that you generated, please update as necessary:"
        echo "$config"
    fi
else
    echo -n "Would you like to configure smartcd in $HOME/.smartcd_config? (recommended) [Y/n] "
    create_config_file=$(read_yesno y)
    if [[ $create_config_file =~ $yes ]]; then
        write_config_file "$config"
        config_file_exists=1
    fi
fi

if [[ -n $config_file_exists ]]; then
    for file in $possible_files; do
        if [[ -f "$HOME/$file" ]]; then
            if grep "\.smartcd_config" "$HOME/$file" >/dev/null 2>&1; then
                setup=1
            else
                echo -n "I see you have a $file, would you like to load your config file from there? [Y/n] "
                answer=$(read_yesno y)
                if [[ $answer =~ $yes ]]; then
                    echo -e "\nsource ~/.smartcd_config" >> "$HOME/$file"
                    setup=1
                fi
            fi
        fi
    done

    if [[ -z $setup ]]; then
        echo -n "You did not load your config anywhere, which file would you like to load it from? "
        read filename < /dev/tty
        if [[ -n "$filename" ]]; then
            # eval here to expand ~
            real_filename=$(readlink -f $(eval echo $filename))
            if [[ -f "$real_filename" ]]; then
                echo -e "\nsource ~/.smartcd_config" >> "$real_filename"
            else
                echo "Sorry, I can't find $filename"
            fi
        else
            echo
            echo "WARNING"
            echo "You apparently did not configure your shell to load your smartcd configuration."
            echo "Make sure you add \"source ~/.smartcd_config\" to the appropriate location."
        fi
    fi
else
    for file in $possible_files; do
        if [[ -f "$HOME/$file" ]]; then
            echo -n "I see you have a $file, would you like to write your config to it? [Y/n] "
            answer=$(read_yesno y)
            if [[ $answer =~ $yes ]]; then
                setup_file "$HOME/$file" "$config"
                setup=1
            fi
        fi
    done

    if [[ -z $setup ]]; then
        echo -n "You did not configure any files, which file would you like to set up? "
        read filename < /dev/tty
        if [[ -n "$filename" ]]; then
            # eval here to expand ~
            real_filename=$(readlink -f $(eval echo $filename))
            if [[ -f "$real_filename" ]]; then
                setup_file "$real_filename" "$config"
            else
                echo "Sorry, I can't find $filename"
            fi
        else
            echo "Ok, here is your configuration, please set it up in an appropriate location:"
            echo "$config"
        fi
    fi
fi
