# Non-reusable, but can be generated with std.sh for a fully-functional script library
# (If it's unique, then it can very well be generated in-line on the main script)

help_message() {
  cat <<- _EOF_
  $PROGTITLE ver. $VERSION
  A "remote control" for backup management.

  $(usage)

  Options:
  -h, --help  Display this help message and exit.

_EOF_
  return
}
