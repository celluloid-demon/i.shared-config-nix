# Non-reusable, but can be generated with std.sh for a fully-functional script library
# (If it's unique, then it can very well be generated in-line on the main script)

parse() {
  while [[ -n $ARG ]]; do
    case $ARG in
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
