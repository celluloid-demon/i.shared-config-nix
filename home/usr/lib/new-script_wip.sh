# [Headers, descriptions and synopses and such go here.]

# Configure arguments for mkscpt_main, or leave alone if you wish to have a
# script wrap these functions and behave as the new-script binary (the idea is
# that you can configure these functions to run, automatically, in the
# background, or plug them all into a main script, and have it behave as if it
# were the normal new-script.sh binary running. The former means added
# portability of whatever you're scripting, when you can just copy-and-paste
# the required functions into your main script.)
make_script_silent() { # Run this first if you wish to have template made silently in background
  local dir="$HOME/.syncdae"
  local filename="syncdae.sh"

  mkdir -p "$dir"

  mksyncdae_main -q "$dir/$filename" # -q to run silently in the background, without prompt
}

make_script() { # Template generator's main logic (can be invoked directly if you want user prompts)
  SCRIPT_SHELL="${SHELL}"
  daemon_progtitle="SyncDae"

  # Make some pretty date strings
  DATE=$(date +'%Y-%m-%d')
  YEAR=$(date +'%Y')

  # Get user's real name from passwd file
  AUTHOR=$(awk -v USER=$USER \
    'BEGIN { FS = ":" } $1 == USER { print $5 }' < /etc/passwd)

  # Construct the user's email address from the hostname or the REPLYTO
  # environment variable, if defined
  EMAIL_ADDRESS="<${REPLYTO:-${USER}@$HOSTNAME}>"

  # Arrays for command-line options and option arguments
  declare -a opt opt_desc opt_long opt_arg opt_arg_desc

  # Parse the "command line"
  quiet_mode=
  root_mode=
  script_license=
  while [[ -n $1 ]]; do
    case $1 in
      -h | --help)
        help_message; graceful_exit ;;
      -q | --quiet)
        quiet_mode=yes ;;
      -s | --root)
        root_mode=yes ;;
      -* | --*)
        usage; error_exit "Unknown option $1" ;;
      *)
        tmp_script=$1; break ;;
    esac
    shift
  done

  script_filename="$tmp_script"
  mksyncdae_check_filename "$script_filename" || \
    error_exit "$script_filename is not writable."
  script_purpose="Daemon used by SyncRC or SyncLink."

  script_name=${script_filename##*/} # Strip path from filename
  script_name=${script_name:-"[Untitled Script]"} # Set default if empty

  # "help" option included by default
  opt[0]="h"
  opt_long[0]="help"
  opt_desc[0]="Display this help message and exit."

  # Create usage message
  usage_message=  
  i=0
  while [[ ${opt[i]} ]]; do
    arg="]"
    [[ ${opt_arg[i]} ]] && arg=" ${opt_arg[i]}]"
    usage_message="$usage_message [-${opt[i]}"
    [[ ${opt_long[i]} ]] \
      && usage_message="$usage_message|--${opt_long[i]}"
    usage_message="$usage_message$arg"
    ((++i))
  done

  # Generate script
  if [[ $script_filename ]]; then # Write script to file
    mksyncdae_write_script > "$script_filename"
    chmod +x "$script_filename"
  else
    mksyncdae_write_script # Write script to stdout
  fi
}

mksyncdae_usage() {
  echo "Usage: ${PROGNAME} [-h|--help ] [-q|--quiet] [-s|--root] [script]"
}

mksyncdae_help_message() {
  cat <<- _EOF_
  ${PROGNAME} ${VERSION}
  Bash shell script template generator.

  $(mksyncdae_usage)

  Options:

  -h, --help    Display this help message and exit.
  -q, --quiet   Quiet mode. No prompting. Outputs default script.
  -s, --root    Output script requires root privileges to run.

_EOF_
}

mksyncdae_insert_license() {
  if [[ -z $script_license ]]; then
    echo "# All rights reserved."
    return
  fi
  cat <<- _EOF_
  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
_EOF_
}

mksyncdae_insert_usage() {
  echo -e "mksyncdae_usage() {\n  echo \"$usage_str\"\n}"
}

