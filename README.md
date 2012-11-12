# smartcd - make your shell come alive

## WHAT IS SMARTCD?

  smartcd is a library for bash and zsh which brings transformative power
  to your fingertips.

  The basic premise is that as you move around your computer using the shell,
  actions can be automatically taken to provide you with the environment you
  really want, not the one you're accustomed to putting up with.

## Have you ever...

  * Created a file for a project to alter your environment by setting
    variables or creating aliases so that things work correctly, one which
    you need to remember to load by hand

  * Struggled to set up your shell's configuation to support conflicting
    needs for different uses

  * Wished that your prompt could be made to say something or be a different
    color when you are in a sensitive directory

  * Wanted a daemon process to run automatically when you go to work on a
    project, and shut down when you finish

  * Wanted to automatically update your project from source control when you
    enter

  * Needed to attach to a particular screen(1) session when working in
    a particular directory

These are just a few examples of problems people are solving with smartcd.


## OK, HOW DO I USE IT?

  It's stupid easy.  If you have already downloaded the archive or checked out
  the source, you can:

    make install
    source ~/.smartcd/lib/core/smartcd
    smartcd config

  However, if you would rather skip all that and simply have it install itself,
  try this:

    curl -L http://smartcd.org/install | bash

  Either method will prompt you to configure a small number of settings, and
  then help you set up your shell to load it on login.

  Once it is installed, you're ready to go.  All actions are available through
  the `smartcd` command.

    Usage: smartcd ( edit | show | filename | helper | template | setup | config ) [args]

  If you run `smartcd edit enter`, it will launch your editor to allow you to
  begin creating a script for the current directory which will run when you
  enter.  Its counterpart, `smartcd edit leave`, will create a script that runs
  when you cd away from the current directory.

  An auxiliary library is provided with smartcd called varstash.  This provides
  you with a powerful mechanism which saves the definitions of variables,
  aliases, and shell functions to allow you to change or unset them temporarily.
  Once you are finished, it will allow you to (or automatically) restore their
  prior values.

  For example,

    autostash PATH=/path/to/my/project/bin:$PATH
    autostash alias restart="apachectl restart"
    restart

  will save the value of your $PATH, and prepend a project-specific directory
  to it.  smartcd will automagically restore its old value when you leave the
  directory.

  The second line creates a temporary alias which is probably something only
  meaningful to the directory you are in, allowing you to keep concise aliases
  that won't get in your way, and allow you to re-use them between projects.

  And these commands are immediately available, as shown by the third line,
  which makes use of the newly defined alias to restart your server.

  You could instead create the files non-interactively

    echo 'autostash PATH=__PATH__/temporary/path:$PATH' | smartcd edit enter

  which also highlights a convenient feature that replaces __PATH__ with the
  directory name before the script is run.

  If you like doing things by hand, you may prefer

    mkdir -p ~/.smartcd/scripts/some/directory
    echo 'autostash PATH=__PATH__/temporary/path:$PATH' >> ~/.smartcd/scripts/some/directory/bash_enter


## HOW DOES IT WORK?

  Scripts for smartcd are contained in a directory structure under your home,
  in the .smartcd directory.  As you change directory, it will look for files
  which correspond to where you are leaving from and going to, and run them for
  you.

  The primary way of doing this is to create a "cd" function which calls
  `smartcd cd`. This also works with push and popd.  The simplest way to
  create these wrappers is to call `smartcd setup cd`, `smartcd setup pushd`,
  and `smartcd setup pushd`.  When you `smartcd config`, this will be set up
  for you.

  If you prefer (or in addition), you can hook the prompt command.
  This sets PROMPT_COMMAND in bash, or precmd in zsh.  This is enabled using
  `smartcd setup prompt-hook`.  After calling smartcd, it will call any prior
  command for those hooks.  This feature allows users with the "autocd" option
  set in their shell to also benefit from smartcd.

  The structure of .smartcd will mirror the filesystem hierarchy you wish to
  configure.  For example:

      Path         Action      Script
    ------------------------------------------------------------
     /foo/bar       enter     ~/.smartcd/scripts/foo/bar/bash_enter
     /foo/bar/baz   leave     ~/.smartcd/scripts/foo/bar/baz/bash_leave

  You can edit and read these files with the smartcd command using the
  "edit", "show", and "filename" actions.

    user@host:/usr/local/bin$ smartcd filename enter
    /home/user/.smartcd/scripts/usr/local/bin/bash_enter

    user@host:/usr/local/bin$ smartcd show leave
    /home/user/.smartcd/scripts/usr/local/bin/bash_leave does not exist

    user@host:/usr/local/bin$ smartcd show enter
    /home/user/.smartcd/scripts/usr/local/bin/bash_enter exists
    -------------------------------------------------------------------------
    smartcd inform "testing"
    -------------------------------------------------------------------------

    user@host:/usr/local/bin$ smartcd edit enter
    --> edits ~/.smartcd/scripts/usr/local/bin/bash_enter

    user@host:/usr/local/bin$ echo "some-command" | smartcd edit enter

  One thing to note is that going from a directory to its child is not
  considered "leaving", so the bash_leave will not be run until you go to
  another directory that doesn't contain that same directory as part of
  its path.  The scripts are run as appropriate if they exist for each
  level going back to the common element between the paths.

  If you cd from /foo/bar/baz to /foo/quux/biff, the following actions would
  take place:

    1) bash_leave for /foo/bar/baz
    2) bash_leave for /foo/bar
    3) bash_enter for /foo/quux
    4) bash_enter for /foo/quux/biff

  These scripts are run in the interactive shell using eval, so any variables
  or other environment effects will take place in the user's shell directly.


