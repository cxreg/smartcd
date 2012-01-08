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
	rm -rf $(HOME)/.smartcd/lib/core
	mkdir -p $(HOME)/.smartcd/lib/core
	cp -r lib/core $(HOME)/.smartcd/lib
	cp bash_smartcd $(HOME)/.bash_smartcd
	@echo
	@echo "smartcd is now installed"
	@echo
	@echo "If this is your first time installing smartcd, run the following command:"
	@echo
	@echo "    source ~/.smartcd/lib/core/smartcd"
	@echo
	@echo "After you have done that, run \`smartcd config\` to configure your shell"


setup:
	@echo "\`make setup\` is deprecated, please run \`smartcd config\`"
