#!/bin/bash

echo "Testing with SHELL=$SHELL"

unset VARSTASH_QUIET VARSTASH_AUTOCONFIG VARSTASH_AUTOEDIT
unset SMARTCD_QUIET

# Test array
$SHELL t/arrays.t

# Test varstash
$SHELL t/varstash.t

# Test smartcd
$SHELL t/smartcd.t