## WHAT ARE SOME COMMON RECIPES?

  Here are some examples of useful setups that have been created so far


### DISPLAY A MESSAGE

  Sometimes you may want a message to be shown when you enter or leave the
  directory, either to remind to you do something, or simply to let you know
  what the script has done.

  You could use `echo` for this, but the issue with that is if you are doing
  something sophisticated with pipes, you may not want this message to
  interfere with the command being piped.  For example, you might use the
  following command to copy some files

    ( cd foo; tar -cf - sub-dir ) | ( cd bar; tar -xf - )

  but if "foo" has an enter script which echos something, this will corrupt
  the tar file.  By using `smartcd inform`, this will suppress the output when
  it is detected that the output is not a terminal

    smartcd inform "Reminder, don't forget to commit your code!"


### PROMPT COLOR

  If you want a visual cue that you need to be careful, it might make sense
  to change your prompt.  Here's one that will temporarily make your prompt
  red while leaving its actual value alone.

    autostash PS1='\[\e[1;31m\]'"$PS1"'\[\e[0m\]'

  Note the double-quotes around $PS1.  This is not superfluous, if your
  current value has any space characters in it, it's important to use quoting
  because otherwise it would be seen as a second argument to autostash


### SCREEN

  This one can be a bit tricky since screen commands from within screen tend
  to confuse it.  And of course, creating a new screen window will execute
  your bash_enter scripts.

  So what we'll do is set a variable in the attaching shell which is seen
  from within screen to prevent it from doing so.

    if [[ -z $MYSCREEN ]]; then
        autostash MYSCREEN=1
        screen -c __PATH__/.screenrc -RRD my-special-screen-session
    fi


### PERLBREW

  perlbrew is a system for installing multiple builds and versions of the Perl
  language, allowing you to easily switch between them.  This is very valuable
  for development, but probably not what you want for your whole system.

  smartcd now ships with a helper designed to integrate perlbrew and smartcd
  seamlessly together.  Simply put this line in your enter script:

    smartcd helper run perlbrew init /path/to/perlbrew/install

  When you leave the directory, perlbrew will stop being in effect and you will
  get your previous perl back.

  perlbrew is available at http://search.cpan.org/~gugod/App-perlbrew/


### local::lib

  Perl currently ships with a module named local::lib, which is handy for
  installing module dependencies outside of the standard install locations.

  A helper is included for interacting with this module as well.

    smartcd helper run perl-locallib activate __PATH__/perl5lib

  If you want to explicitly remove a path (as you might do with
  -Mlocal::lib=--deactivate), this is supported

    smartcd helper run perl-locallib deactivate __PATH__/perl5lib

  but not required.  If you don't perform this set, it will still be
  automatically cleared when you cd away restoring any prior local::lib
  or PERL5LIB state.


### RVM

  RVM is the Ruby Version Manager, which like perlbrew, can manage multiple
  versions of the language being installed at once.  Because it too wants to
  wrap the `cd` command, things are a little tricker than with perlbrew.
  Fortunately, the RVM project has added express support for smartcd as the
  action taken during its own cd.  If both projects are installed, RVM's cd()
  will call smartcd's, regardless of which order the two are set up.

  RVM is available at http://beginrescueend.com/


