all:
	@echo "Run \"make install\" to install to your home directory"
	@echo "To set up your shell configuration, run \"smartcd config\""
	@echo "See README for instructions on installation or configuration"

test:
	t/harness.sh

test_bash:
	t/harness.sh /bin/bash

test_zsh:
	t/harness.sh /usr/bin/zsh

test_all: test_bash test_zsh


install:
	@[ -d $(HOME)/.smartcd/lib/core ] && echo "* Removing old $(HOME)/.smartcd/lib/core" && rm -rf $(HOME)/.smartcd/lib/core || true
	@echo "* Installing libraries to $(HOME)/.smartcd/lib"
	@mkdir -p $(HOME)/.smartcd/lib/core
	@cp -r lib/core $(HOME)/.smartcd/lib
	@echo "* Installing helpers to $(HOME)/.smartcd/helper"
	@mkdir -p $(HOME)/.smartcd/helper
	@cp -r helper $(HOME)/.smartcd
	@[ -f $(HOME)/.bash_smartcd ] && echo "* Replacing legacy $(HOME)/.bash_smartcd" && cp bash_smartcd $(HOME)/.bash_smartcd || true
	@echo
	@echo "Congratulations, smartcd is now installed"
	@echo
	@echo "If this is your first time installing smartcd, run the following commands:"
	@echo
	@echo "    source load_smartcd"
	@echo "    smartcd config"
	@echo
	@echo "See the README file for ideas about what you can do with it"


setup:
	@echo "\`make setup\` is deprecated, please run \`smartcd config\`"
