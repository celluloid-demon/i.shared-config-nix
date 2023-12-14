#!/bin/bash
# Download and install the latest versions of build-essential, automake,
# checkinstall, cvs, subversion, git-core and mercurial, primarily for
# building on Ubuntu.

PROGNAME="${0##*/}"
VERSION="0.1"
SCPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GETOPTS_OPTSTRING=":hir"
ROOT_REQUIRED=true

ORIGINAL_IFS="$IFS"

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
		root_message="$(get_warning --page=ROOT)"

		exit_script --error="$root_message"
	fi
}

# Exit
exit_script()
{
	local opt
	local error_message

	opt="$@"

	for i in "$opt"; do
	case $i in
		# Error exit
		-e=* | --error=* )
			error_message="${i#*=}"
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
	done
}

# Help
get_help()
{
	local opt
	local help_message
	local page_name

	opt="$@"

	for i in "$opt"; do
	case $i in
		# Display a help page
		-p=* | --page=* )
			page_name="${i#*=}"

			help_message="$(read_help $page_name)"
			;;

		# Default help message
		* )
			help_message="$(read_help SHORT)"
			;;
	esac
	done

	echo "$help_message"
}

# Parse command-line
get_options()
{
	# With getops, invalid options don't stop the processing - if we want to
	# stop the script, we have to do it ourselves (exit in the right place).
	while getopts "$GETOPTS_OPTSTRING" i; do
	case $i in
		\? )
			exit_script --error="Invalid option: -$OPTARG"
			;;

		: )
			exit_script --error="Option -$OPTARG requires an argument"
			;;
	esac
	done

	# Reset getopts
	OPTIND=1

	# Parse options
	while getopts "$GETOPTS_OPTSTRING" i; do
	case $i in
		# Help message
		h )
			get_help
			;;

		# Install packages
		i )
			update_package "build-essential automake checkinstall cvs subversion git-core mercurial"
			;;

		# Readme
		r )
			get_help --page=README
			;;
	esac
	done
}

# Handle trapped signals
get_signals()
{
	local opt

	opt="$@"

	for i in "$opt"; do
	case $i in
		INT )
			exit_script --error="Program interrupted by user"
			;;

		TERM )
			echo -e "\n$PROGNAME: Program terminated" >&2
			exit_script
			;;

		* )
			exit_script --error="$PROGNAME: Terminating on unknown signal"
			;;
	esac
	done
}

# Print warnings
get_warning()
{
	local opt
	local page_name
	local warning_message

	opt="$@"

	for i in "$opt"; do
	case $i in
		# Display a specific warning
		-p=* | --page=* )
			page_name="${i#*=}"

			warning_message="$(read_warning $page_name)"

			# shift # past argument=value
			;;

		# Default warning message
		* )
			warning_message="$(read_warning SHORT)"

			# shift # unknown option # todo do you really need the shift statements in your script?
			;;
	esac
	done

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

opt="$@"

for i in "$opt"; do
case $i in

# Default help message
SHORT )
echo """\
$PROGNAME ver. $VERSION
Download and install the latest versions of build-essential, automake,
checkinstall, cvs, subversion, git-core and mercurial, primarily for building
on Ubuntu.

Usage: $PROGNAME [-h] [-i] [-r]

Options:
-h        Display this help message and exit.
-i        Install packages.
-r        Display readme.
"""

# Append a note to the default help message if the script requires root
# privileges.
if [[ $ROOT_REQUIRED = true ]]; then
	local root_message="$(get_warning --page=ROOT)"

	echo "NOTE: $root_message"
fi
;;

# Readme
README )
echo """\
$PROGNAME ver. $VERSION

Why would you want to compile your own software?
1) To add your own functionality
2) To install the latest version, which repos often miss
3) To have fun!

Packages this script installs:
  automake          generate makefiles
  build-essential   Ubuntu meta-package, contains c-compiler, make, other nice things
  checkinstall      adds software we compile ourselves to the package manager list for easy uninstallation
  cvs               version-control software
  git-core          version-control software
  mercurial         version-control software
  subversion        version-control software

After you install your build packages, you'd ordinarily run the configure
script for configuring makefiles that comes included with most open source
packages.

Example worlflow:
  Download tarball via wget
  Unzip the tarball via tar -zxf <file>
  CD into the folder you made
  Look for files called: INSTALL, README, SETUP, or similar
  Run included configure shell script
  Address any warnings or errors, look at config.log if configure failed
  Compile it via make
  make install or checkinstall

Example build:
  ./configure        # generate makefiles
  make               # compiles using makefile
  sudo make install  # install

Alternative build (with checkinstall):
  ./configure
  make
  sudo checkinstall  # install and add to package manager for easy uninstallation

And remember: Troubleshooting is a part of compiling, because you will run
into problems (stackoverflow threads can be your best friend)!
"""
;;

# Missing page
* )
echo """\
Unknown page
"""
;;

esac
done

}

# Warning messages
read_warning()
{
local opt

opt="$@"

for i in "$opt"; do
case $i in

# Root required
ROOT )
echo """\
You must be the superuser to run this script.
"""
;;

# Missing page
SHORT | * )
echo """\
Unknown warning
"""
;;

esac
done

}

# Trap signals
watch_signals()
{
	trap "get_signals TERM" TERM HUP
	trap "get_signals INT" INT
}

# Update package
update_package()
{
	local package_list

	package_list="$@"

	apt-get update
	apt-get install "$package_list"
}

# Main logic
main "$@"
