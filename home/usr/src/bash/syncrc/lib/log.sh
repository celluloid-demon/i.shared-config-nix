# Reusable

log() {
  local dir="$HOME/var/log"
  local logfile="syncrc.log"

  echo "$1"                                       # Print to command line
  echo "[pretty date string] $1" >> $dir/$logfile # Write to file with a pretty date string
}
