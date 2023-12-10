#!/bin/bash
# Setup Grub2 to automatically boot after a power failure.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hgr"
ROOT_REQUIRED=true

GRUB="/etc/default/grub"
HEADER="/etc/grub.d/00_header"
LINUX="/etc/grub.d/10_linux"

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

edit_grub()
{
	echo "Editing $(basename $GRUB)..."

	# We ask if the GRUB_RECORDFAIL_TIMEOUT option exists - if not, we append
	# and set it, and if yes (whether or not it's commented), then we just set
	# it.
	gawk \
	--assign progname="$PROGNAME" \
	--include inplace '
		BEGIN	{
					option_exists = 0 # 0 used for boolean eval
				}

				/^ *#* *GRUB_RECORDFAIL_TIMEOUT=/ {
					option_exists = 1

					gsub(/GRUB_RECORDFAIL_TIMEOUT=.*$/, "GRUB_RECORDFAIL_TIMEOUT=2 # changed by " progname)
				}

				{
					print
				}

		ENDFILE	{
					if (!option_exists) {
						print "GRUB_RECORDFAIL_TIMEOUT=2 # changed by " progname
					}
				}
	' "$GRUB"

	echo "Done."
}

edit_header()
{
	# Since we're only interested in changing the FIRST "set timeout" line
	# AFTER the inline definition for make_timeout(), we get the first line
	# number for "set timeout" FOLLOWING the first line number for
	# make_timeout(), and run gsub only on that line.
	echo "Editing $(basename $HEADER)..."

	gawk \
	--assign progname="$PROGNAME" \
	--include inplace '
		BEGIN	{
					line_a = 0 # 0 used for boolean eval
					line_b = 0 # 0 used for boolean eval
				}

				/^ *make_timeout *()/ {
					if (!line_a) {
						line_a = NR
					}
				}

				/^ *set timeout=/ {
					if ((line_a) && (!line_b)) {
						line_b = NR
						gsub(/set timeout=.*$/, "set timeout=2 # changed by " progname)
					}
				}

				{
					print
				}
	' "$HEADER"

	echo "Done."
}

edit_linux()
{
	# Just look for everytime we set linux_gfx_mode and swap in our value.
	echo "Editing $(basename $LINUX)..."

	gawk \
	--assign progname="$PROGNAME" \
	--include inplace '
		/^ *set linux_gfx_mode=/ {
			gsub(/set linux_gfx_mode=.*$/, "set linux_gfx_mode=keep # changed by " progname)
		}

		{
			print
		}
	' "$LINUX"

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

			g )
				backup_content --file "$GRUB"
				edit_grub
				update_grub
				backup_content --file "$HEADER"
				edit_header
				update_grub
				backup_content --file "$LINUX"
				edit_linux
				update_grub
				;;

			r )
				get_help --page readme
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
Setup Grub2 to automatically boot after a power failure.

Usage: $PROGNAME [-h] [-g]

Options:
-h        Display this help message and exit.
-g        Edit Grub files and rebuild Grub cfg.
"""

# Append a note to the default help message if the script requires root
# privileges.
if [[ $ROOT_REQUIRED = true ]]; then
	local root_message="$(get_warning --page root)"

	echo "NOTE: $root_message"
fi
;;

# ==============================[PAGE: README]==============================

readme )
echo """\
$PROGNAME ver. $VERSION

================================[WARNING]===================================

This script grounds its text analysis in the assumption that it's dealing with
brand new, default Grub files - specifically, its search patterns do not
account for changes made by this script or the sys admin. Thus, if you run
this script more than once, your system WILL BE UNBOOTABLE.

Have your favorite boot repair utility handy when running this script, review
the changes to your Grub files (this script comments each line it changes w/
\"changed by config-grub.sh\"), and immediately test-boot (one clean shutdown,
one clean reboot, and - the real test - one \"power failure\" by unplugging
your machine).

============================================================================

GRUB_TIMEOUT, GRUB_RECORDFAIL_TIMEOUT, timeout values:
  1. For -1, there will be no countdown and thus the menu will display.
  2. For 0, menu will not display even for a failed startup.
  3. For >=1, menu will display for the specified number of seconds.

This mostly works by customizing /etc/default/grub with a new
GRUB_RECORDFAIL_TIMEOUT entry.

In some cases the trick with GRUB_RECORDFAIL_TIMEOUT doesn't work. In such a
case, we edit /etc/grub.d/00_header and change the value of timeout in the
make_timeout () function (around line 333).

The above change, however, still causes GRUB2 to boot into text graphics mode.
Thus, an additional change is required, and we edit /etc/grub.d/10_linux and
set all instances of linux_gfx_mode to linux_gfx_mode=keep.
"""
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

# Update grub cfg
update_grub()
{
	# This is literally here to make the get_options() case statement look
	# nicer - the script author's OCD can't handle a command call that uses a
	# dash while the rest of its buddies are using underscores.

	# Grub needs to rebuild its cfg in order to reflect our changes.
	update-grub
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
