#!/bin/bash
# ---------------------------------------------------------------------------
# stdutils.sh - A collection of handy utilities and functions to make bash
# scripting easier and more fun.

# This is an attempt to make all libraries compatable with each other, and
# make it easier to load them all under the library "stdutils.sh".

# A note on "std"-prefixed libraries: These libraries should store their
# configuration files in the ETC or UETC directories.

# Jonathan Dudrey
# Nathaniel Landau <nate+site@natelandau.com>

# Revision history:
# 2014-12-30 Forked by Jonathan Dudrey
# 2014-12-30 Downloaded from http://natelandau.com/
# ---------------------------------------------------------------------------

# Source libraries
source_libraries() {
  local lib="$HOME/lib"
  local ulib="$HOME/usr/lib"

  source "$ulib/stdgethome.sh"
  source "$ulib/stdhostlock.sh"
  source "$ulib/stdlockfile.sh"

  unset lib
  unset ulib
}

source_libraries # necessary to keep variables local

# Define functions

#
# Set Colors
#

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

#
# Headers and  Logging
#

e_header() { printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}
e_arrow() { printf "➜ $@\n"
}
e_success() { printf "${green}✔ %s${reset}\n" "$@"
}
e_error() { printf "${red}✖ %s${reset}\n" "$@"
}
e_warning() { printf "${tan}➜ %s${reset}\n" "$@"
}
e_underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
e_bold() { printf "${bold}%s${reset}\n" "$@"
}
e_note() { printf "${underline}${bold}${blue}Note:${reset}  ${blue}%s${reset}\n" "$@"
}

#
# USAGE FOR SEEKING CONFIRMATION
# seek_confirmation "Ask a question"
# Credt: https://github.com/kevva/dotfiles
#
# if is_confirmed; then
#   some action
# else
#   some other action
# fi
#

seek_confirmation() {
  printf "\n${bold}$@${reset}"
  read -p " (y/n) " -n 1
  printf "\n"
}

# underlined
seek_confirmation_head() {
  printf "\n${underline}${bold}$@${reset}"
  read -p "${underline}${bold} (y/n)${reset} " -n 1
  printf "\n"
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  return 0
fi
return 1
}

#
# Test whether a command exists
# $1 = cmd to test
# Usage:
# if type_exists 'git'; then
#   some action
# else
#   some other action
# fi
#

type_exists() {
if [ $(type -P $1) ]; then
  echo "Returned 0!"
  return 0
fi
echo "Returned 1!"
return 1
}

#
# Test which OS the user runs
# $1 = OS to test
# Usage: if is_os 'darwin'; then
#

is_os() {
if [[ "${OSTYPE}" == $1* ]]; then
  return 0
fi
return 1
}

is_machine() {
if [[ "${HOSTNAME}" == $1* ]]; then
  echo "Returned 0!"
  return 0
fi
echo "Returned 1!"
return 1
}

#
# Pushover Notifications
# Usage: pushover "Title Goes Here" "Message Goes Here"
# Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html
#

pushover () {
    PUSHOVERURL="https://api.pushover.net/1/messages.json"
    API_KEY="your-api-here"
    USER_KEY="your-user-key-here"
    DEVICE=""

    TITLE="${1}"
    MESSAGE="${2}"

    curl \
    -F "token=${API_KEY}" \
    -F "user=${USER_KEY}" \
    -F "device=${DEVICE}" \
    -F "title=${TITLE}" \
    -F "message=${MESSAGE}" \
    "${PUSHOVERURL}" > /dev/null 2>&1
}
