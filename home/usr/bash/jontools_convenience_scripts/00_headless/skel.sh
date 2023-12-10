#!/bin/bash
# ---------------------------------------------------------------------------
# skel.sh - Skeleton script for creating new scripts.

# Usage: skel.sh [-h] [-a] [-b arg_1] [-c arg_2]

# Revision history:
# 2017-11-20 Simplified naming conventions
# 2017-11-18 Converted parsing to getopts
# 2017-11-16 Created by scptgen ver. 3.3
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="0.2"

DID_GETOPTS=false
GETOPTS_OPTSTRING=":ha:b:c:"
ROOT_REQUIRED=false

main()
{
	initialize_script
	watch_signals
	confirm_root
	get_errors "$@"
	get_options "$@"
#	did_getopts
	exit_script
}

# Check for root EUID
confirm_root()
{
	local root_message="$(read_warning --root)"

	if [[ "$ROOT_REQUIRED" == true ]] && (( EUID != 0 )); then
		exit_script --error "$root_message"
	fi
}

# Print usage if getopts was not invoked (getopts is not invoked for mass
# arguments)
did_getopts() {
	[[ "$DID_GETOPTS" == false ]] && get_help
}

# Exit
exit_script()
{
	case $1 in
		# Error exit
		--error )
			echo -e "${PROGNAME}: ${2:-"Unknown Error"}" >&2
			invoke_cleanup
			exit 1
			;;

		# Graceful exit
		* )
			invoke_cleanup
			exit
			;;
	esac
}

# Filter invalid options and missing arguments
get_errors()
{
	# With getops, invalid options don't stop the processing - if we want to
	# stop the script, we have to do it ourselves (exit in the right place).

	# Reset getopts
	OPTIND=1

	while getopts "$GETOPTS_OPTSTRING" opt; do
		case $opt in
		\? )
			exit_script --error "Invalid option: -$OPTARG"
			;;

		: )
			exit_script --error "Option -$OPTARG requires an argument"
			;;
		esac
	done
}

get_help()
{
	local help_message="$(read_help)"
	local root_message="$(read_warning --root)"

	echo "$help_message"

	if [[ $ROOT_REQUIRED = true ]]; then
		echo
		echo "NOTE: $root_message"
	fi
}

# Parse command-line
get_options()
{
	# Reset getopts
	OPTIND=1

	while getopts "$GETOPTS_OPTSTRING" opt; do
		case $opt in
			h )
				get_help
				;;

			a )
				echo "-a was triggered, argument: $OPTARG"
				;;

			b )
				echo "-b was triggered, argument: $OPTARG"
				;;

			c )
				echo "-c was triggered, argument: $OPTARG"
				;;
		esac

		# Print a help/usage message if script is run with no arguments:
		DID_GETOPTS=true
	done
}

# Handle trapped signals
get_signals()
{
	case $1 in
		INT )
			exit_script --error "Program interrupted by user"
			;;

		TERM )
			echo -e "\n$PROGNAME: Program terminated" >&2
			exit_script
			;;

		* )
			exit_script --error "$PROGNAME: Terminating on unknown signal"
			;;
	esac
}

get_warning()
{
	local warning_message="$(read_warning --$1)"

	echo "$warning_message"
}

initialize_script()
{
	local placeholder
}

# Perform pre-exit housekeeping
invoke_cleanup()
{
	return
}

# Help message
read_help()
{
cat <<- _EOF_
$PROGNAME ver. $VERSION
Skeleton script for creating new scripts.

Usage: $PROGNAME [-h] [-a arg_1] [-b arg_2] [-c arg_3]

Options:
-h        Display this help message and exit.
-a arg_1  Do option a.
-b arg_2  Do option b.
-c arg_3  Do option c.
_EOF_
return
}

# Warning messages
read_warning()
{
	case $1 in
		--root )
			echo "You must be the superuser to run this script."
			;;

		* )
			echo "Unknown warning"
			;;
	esac
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