mksyncdae_insert_help_message() {
  local arg i long

  echo -e "mksyncdae_help_message() {"
  echo -e "  cat <<- _EOF_"
  echo -e "  \$PROGTITLE ver. \$VERSION"
  echo -e "  $script_purpose"
  echo -e "\n  \$(mksyncdae_usage)"
  echo -e "\n  Options:"
  i=0
  while [[ ${opt[i]} ]]; do
    long=
    arg=
    [[ ${opt_long[i]} ]] && long=", --${opt_long[i]}"
    [[ ${opt_arg[i]} ]] && arg=" ${opt_arg[i]}"
    echo -e "  -${opt[i]}$long$arg  ${opt_desc[i]}"
    [[ ${opt_arg[i]} ]] && \
      echo -e "    Where '${opt_arg[i]}' is the ${opt_arg_desc[i]}."
    ((++i))
  done
  [[ $root_mode ]] && \
    echo -e "\n  NOTE: You must be the superuser to run this script."
  echo -e "\n_EOF_"
  echo -e "  return\n}"
}

mksyncdae_insert_root_check() {
  if [[ $root_mode ]]; then
    echo -e "# Check for root UID"
    echo -e "if [[ \$(id -u) != 0 ]]; then"
    echo -e "  error_exit \"You must be the superuser to run this script.\""
    echo -e "fi"
  fi
}

mksyncdae_insert_parser() {
  local i
  
  echo -e "while [[ -n \$1 ]]; do\n  case \$1 in"
  echo -e "    -h | --help)\n      mksyncdae_help_message; graceful_exit ;;"
  for (( i = 1; i < ${#opt[@]}; i++ )); do
    echo -ne "    -${opt[i]}"
    [[ -n ${opt_long[i]} ]] && echo -ne " | --${opt_long[i]}"
    echo -ne ")\n      echo \"${opt_desc[i]}\""
    [[ -n ${opt_arg[i]} ]] && echo -ne "; shift; ${opt_arg[i]}=\"\$1\""
    echo " ;;"
  done
  echo -e "    -* | --*)\n      mksyncdae_usage"
  echo -e "      error_exit \"Unknown option \$1\" ;;"
  echo -e "    *)\n      echo \"Argument \$1 to process...\" ;;"
  echo -e "  esac\n  shift\ndone"
}

mksyncdae_write_script() {
#############################################################################
# START SCRIPT TEMPLATE
#############################################################################
cat << _EOF_
#!$SCRIPT_SHELL
# ---------------------------------------------------------------------------
# $daemon_progtitle - $script_purpose

# Copyright $YEAR, $AUTHOR $EMAIL_ADDRESS
$(mksyncdae_insert_license)

# Usage: $script_name$usage_message

# Revision history:
# $DATE Created by $PROGNAME ver. $VERSION
# ---------------------------------------------------------------------------

PROGNAME=\${0##*/}
PROGTITLE=SyncDae
VERSION="0.1"

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "\${PROGNAME}: \${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case \$1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n\$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "\$PROGNAME: Terminating on unknown signal" ;;
  esac
}

mksyncdae_usage() {
  echo -e "Usage: \$PROGNAME$usage_message"
}

backup() {
  local target=./
  local destination=~/Desktop/null

  rsync -lHvrtpg --progress --delete --dry-run \$target \$destination
 #rsync -lHvrtpg --progress --delete           \$target \$destination
}

main() {
  backup
}

$(mksyncdae_insert_help_message)

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

$(mksyncdae_insert_root_check)

# Parse command-line
$(mksyncdae_insert_parser)

# Main logic
main

graceful_exit

_EOF_
#############################################################################
# END SCRIPT TEMPLATE
#############################################################################
}

mksyncdae_check_filename() {
  local filename=$1
  local pathname=${filename%/*} # Equals filename if no path specified

  if [[ $pathname != $filename ]]; then
    if [[ ! -d $pathname ]]; then
      [[ $quiet_mode ]] || echo "Directory $pathname does not exist."
      return 1
    fi
  fi
  if [[ -n $filename ]]; then
    if [[ -e $filename ]]; then
      if [[ -f $filename && -w $filename ]]; then
        [[ $quiet_mode ]] && return 0
        read -p "File $filename exists. Overwrite [y/n] > "
        [[ $REPLY =~ ^[yY]$ ]] || return 1
      else
        return 1
      fi
    fi
  else
    [[ $quiet_mode ]] && return 0 # Empty filename OK in quiet mode
    return 1
  fi
}