### STOP/START

  If you want something to start running when you enter the directory, and
  stop running when you leave, you can certainly use smartcd for this.  Here's
  an example of how someone is using smartcd to start and stop a Plack service

    ### enter script ###

    # temporarily define the functions stop and start
    autostash stop start pidfile="__PATH__/.pid"
    start() {
        if [[ ! -f "$pidfile" ]] || ! kill -0 $(cat "$pidfile") >/dev/null 2>&1; then
            (
                builtin cd __PATH__/html
                plackup &> /dev/null &
                local pid=$!
                echo $pid > "$pidfile"
                smartcd inform "Started Plack with pid $pid"
            )
        fi
    }
    stop() {
        if [[ -f "$pidfile" ]] && kill -0 $(cat "$pidfile") >/dev/null 2>&1; then
            kill $(cat "$pidfile")
            rm "$pidfile"
        fi
    }

    # Create an alias that calls both functions
    autostash alias restart="stop; sleep 2; start"

    # And automatically start-up on enter
    start


    ### leave script ###

    # Shut down when leaving.  Yes, this function is still available here, and
    # it will be removed by autounstash after this leave is complete
    stop

    # There are several things to make a note of here
    #
    #   1) The sub-shell created in the start() function is not actually necessary
    #      if `start` is _only_ run from within smartcd, since the extra `cd` command
    #      will not prevent you from ending up in the right directory.  However, since
    #      this function can be called manually, it's safer to do this in a subshell.
    #
    #   2) I used `builtin cd` instead of just `cd` in start() to avoid smartcd being
    #      called during another call, possibly causing surprising results.  However,
    #      if you actually want smartcd to be run in that situation, it's ok to do so.
    #
    #   3) Use __PATH__ liberally to ensure that files and actions are taken in the
    #      correct place, even after you've changed to a subdirectory of where the script
    #      was defined.


  and of course, if you want to be sure that this daemon is shut down properly
  if you simply log out or close your shell, you will want the exit hook as well

    # in your .smartcd_config, see `smartcd config`
    smartcd setup exit-hook


## WHAT ELSE CAN IT DO?

### HELPERS

  A system for pre-written scripts is provided which implement things that you
  may find useful.  This system allows people to distribute and share these
  independently of the core smartcd distribution.

  Some helpers are provided with smartcd, including:

  * path:

    Simple ways to temporarily add elements to your PATH

    ```
    smartcd helper run path append __PATH__/bin
    smartcd helper run path prepend __PATH__/bin
    ```


  * history:

    This keeps commands run in the current and any subdirectories
    in a separate history file specified as an argument.  The also-read
    command will prepend another history file into the shell's buffer
    when setting up, so that other history can be availble "further
    back" in your history.

    ```
    smartcd helper run history also-read ~/.bash_history
    smartcd helper run history localize __PATH__/.history
    ```

    You can also have ask it to save and/or reload this history
    file on each prompt

    ```
    smartcd helper run history prompt-append
    smartcd helper run history prompt-reload
    ```

  * perlbrew:

    Automagic setup and teardown of Perlbrew

    ```
    smartcd helper run perlbrew init /path/to/perlbrew/install
    ```


### TEMPLATES

  In addition to configuring scripts individually, smartcd supports a template
  system, which can be set up to re-use common configuration among many
  directories.  This is controlled with the "smartcd template" action.

  To create a new template based on the current directory, run:

    smartcd template create some_template_name

  This will create a new template named "some_template_name", and prepopulate
  it from the bash_enter and bash_leave files corresponding to the working
  directory, replacing any instance of your working directory with __PATH__.

  You can then edit the contents with `smartcd template edit some_template_name`.
  The `create` step is optional, and if you `edit` a template that is not yet
  created you will start with an empty one.

  Now that your template is ready, you'll want to use it somewhere.  For this,
  there are two options:

  1. Run it "in-place", and all changes to the template will be dynamically
  picked up by the enter and exit scripts which execute it

        echo 'smartcd template run some_template_name' | smartcd edit enter

  The `run` action will determine if you are in an "enter" or "leave" script,
  and execute the correct portion of the template.  This does not need to be
  the only line in your script, and in fact you can even run more than one
  template from the same script.

  1. Copy the current contents of the template to the scripts for a directory,
  as a one-time operation.  This will not automatically propagate changes to
  the places it is in use, and can be used as a way to quickly bootstrap
  scripts but allow them to exist independently.

        smartcd template install some_template_name


  The other template editor actions are `show`, `list`, and `delete`.


