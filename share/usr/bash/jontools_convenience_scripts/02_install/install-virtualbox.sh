#!/bin/bash
# Update/install VirtualBox, the VirtualBox extension pack and phpVirtualBox.

# NOTE: The syntax for update_extpack() may need to be periodically updated -
# run a test 'vboxmanage -v' to check for the up-to-date syntax.

# todo graft the option-parsing and extension pack installation here onto
# install-virtualbox.sh?

# todo make a note about this: if your attempt to start an imported vm is
# failing w/ the message "Failed to open a session for the virtual machine /
# The virtual machine has terminated unexpectedly during startup with exit
# code 1 (0x1)", even after a reboot, and you recently upgraded to a new
# version of virtualbox, you may also get the error message "The VirtualBox
# kernel modules do not match this version of VirtualBox. The installation of
# VirtualBox was apparently not successful. Executing '/sbin/vboxconfig' may
# correct this. Make sure that you do not mix the OSE version and the PUEL
# version of VirtualBox." Essentially this means that the installed vbox
# support driver doesn't match the version of the vbox user.

# Alternatively, you could purge and reinstall VirtualBox using these
# commands:

# apt-get purge virtualbox virtualbox-dkms virtualbox-ose-qt virtualbox-qt # (basically any virtualbox* package)
# apt-get install virtualbox virtualbox-dkms

# todo make additional note about not forgetting to install Guest Additions on
# vm! There are dependencies that vboc will most likely complain about if
# missing.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hvep"
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

	echo "Adding repository..."

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

# Check if Virtual Box is installed before we install extention pack, else
# exit and print message
confirm_vbox()
{
	if which VBoxManage >/dev/null; then
		echo "Virtual Box installed."
	else
		exit_script --error "Virtual Box not installed."
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

			v )
				# update_vbox
				add_repo "deb http://download.virtualbox.org/virtualbox/debian xenial contrib"
				add_key --web "https://www.virtualbox.org/download/oracle_vbox_2016.asc"
				update_package "dkms"
				update_package "virtualbox-5.2"
				;;

			e )
				confirm_vbox
				update_extpack
				;;

			p )
				# confirm_vbox
				# add_repo "deb https://download.webmin.com/download/repository sarge contrib"
				# add_key --web "http://www.webmin.com/jcameron-key.asc"
				update_phpvbox
				# update_package "phpvirtualbox"
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
Update/install VirtualBox, the VirtualBox extension pack and phpVirtualBox.

Usage: $PROGNAME [-h] [-v] [-e] [-p]

Options:
-h        Display this help message and exit.
-v        Install the latest version of VirtualBox.
-e        Install the matching version of the VirtualBox Extension Pack.
-p        Install the latest version of phpVirtualBox.
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

update_extpack()
{
	local version="$(vboxmanage -v)"
	local   build="$(echo $version | cut -d '_' -f 1)"
	local release="$(echo $version | cut -d 'r' -f 2)"
	local    file="Oracle_VM_VirtualBox_Extension_Pack-$build-$release.vbox-extpack"
	local     web="http://download.virtualbox.org/virtualbox/$build/$file"
	local extpack="Oracle VM VirtualBox Extension Pack"

	# Download the latest version of the extension pack
	wget "$web" -O "/tmp/$file"

	# If wget doesn't find the extension pack, we exit on error
	if [ $? -eq 0 ]; then
		local placeholder
	else
		exit_script --error "Failed to download file. Is the URL correct?"
	fi

	# Uninstall the old version and install the new one
	VBoxManage extpack uninstall "$extpack"
	VBoxManage extpack install "/tmp/$file"

	# Cleanup tmp files
	rm "/tmp/$file"

	# Confirm installed
	VBoxManage list extpacks
}

update_package()
{
	local package="$1"

	apt-get update
	apt-get install "$package"
}

update_phpvbox()
{
	# "Upgrading" phpVirtualBox is as easy as copying the files of the new
	# "version over the old installation.

	local dir="/usr/share/phpvirtualbox"
	# local web="https://github.com/phpvirtualbox/phpvirtualbox/archive/master.zip"
	local web="https://github.com/phpvirtualbox/phpvirtualbox/archive/develop.zip"
	local file="$(echo $web | gawk --field-separator '/' '{print $NF}')"

	# Rather than make a new directory, we rely on the archive's top folder
	# and rename it to phpvirtualbox.
	# mkdir --parents "$dir"

	# Update headers for virtualbox.
	apt-get install linux-headers-$(uname -r) build-essential virtualbox-5.1 dkms

	# Update tools and get some php dependencies that don't come with LAMP.
	apt-get install apache2 libapache2-mod-php7.0 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libapr1 php7.0-common php7.0-mysql php7.0-soap php-pear wget

	wget "$web"

	unzip "$file"

	# Overwrite the previous phpVirtualBox installation.
	rm --recursive "/usr/share/phpvirtualbox"
	mv "phpvirtualbox-develop" "/usr/share/phpvirtualbox"

	# Template-out a new config file if one doesn't already exist.
	cp --no-clobber "$dir/config.php-example" "$dir/config.php"

	# Update our conf file.
	cp --no-clobber "$dir/phpvirtualbox.conf" "/etc/apache2/conf-available/"

	# TODO: Edit our conf file (the default config file makes phpvirtualbox
	# only accessible from the localhost for security reasons). If we find
	# 'Require local', make sure it's commented-out.
	gawk \
	--include inplace '
		/^.*Require local/ {
			gsub(/^.*$/, "# Require local")
		}

		{
			print
		}
	' "/etc/apache2/conf-available/phpvirtualbox.conf"

	# Enable our conf file.
	a2enconf phpvirtualbox
	service apache2 reload

	echo "Config: /usr/share/phpvirtualbox/config.php"
	echo "Default login is username: admin password: admin"
}

# todo delete this
update_vbox()
{
	# The dkms package ensures that the VirtualBox host kernel modules are
	# properly updated if the Linux kernel version changes.

	# Addendum: As of VirtualBox 5.1, dkms is no longer required!

	apt-get update
	# apt-get install dkms
	apt-get install virtualbox
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
