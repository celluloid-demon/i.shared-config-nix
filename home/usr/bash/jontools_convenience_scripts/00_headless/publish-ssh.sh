#!/bin/bash
# Publish changes to SSH server.

PROGNAME="${0##*/}"
VERSION="0.1"

GETOPTS_OPTSTRING=":hp:k:rcx"
ROOT_REQUIRED=true

SSHD_CONFIG="/etc/ssh/sshd_config"
AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"

main()
{
	watch_signals
	confirm_root
	get_options "$@"
	exit_script
}

add_pubkey()
{
	local opt
	local keyfile
	local keyfile_contents

	opt="$1"
	keyfile="$2"
	keyfile_contents="$(cat $keyfile)"

	# Create authorized_keys if it doesn't exist
	mkdir "$HOME/.ssh"
	chmod 700 "$HOME/.ssh"
	touch "$AUTHORIZED_KEYS"
	chmod 600 "$AUTHORIZED_KEYS"

	echo "Adding $(basename $keyfile)..."

	# todo this is appending whether or not the contents already exist...
	# a little messy, but works.
	gawk \
	--assign keyfile_contents="$keyfile_contents" \
	--include inplace '
		BEGIN	{
					content_exists = 0 # 0 used for boolean eval
				}

				$0 ~ keyfile_contents {
					content_exists = 1
				}

				{
					print
				}

		ENDFILE	{
					if (!content_exists) {
						print keyfile_contents
					}
				}
	' "$AUTHORIZED_KEYS"

	echo "Added $(basename $keyfile) to $(basename $AUTHORIZED_KEYS)."
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

# Force the use of SSH keys
disable_passwords()
{
	echo "Disabling password authentication..."

	gawk \
	--assign progname="$PROGNAME" \
	--include inplace '
		/^ *#* *PasswordAuthentication / {
			gsub(/^.*$/, "PasswordAuthentication no # changed by " progname)
		}

		{
			print
		}
	' "$SSHD_CONFIG"

	echo "Disabled password authentication."
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

			# Change SSH port
			p )
				backup_content --file "$SSHD_CONFIG"
				set_port --port "$OPTARG"
				restart_service "sshd.service"
				;;

			# Add SSH key
			k )
				# todo wait, why would you try to backup authorized_keys BEFORE you attempt to make the missing file?
				backup_content --file "$AUTHORIZED_KEYS"
				add_pubkey --keyfile "$OPTARG"
				disable_passwords
				restart_service "sshd.service"
				;;

			# Readme
			r )
				get_help --page readme
				;;

			# Print example config
			c )
				get_help --page config
				;;

			# Extended readme
			x )
				get_help --page readme-ext
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

# ==============================[PAGE: README]==============================

# Readme
readme )
echo """\
$PROGNAME ver. $VERSION

Synopsis:
  This script was made to help setup and secure any SSH server as fast as
  possible. It is NOT a replacement for understanding SSH.

Cheat Sheet:
  [Client] 1. Make SSH config file:
              mkdir \"\$HOME/.ssh\"
              chmod 700 \"\$HOME/.ssh\"
              touch \"\$HOME/.ssh/config\"
              chmod 600 \"\$HOME/.ssh/config\"

  [Server] 2. Change SSH port (choose from the unregistered range of
              49152–65535):
              sudo ./publish-ssh.sh -p <port_number>

  [Router] 3. Forward new port to server.

  [Client] 4. Update config.

  [Client] 5. Make SSH key-pair:
              cd \$HOME/.ssh; ssh-keygen

  [Client] 6. Copy public key to server (via SSH):
              scp [-P port_number] <pubkey> <username>@<hostname | host IP>:~/.ssh/

  [Server] 7. Add public key to authorized_keys:
              sudo ./publish-ssh.sh -k <public_keyfile>

  [Client] 8. Update config.

  [Client] 9. Setup alias (optional):
              alias <alias_name>='ssh <ssh_alias>'
"""
;;

# ==============================[PAGE: EXAMPLE CONFIG]==============================