### NESTABLE PROMPT COMMANDS

  Users can define their own actions which will be taken just before each
  prompt is displayed.  In fact, smartcd itself can use this mechanism to
  invoke itself.

  smartcd on-prompt takes this concept to a new level.  By specifying commands
  to be run, they will be run on each prompt, similar to the built-in feature,
  but only while you are in the current directory and its children.  In
  addition to this, further on-prompt commands specified in child directories
  will run in addition to the current ones rather than replacing them.

  For example:

    ~/foo$ smartcd on-prompt 'echo test 1'
    test 1
    ~/foo$ cd bar
    test 1
    ~/foo/bar$ smartcd on-prompt 'echo test 2'
    test 1
    test 2
    ~/foo/bar$ cd ..
    test 1
    ~/foo$ cd
    ~$


### EXIT HOOK

  By default, your enter scripts will be run when a shell is started.  However,
  the opposite is not the case.  If you'd like your leave scripts to run when
  the shell exits, smartcd is able to utilize the shell's EXIT trap hook to do
  so, or in zsh, the zshexit hook.  This is enabled by running

    smartcd setup exit-hook


### BACKUP

  If you would like to back up your scripts and templates, or copy them to
  another computer, you can use the provided export/import feature.

    # Export your scripts
    smartcd export > my_smartcd_backup

    # Several methods to import them
    smartcd import my_smartcd_backup
    cat my_smartcd_backup | smartcd import


For more complete documentation, see the documentation in lib/core/smartcd.


## OTHER LIBRARIES

### VARSTASH

  As already discussed, the included library lib/core/varstash provides several
  functions for saving values to a temporary location so that you can edit
  them, and then later restore the original value.

  In addition to autostash, you could manually stash and unstash using
  functions with those names if there is some need to do so

    echo 'stash FOO=bar' | smartcd edit enter
    echo 'unstash FOO' | smartcd edit leave

  You may also trigger autostash's restore mechanism by calling

    autounstash

  by hand.  It's safe to do so multiple times and it won't harm smartcd
  if you do this.

  If you run stash, unstash, or autostash interactively, they will instruct
  you on how to create files for smartcd to run those commands for you.  If
  you do not wish to see this advice, set `VARSTASH_QUIET=1`.  The library can
  automatically follow its own advice and configure these files if you set
  `VARSTASH_AUTOCONFIG=1`.  It can do so, but also give you an opportunity to
  make additional edits to the relevant file, if you set `VARSTASH_AUTOEDIT=1`.

  Alias stashing was briefly mentioned, and it is supported to do in-line
  stashing and declaration of an alias with autostash

    autostash alias mycmd="do something crazy"

  However, stashing functions looks like this:

    autostash my_func
    my_func() {
        some_new_definition
    }

  It's useful to autostash something even before it's set, because that
  triggers the mechanism which will unset them upon leaving.  Since functions
  cannot be declared inline with autostash, this is how you should do it.


### ARRAYS

  Bash added array support in version 2.0, but it doesn't have a very good
  set of supporting built-ins.  In particular, I find myself missing the Perl
  functions push, pop, shift, unshift, reverse.

  To provide these capabilities, another library, lib/core/arrays, is
  included.  The provided functions are:

    apush    - Add an element to the end of your array
    apop     - Remove the last element from the array and print it
    ashift   - Remove the first element from the array and print it
    aunshift - Add an element to the beginning of the array
    areverse - Reverse the order of elements in the array
    afirst   - Like ashift, but doesn't remove anything.
    alast    - Like apop, but doesn't remove anything.
    anth     - Retreive the n-th element of an array.
    alen     - Print the current number of elements in the array
    acopy    - Copy an array into a new variable

  See documentation included in lib/core/arrays for more detail.


## LICENSE

This code is Copyright (c) 2009,2012 Dave Olszewski <cxreg@pobox.com>

You may distribute under the terms of either the GNU General Public
License v2 or the Artistic License.


## SEE ALSO

  As with most ideas worth doing, there are other implementations of some
  of the things provided by smartcd.  Here are a few of them, and how they
  differ from this library.

  * ondir - http://swapoff.org/ondir.html
      * Written in C, and is executed by a "cd" function
      * Requires manual and explicit variable setting and unsetting

  * direnv - https://github.com/zimbatm/direnv/
      * Requires ruby
      * Works only with PROMPT_COMMAND or precmd
      * Does not walk directory hierarchy
      * Does not support functions or aliases
      * Is entirely "snapshot" based
      * Runs files directly out of local directory, similar to "legacy mode"

  * EnvWatcher - https://github.com/MrMasterplan/EnvWatcher
      * Requires python
      * Only supports bash
      * Is triggered manually, not automatically
      * Does not walk directory hierarchy
      * Is entirely "snapshot" based
      * Does not allow other actions besides environment variable switching
