all:
	@echo "Run \"make install\" to install to your home directory"
	@echo "See README for instructions on installation or configuration"

test:
	t/harness.sh

install:
	cp bash_arrays ~/.bash_arrays
	cp bash_varstash ~/.bash_varstash
	cp bash_smartcd ~/.bash_smartcd
