# It seems you can use complimentary parsing, to get mixed single-character
# parsing, option argument parsing, double-hyphenated string option parsing,
# and even non-option parsing.

# getopts Cheat Sheet:

# Colon (:) prefix tells it to run in silent error reporting mode.
# Can use mix of upper- and lower-case letters.
# Colon (:) suffix after a letter tells the option to expect an argument.
# Since getopts will set an exit status of FALSE when there's nothing left to
# parse, it's easy to use it in a while-loop.
# getopts parses "$@", but does NOT shift the positional parameters. If you
# want to do that, you'll have to do it manually.

# Here are some points you may consider:

# 1. Invalid options don't stop the processing; If you want to stop the
# script, you have to do it yourself (exit in the right place).

# 2. Multiple identical options are possible; If you want to disallow these,
# you have to check manually (e.g. by setting a variable or so).

# split the following into multiple sub-functions? (eg. parse, parse_opt, parse_sopt, parse_nopt, etc...)
parse() { # Function with complimentary parsing
  while getopts ":h" opt; do
    case $opt in
      h)
        echo "Ran the help_message function." >&2
        exit
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
  done

  # Parsing is split into three parts:
  parse_getopts "$@" # Single-hyphenated option parsing
  parse_string  "$@" # Double-hyphenated option parsing
  parse_nopt    "$@" # Non-hyphenated option parsing
}

parse() {
  parse_base
}

parse_pre() { # Pre-check for anything you might want (like a NOARG statement)
  a=
}

# there's really just single-hyphenated options, double-hyphenated string options, and non-options.
# getopts can catch single-hyphenated options, their errors and their arguments, and
# the while-loop can catch double-hyphenated string options and store non-options.

# Setting up getopts is optional; you only need it if you want to parse mixed
# single-character options and any possible arguments they might have.
parse_getopts() { # getopts parsing for single-character options and their arguments
  while getopts ":h" opt; do
    case $opt in
      h)
        opt_h
        ;;
    esac
  done
}

# takes option string, mybackup -x -f /etc/mybackup.conf -r ./foo.txt ./bar.txt --poop
# in above, -x is an option w/o an argument, and can be parsed in main

# actually, you can just populate sopt here with double-hyphenated strings and non-options, and
# let -* pass the rest to getopts. :)

# what does it look like when a double-hyphenated string option takes an argument?

# mybackup -x -f /etc/mybackup.conf -r ./foo.txt ./bar.txt --poop -dKz

# single-character option parsing (getops)
# mixed single-character option parsing (getopts)
# double-hyphenated string option parsing (while)
# single-character option argument parsing (getopts)
# mixed single-character option argument parsing (getopts)
# double-hyphenated string option argument parsing (while)
# non-option parsing (while: *)

# keep in mind, options WILL repeat unless you manually prevent it (such as exiting)
# it is possible, but inadvisable, to define single-character options here. instead, you should define them in getopts, so you can get them readable in mixed single-character options
# a good (and elegant) use for this function is to have it pass ALL single-hyphenated options to getopts.

# need to make sure that each type of option, even errors, are parsed only once.

# you can define single-character options here, but not for parsing - for filters on errors. (you don't want error-reporting to include things that other parts of the parsing block have read successfully)
parse_string() { # Parsing for double-hyphenated string options and their arguments
  while [[ -n $1 ]]; do
    case $1 in
      --help) # I suppose you can define -h here, but it's much better to define it in getopts, so you can get it readable in mixed single-character options, and you reduce the risk of repeating code. however, getopts needs to have you manually prevent it from repeating optoins, since it's possible, and I suppose this while-loop has the same problem. you should just disable this behavior (by manually forking the code or otherwise) when these options are called.
        opt_h
        ;;
      *) # non-option positional parameters (anything without a flag) gets processed through here (eventually)
        nopt "$1"
      -*) # -* can catch everything else, including errors, mixed single-character options, and single-character options. catch-all plug for getopts
        usage   # any other double-hyphenated string option should result in error.
        error_exit "Unknown option: $1"
        ;;
      --*) # any other double-hyphenated string option should result in error.
        opt_err "$1"
      *) # if cpu-temp-shutdown, then 40 80 should each be parsed separately as positional parameters
        echo "Argument $1 to process..." # Oh, huh... variable non-option parsing!
        temp="a string"
        process_temp "$temp" # really, this should be parse_nopt...
        parse_nopt "$1"
        ;;
    esac
    shift
  done
}

