all:
	@echo "Run \"make install\" to install to your home directory"
	@echo "To set up your shell configuration, run \"make setup\""
	@echo "See README for instructions on installation or configuration"

test:
	t/harness.sh

test_bash:
	t/harness.sh /bin/bash

test_zsh:
	t/harness.sh /usr/bin/zsh

test_all: test_bash test_zsh


install:
	cp bash_arrays ~/.bash_arrays
	cp bash_varstash ~/.bash_varstash
	cp bash_smartcd ~/.bash_smartcd
	@echo "smartcd installed, run \"make setup\" to configure your shell"

setup:
	./setup.sh
