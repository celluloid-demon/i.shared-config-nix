#!/bin/bash
# Publish static IP address.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hig"
ROOT_REQUIRED=true

SETTINGS="publish-interface.settings"
INTERFACES="/etc/network/interfaces"

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

# Make backup copy if one doesn't already exist
backup_content() {
	local opt
	local file_name

	opt="$1"
	file_name="$2"

	case $opt in
		--file )
			cp --no-clobber --verbose "$file_name" "$file_name.BAK"
			;;
	esac
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

# todo you could stand to cleanup some of this awk script...
edit_interfaces()
{
	local interface
	local address
	local netmask
	local gateway
	local dns_nameservers

	interface=$(gawk '/^ *iface/ {print $2; exit}' $SETTINGS)
	address=$(gawk '/^ *address/ {print $2; exit}' $SETTINGS)
	netmask=$(gawk '/^ *netmask/ {print $2; exit}' $SETTINGS)
	gateway=$(gawk '/^ *gateway/ {print $2; exit}' $SETTINGS)
	dns_nameservers=$(gawk '/^ *dns-nameservers/ {print $2, $3; exit}' $SETTINGS)

	echo "Editing $(basename $INTERFACES)..."

	gawk \
	--assign interface="$interface" \
	--assign address="$address" \
	--assign netmask="$netmask" \
	--assign gateway="$gateway" \
	--assign dns_nameservers="$dns_nameservers" \
	--include inplace '
		BEGIN {
			nr_iface   = 0 # 0 used for boolean eval
			nr_address = 0
			nr_netmask = 0
			nr_gateway = 0
			nr_dns     = 0

			ignore_main_print = 0 # ignore main print statement if we get a dhcp hit
		}

		/^ *iface *'$interface' *inet *static/ {
			if (!nr_iface) {
				nr_iface = NR
			}
		}

		/^ *address/ {
			if ((nr_iface) && (!nr_address)) {
				nr_address = NR
			}

			if (NR == nr_address) {
				gsub(/address.*$/, "address '"$address"'")
			}
		}

		/^ *netmask/ {
			if ((nr_iface) && (!nr_netmask)) {
				nr_netmask = NR
			}

			if (NR == nr_netmask) {
				gsub(/netmask.*$/, "netmask '"$netmask"'")
			}
		}

		/^ *gateway/ {
			if ((nr_iface) && (!nr_gateway)) {
				nr_gateway = NR
			}

			if (NR == nr_gateway) {
				gsub(/gateway.*$/, "gateway '"$gateway"'")
			}
		}

		/^ *dns-nameservers/ {
			if ((nr_iface) && (!nr_dns)) {
				nr_dns = NR
			}

			if (NR == nr_dns) {
				gsub(/dns-nameservers.*$/, "dns-nameservers '"$dns_nameservers"'")
			}
		}

		# Important to do the dhcp check AFTER the static check
		/^ *iface *'$interface' *inet *dhcp/ {
			gsub(/dhcp/, "static")
			print
			print "address '"$address"'"
			print "netmask '"$netmask"'"
			print "gateway '"$gateway"'"
			print "dns-nameservers '"$dns_nameservers"'"

			ignore_main_print = 1
		}

		# Our workflow ordinarily is to print our line streams in a final
		# print statement. However, the dhcp line statement above prints extra
		# lines that actually need to be printed AFTER the original stream; so
		# to print them in the correct order, we temporarily disable the
		# default print statement so that we can print our original line
		# stream FOLLOWED BY our extra lines.

		{
			if (!ignore_main_print) {
				print
			}

			if (ignore_main_print) {
				ignore_main_print = 0
			}
		}
	' "$INTERFACES"

	echo "Done."
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

# Flush old settings
flush_address()
{
	local interface

	interface=$(gawk '/^ *iface/ {print $2; exit}' $SETTINGS)

	echo "Flushing address for $interface..."

	ip addr flush "$interface"

	echo "Done."
}

get_interface()
{
	ip route get 1 | gawk '
		{
			print $5
			exit
		}
	'
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

			i )
				backup_content --file "$INTERFACES"
				edit_interfaces
				flush_address
				restart_service "networking.service"
				;;

			g )
				get_interface
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
Publish static IP address.

Usage: $PROGNAME [-h] [-i] [-g]

Options:
-h        Display this help message and exit.
-i        Enable static IP and publish interface changes.
-g        Print name of interface.
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

restart_service()
{
	local progname

	progname="$1"

	echo "Restarting $progname..."

	# Restarting network service: newer 16.04 implementation
	systemctl restart "$progname"

	echo "Restarted $progname."
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