parse() { # Basic parsing
  while [[ -n $1 ]]; do
    case $1 in
      -h | --help) # single-letters should be set here to prevent them from registering as errors in this block
        opt_h
        ;;
      --*) # any other double-hyphenated string option should result in error.
        opt_err "$1"
      -*) # another word for '*' is "leftover," so this must come AFTER all other possible choices are exhausted! (you don't want this to be processed "before" a "valid" option is triggered)
        parse_complex "$1" # so if valid single-character options are combined, they won't be discovered here, and must be passed to getopts for additional parsing. rather than report an error, this treats all single-hyphenated strings that haven't been defined as possible mixed single-character option strings, and passes them on to getopts to let it decide. (this means that error-reporting for invalid single-character options MUST be reported in getopts)
        ;;
      *)
        nopt "$1"
        ;;
    esac
    shift
  done
}

parse_complex() { # Complex parsing of single-hyphenated option strings
  while getopts ":h" opt; do
    case $opt in
      h)
        opt_h
        ;;
      \?)
        opt_err "$opt"
        ;;
    esac
  done
}

parse_nopt() { # this will run once each time it is invoked from parse_main as *; it should process $1
  # here, a for-loop would go through a single positional parameter for as many times as is needed by the program, which can be configured here by the user by shanging the number of times the loop repeats (it can repeat as often as there are non-option positional parameters); it will then stuff them into variables, because these things are normally directories, filenames or limit numbers. later, if they need to be called on, then the functions can do so by calling on the standard variables (with non-options) that this function assigns.
  nopt "$1"
}

# option block? plug them into appropriate functions for parsing.
# this will reduce redundant option code between parsing blocks.
# there's an understanding that options don't take multiple arguments.

# there's also an understanding that arguments should be optional. this is
# because a default behavior should be employed, so that when arguments are
# omitted, the default behavior can kick in, if a default behavior is desired.
nopt()    { echo "Non-option given: $1";  } # you can impose a limit on how many nopt's you store here with a variable limit in a hard-coded FOR loop, whch can initially be set to whatever the number of nopt's is (set an arithmetic counter! it will end when (main) parsing is done, and post-processing will handle the nopt parsing loop).
opt_a()   { echo "Option $opt activated!" }
opt_b()   { echo "Option $opt activated!" }
opt_c()   { echo "Option $opt activated!" }
opt_h()   { help_message; graceful_exit }
opt_j()   { echo "Option $opt activated! Argument given: $arg" }
opt_p()   { echo "Poop." }
opt_q()   { echo "The quiet mode flag doesn't do anything, yet."; quiet_mode="yes" }
opt_err() { usage; error_exit "Unkown option: $1" }

opt_w() { echo "Warning set to: $1" }
opt_s() { echo "Shutdown set to: $1" }

error_exit() {
  echo "error_exit hasn't been completed, yet. Exiting normally..."
  exit
}

help_message() {
  echo "The help_message function doesn't do anything, yet."
}

graceful_exit() {
  echo "graceful_exit not completed, yet. Exiting normally..."
  exit
}

# (The idea here is that the previous sub-functions are setting variables for this to work with.)
parse_proc() { # Post-processing for options
  a=
}

parse_getopts_example() {
  while getopts ":ha:" opt; do
    case $opt in
      h)
        echo "Ran the help_message function." >&2
        exit
        ;;
      a)
        echo "-a was triggered, Parameter: $OPTARG" >&2
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
  done

  # you can put this in a while loop, for as many parameters as you have,
  # until they're gone (makes this easier to copy & paste)
  parse_getopts_example_do_stuff "$1"
  parse_getopts_example_do_stuff "$2"
}

parse_getopts_example_do_stuff() {
  echo "$1"
}
