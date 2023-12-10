#!/bin/bash
# ---------------------------------------------------------------------------
# cpu-temp-shutdown.sh - Script to check temperature of CPU cores and
# report/shutdown if specified temperatures exceeded.

# feedback@havetheknowhow.com

# Usage: cpu-temp-shutdown.sh <warning temp> <critical shutdown temp>

# Dependencies: sensors

# Revision history:
# 2015-01-12 Minor formatting corrections
# 2014-12-19 Created
# ---------------------------------------------------------------------------

# Global, immutable variables
readonly OPT1="$1" # seems like you need an array, for all non-option positional parameters (but you'll only use the first two; you can check the validity of them (impose limits) in another routine, and prevent undesired behavior, but those first two non-option positional parameters will be saved as anything the user enters in)
readonly OPT2="$2"
readonly LOG_DIR="/home/jonathan/var/log"
readonly LOGFILE="cpu-temp-shutdown.log"

# Define functions
main() {
  check_opt
  parse "#@"
  read_core_temp "0"
  read_core_temp "1"
  exit_message
}

check_opt() { # Exit immediately if there are no arguments, to prevent accidental shutdown
  if [[ -n $OPT2 ]]; then
    local a= # Placeholder to prevent syntax error
  else
    echo "Insufficient arguments. Exiting to prevent shutdown..." # Here, you could provide a usage message, instead. In addition, why not add argument parsing for help options?
    echo "[Enter usage of script here.]"
    exit
  fi
}

parse() {
  while [[ -n $OPT1 ]]; do
    case $OPT1 in
      -h | --help)
        help_message; graceful_exit ;;
      -* | --*)
        usage
        error_exit "Unknown option $ARG" ;;
      *)
        echo "Argument $ARG to process..." ;;
    esac
    shift
  done
}

read_core_temp() { # core_temp is matched against NOPT1 and NOPT2 (the first two non-option positional parameters, in that order)
  local core_temp=$(sensors | grep "Core $1:")
  local core_temp=${core_temp:17:2} # check validity of coretemp (set limits), if not valid then notify user unable to read temperature (report invalid temperature value) and exit on error

  # Notify the user if warning limit exceeded.
  if [[ ${core_temp} -ge "$NOPT1" ]]; then
    log "WARNING: CORE $1 TEMPERATURE EXCEEDED $NOPT1 -> $core_temp"
  fi
  
  # Notify the user if critical limit exceeded, then shutdown the server.
  if [[ ${core_temp} -ge "$NOPT2" ]]; then
    log "CRITICAL: CORE $1 TEMPERATURE EXCEEDED MAX $NOPT2 -> $core_temp"
    log "CRITICAL: SHUTTING DOWN THE SERVER!"
    /sbin/shutdown -h now
    exit
  fi

  echo "Core $1 temperature OK at $core_temp."
}

log() {
  echo "$1"                                 # Notify user
  echo "$(date): $1" >> "$LOG_DIR/$LOGFILE" # Write log
}

exit_message() {
  echo
  echo "Both CPU cores are within limits. Yay, everything is OK!"
  echo
}

# Main logic
main "#@"
