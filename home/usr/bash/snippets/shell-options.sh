#!/bin/bash

# Shell options

# The provided shell options at the beginning of the scripts are not
# mandatory, but it's a good habit to use them in every script we write. In
# brief, -e, short for errexit, modifies the behavior of the shell that will
# exit whenever a command exits with a non zero status (with some exceptions).
set -e

# -u is another very important option: this makes the shell to treat undefined
# variables as errors.
set -u

# The pipefail changes the way commands inside a pipe are evaluated. The exit
# status of a pipe will be that of the rightmost command to have exited with a
# non zero status, or zero if the all the programs in the pipe have been
# executed successfully. In other words, the pipe will be considered
# successful if all the commands involved are executed without errors.
set -o pipefail