config )
echo """\
Host shelob
  User sam
  HostName 192.168.1.101
# Port 49152
# IdentityFile \$HOME/.ssh/id_rsa.shelob
"""
;;

# ==============================[PAGE: README EXT]==============================

readme-ext )
echo """\
$PROGNAME ver. $VERSION

Description:
  This script has two functional options: -p, which changes the SSH port
  (optional), and -k, which switches from password authentication to SSH key
  authentication (recommended). Peripheral tasks like restarting the ssh
  server and creating the necessary files (if they don't exist) are automated,
  and the client machine is prompted to make use of these changes in a config
  file like the one displayed below.

  NOTE: A static IP address for your SSH server should be configured before
  attempting to do this.

An example workflow:
  1. CONFIG
  First, we block-in our client's SSH config file to make logging in easier.
  We'll be logging in a couple of times through this process, and having the
  config file means less typing. In the example below, we define the SSH alias
  'shelob' so that we can run 'ssh shelob' without having to type all of our
  custom options.

    (Client machine) To generate your client's SSH config file, run:
    mkdir \"\$HOME/.ssh\"
    chmod 700 \"\$HOME/.ssh\"
    touch \"\$HOME/.ssh/config\"
    chmod 600 \"\$HOME/.ssh/config\"

  You can populate your config file with the example provided below (in this
  example, 'Host shelob' means the alias 'shelob', not the server's hostname):

    Host shelob
      User sam
      HostName 192.168.1.101
    # Port 49152
    # IdentityFile \$HOME/.ssh/id_rsa.shelob

  Later, we can uncomment and set the last two options if we need them.

  2. PORT
  Then, we change the SSH port our server uses, and forward the port on our
  router to our server (unless we want the default 22). Try to pick from the
  unregistered range of 49152–65535 for new SSH ports.

    (Server machine) Run:
    sudo ./publish-ssh.sh -p <port_number>

  This will change the port and restart the SSH service. We forward the port
  on our router, and update our client's config file to reflect this.

  3. SSH KEYS
  Third is SSH key login. For this, we'll generate our key-pair on the machine
  we'll be logging in _from_.

    (Client machine) First, generate your SSH key-pair (in your .ssh
    directory):
    ssh-keygen

    (Client machine) Then, we want to get our public key onto our server:
    scp <pubkey> <username>@<host>:\$HOME/.ssh/

    (Server machine) Finally, we'll append the pubkey's contents to our
    authorized_keys file. We'll also automatically make backup of it, disable
    password authentication, and restart our SSH service:
    sudo ./publish-ssh.sh -k <public_keyfile>

  DO NOT LOG OUT. Now, before you log out of the server, you should test your
  new configuration. Do not disconnect until you confirm that you can
  successfully log in via SSH. We update our client's config file (again) to
  use its new private key for logging in, and do a test login in a new
  terminal.

  4. .BASH_ALIASES
  SSH is already setup, but for the super-lazy, you can make logging in even
  easier by writing a short-hand in your client's .bash_aliases file.

    (Client machine):
    alias ss='ssh shelob'
"""
;;

# ==============================[PAGE: SHORT]==============================

# Default help message
short )
echo """\
$PROGNAME ver. $VERSION
Publish changes to SSH server.

Usage: $PROGNAME [-h] [-p ssh_port] [-k public_keyfile] [-r] [-c]

Options:
-h                 Display this help message and exit.
-p ssh_port        Change server port number.
-k public_keyfile  Switch from password authentication to SSH key authentication.
-r                 Print a more detailed readme to quickly setup SSH.
-c                 Print an example SSH config.
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

	systemctl restart "$progname"

	echo "Restarted $progname."
}

set_port()
{
	local opt
	local port_number

	opt="$1"
	port_number="$2"

	echo "Setting SSH port to $port_number..."

	gawk \
	--assign port_number="$port_number" \
	--assign progname="$PROGNAME" \
	--include inplace '
		/^ *#* *Port / {
			gsub(/^.*$/, "Port " port_number " # 22, changed by " progname)
		}

		{
			print
		}
	' "$SSHD_CONFIG"

	echo "New SSH port: $port_number."
}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Main logic
main "$@"
