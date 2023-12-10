help_message() {
  cat <<- _EOF_
  $PROGTITLE ver. $VERSION
  This is a test.

  $(usage)

  Options:
  -h, --help  Display this help message and exit.

_EOF_
  return
}
