#!/bin/bash
# Update/install the latest version of Docker.

# Uninstall the Docker CE package:
#   apt-get purge docker-ce

# Images, containers, volumes, or customized configuration files on your host
# are not automatically removed. To delete all images, containers, and
# volumes:
#   rm -rf /var/lib/docker

# You must delete any edited configuration files manually.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hd"
ROOT_REQUIRED=true

SOURCES_LIST="/etc/apt/sources.list"

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

	echo "Setting up repository over HTTPS..."

	apt-get update
	apt-get install \
		apt-transport-https \
		ca-certificates \
		curl \
		software-properties-common

	echo "Adding repository..."

	# todo why aren't we using the add-apt-repository method?

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

			# Install docker
			d )
				add_key --web "https://download.docker.com/linux/ubuntu/gpg"
				add_repo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
				update_package "docker-ce"
				get_help --page verify
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
Update/install Docker.

Usage: $PROGNAME [-h] [-r]

Options:
-h        Display this help message and exit.
-d        Install the latest version of Docker Community Edition.
"""

# Append a note to the default help message if the script requires root
# privileges.
if [[ $ROOT_REQUIRED = true ]]; then
	local root_message="$(get_warning --page root)"

	echo "NOTE: $root_message"
fi
;;

# ==============================[PAGE: VERIFY]==============================
verify )
echo """\
Verify that Docker CE is installed correctly by running the hello-world image:
> sudo docker run hello-world

This command downloads a test image and runs it in a container. When the
container runs, it prints an informational message and exits. If you would
like to use Docker as a non-root user, you should now consider adding your
user to the \"docker\" group. Remember that you will have to log out and back
in for this to take effect!

WARNING: Adding a user to the "docker" group will grant the ability to run
         containers which can be used to obtain root privileges on the
         docker host.
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
