log() {
  local dir="$HOME/var/log"
  local logfile="test.log"

  echo "$1"                                         # Print to command line
  echo "[pretty date string] $1" >> "$dir/$logfile" # Write to file with a pretty date string
}
