#!/bin/bash
# Update/install the latest version of Resilio Sync.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hr"
ROOT_REQUIRED=true

SOURCES_LIST="/etc/apt/sources.list.d/resilio-sync.list"

main()
{
	watch_signals
	confirm_root
	get_options "$@"
	exit_script
}

# Add GPG key
add_key()
{
	local opt
	local web
	local key

	opt="$1"

	case $opt in
		--web )
			web="$2"
			key="$(echo $web | gawk --field-separator '/' '{print $NF}')"

			echo "Connecting to $web..."
			wget "$web"

			echo "Adding $key..."
			apt-key add "$key"

			echo "Added $key."
			;;
	esac
}

add_repo()
{
	local repo="$1"

	echo "Adding repository..."

	# Add sources.list file if it doesn't exist
	touch "$SOURCES_LIST"

	# We ask if our repo exists - if not, we append, and if yes, then we just
	# make sure it isn't commented.
	gawk \
	--assign progname="$PROGNAME" \
	--assign repo="$repo" \
	--include inplace '
		BEGIN	{
					repo_exists = 0 # 0 used for boolean eval
				}

				$0 ~ repo {
					repo_exists = 1

					gsub(/^.*$/, repo)
				}

				{
					print
				}

		ENDFILE	{
					if (!repo_exists) {
						print repo
					}
				}
	' "$SOURCES_LIST"

	echo "Done."
}

# Check for root EUID
confirm_root()
{
	local root_message

	if [[ "$ROOT_REQUIRED" == true ]] && (( EUID != 0 )); then
		root_message="$(get_warning --page root)"

		exit_script --error "$root_message"
	fi
}

# Exit
exit_script()
{
	local opt
	local error_message

	opt="$1"

	case $opt in
		# Error exit
		--error )
			error_message="${2:-"Unknown Error"}"
			echo -e "${PROGNAME}: $error_message" >&2
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

# Help
get_help()
{
	local opt
	local help_message
	local page_name

	opt="$1"

	case $opt in
		# Display a help page
		--page )
			page_name="$2"

			help_message="$(read_help --page ${page_name:-short})"
			;;

		# Default help message
		* )
			help_message="$(read_help --page short)"
			;;
	esac

	echo "$help_message"
}

# Parse command-line
get_options()
{
	# With getops, invalid options don't stop the processing - if we want to
	# stop the script, we have to do it ourselves (exit in the right place).
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

	# Reset getopts
	OPTIND=1

	while getopts "$GETOPTS_OPTSTRING" opt; do
		case $opt in
			# Help message
			h )
				get_help
				;;

			# Install resilio
			r )
				add_repo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free"
				add_key --web "https://linux-packages.resilio.com/resilio-sync/key.asc"
				update_package "resilio-sync"
				;;
		esac
	done
}

# Handle trapped signals
get_signals()
{
	local opt

	opt="$1"

	case $opt in
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

# Print warnings
get_warning()
{
	local warning_message
	local page_name
	local opt

	opt="$1"

	case $opt in
		# Display a specific warning
		--page )
			page_name="$2"

			warning_message="$(read_warning --page ${page_name:-short})"
			;;

		# Default warning message
		* )
			warning_message="$(read_warning --page short)"
			;;
	esac

	echo "$warning_message"
}

# Perform pre-exit housekeeping
invoke_cleanup()
{
	return
}

# Help pages
read_help()
{
local opt
local page_name

page_name="${2:-short}"

# We kind of skip a step here and ignore $opt, since it's just objectively
# cleaner to look at only the page name.
case $page_name in

# ==============================[PAGE: SHORT]==============================

# Default help message
short )
echo """\
$PROGNAME ver. $VERSION
Update/install Resilio Sync.

Usage: $PROGNAME [-h] [-r]

Options:
-h        Display this help message and exit.
-r        Install the latest version of Resilio Sync.
"""

# Append a note to the default help message if the script requires root
# privileges.
if [[ $ROOT_REQUIRED = true ]]; then
	local root_message="$(get_warning --page root)"

	echo "NOTE: $root_message"
fi
;;

# ==============================[PAGE: UNKNOWN]==============================

# Missing page
* )
echo """\
<Unknown page>.
"""
;;
esac
}

# ==============================[END HELP PAGES]==============================

# ==============================[BEGIN WARNING PAGES]==============================

# Warning messages
read_warning()
{
local opt
local page_name

page_name="${2:-short}"

# We kind of skip a step here and ignore $opt, since it's just objectively
# cleaner to look at only the page name.
case $page_name in

# ==============================[PAGE: ROOT]==============================

# Root required
root )
echo """\
You must be the superuser to run this script.
"""
;;

# ==============================[PAGE: SHORT, UNKNOWN]==============================

# Missing page
short | * )
echo """\
Unknown warning
"""
;;
esac
}

# ==============================[END WARNING PAGES]==============================

update_package()
{
	local package="$1"

	apt-get update
	apt-get install "$package"
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
