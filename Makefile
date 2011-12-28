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
	cp bash_arrays $(HOME)/.bash_arrays
	cp bash_varstash $(HOME)/.bash_varstash
	cp bash_smartcd $(HOME)/.bash_smartcd
	@echo "smartcd installed"
	@echo "If this is your first time installing smartcd, run this following command:"
	@echo
	@echo "    source ~/.bash_smartcd"
	@echo
	@echo "After you have done that, run \"smartcd config\" to configure your shell"

setup:
	@echo "\`make setup\` is deprecated, please run \`smartcd config\`"
