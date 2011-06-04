#!/bin/bash

echo "Testing with SHELL=$SHELL"

# Test array
$SHELL t/arrays.t

# Test varstash
$SHELL t/varstash.t

# Test smartcd
$SHELL t/smartcd.t
