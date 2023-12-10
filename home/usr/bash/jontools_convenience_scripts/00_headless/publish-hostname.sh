#!/bin/bash
# Change hostname.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hH"
ROOT_REQUIRED=true

SETTINGS="publish-hostname.settings"
HOSTNAME="/etc/hostname"
HOSTS="/etc/hosts"

# todo if you're using this as a command button on webmin w/ parameters,
# you'll want to point to the settings file as a parameter, and have another
# file editor button for the settings file. buttons are nice!

main()
{
	watch_signals
	confirm_root
	get_options "$@"
	exit_script
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

			# Change hostname
			H )
				set_hostname
				# restart_service "systemd-logind.service"
				get_warning --page reboot
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

# ==============================[BEGIN HELP PAGES]==============================

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
Change hostname.

Usage: $PROGNAME [-h] [-H]

Options:
-h        Display this help message and exit.
-H        Publish hostname.
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

# ==============================[PAGE: REBOOT]==============================

# Reboot prompt
reboot )
echo """\
Restart your server for the changes to take effect.
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

# Do we even need this? In most cases, you'll have to restart the OS anyway,
# so a prompt to just do so would probably be better...
restart_service()
{
	local progname

	progname="$1"

	echo "Restarting $progname..."

	systemctl restart "$progname"

	echo "Restarted $progname."
}

# Change hostname
# TODO: for whatever reason the hostnamectl line isn't changing the hosts file
set_hostname_NEW()
{
	local new_hostname

	new_hostname=$(gawk '{ print $1; exit }' $SETTINGS)

	echo "Setting hostname to $new_hostname..."

	hostnamectl set-hostname "$new_hostname"

	echo "New hostname: $new_hostname"
}

# Change hostname
set_hostname()
{
	local old_hostname
	local new_hostname

	old_hostname=$(hostname) # todo run w/ -s option or no? do pass on both?
	new_hostname=$(gawk '{ print $1; exit }' $SETTINGS)

	# We edit two files - /etc/hostname and /etc/hosts.
	echo "Setting hostname to $new_hostname..."
	echo "Editing $(basename $HOSTNAME)..."

	gawk \
	--assign old_hostname="$old_hostname" \
	--assign new_hostname="$new_hostname" \
	--include inplace '
		{
			gsub(old_hostname, new_hostname)
			print
		}
	' "$HOSTNAME"

	echo "Editing $(basename $HOSTS)..."

	gawk \
	--assign old_hostname="$old_hostname" \
	--assign new_hostname="$new_hostname" \
	--include inplace '
		{
			gsub(old_hostname, new_hostname)
			print
		}
	' "$HOSTS"

	echo "New hostname: $new_hostname"
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
