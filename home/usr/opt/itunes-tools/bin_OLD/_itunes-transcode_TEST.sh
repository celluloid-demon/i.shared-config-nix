#!/bin/bash

			# *****************************
			# *     RANDOM EXPERIMENT     *
			# *****************************

# When you start a Screen session in detached mode (screen -d -m), no window
# is selected, so input later sent with 'screen -X stuff' is just lost. You
# need to explicitly specify that you want to send the keystrokes to window 0
# (-p 0). This is a good idea anyway, in case you happen to create other
# windows in that Screen session for whatever reason.

# Note: Triple-quoting like this seems to work best when it isn't indented all
# to hell. Also note that we're clearing the screen sessions's window before
# we start running commands inside it, just cause it looks nicer (screen can
# start a session w/ the prompt in a weird place).
# screen -S transcode -p 0 -X stuff """\
# set -e; \
# clear; \
# batch-transcode-video \
# $_debug_opt \
# --input \"$indir\" \
# --output \"$outdir\" \
# --force \"0:0:0:0\" \
# -- \
# $_dry_run_opt \
# $_chapter_opt \
# $_container_opt \
# $_max_height_opt \
# --add-audio all \
# --audio-width main=double \
# --audio-width other=surround \
# --add-subtitle all \
# --handbrake-option encoder=x265
# """
# Note: VERY important that last line in quoted code block does NOT have a
# trailing backslash (the carriage return tells the command to run)!

			# local _PID
			# local _counter

			# _counter=40 # countdown 40 * sleep interval 0.25 = 10 sec total

			# while (( _counter >=  0 )); do

			# 	# sleep interval
			# 	sleep 0.25

			# 	# decrement counter
			# 	(( _counter-=1 ))

			# 	# print the latest update to _counter
			# 	# echo "$_counter"

			# 	# ask for PID
			# 	set +e
			# 	_PID=$(pgrep batch-transcode-video)
			# 	set -e

			# 	# break loop if _PID is a valid integer
			# 	if [[ "$_PID" =~ ^-?[0-9]+$ ]]; then

			# 		break

			# 	fi

			# done

			# exit on error if counter ran out (10 seconds have passed w/ no
			# PID, so we assume batch-transcode-video did not run
			# successfully)
			# if (( _counter <= 0 )); then

			# 	write_host --error="No good, timer ran out."
			# 	exit_script --error

			# fi

			# If batch-transcode-video exited on error and wasn't running,
			# pgrep in this instance would exit on error, halting the script
			# unless we unset our errexit shell option here.
			# set +e
			# _PID=$(pgrep batch-transcode-video)
			# set -e

			# If we got this far, it means we found a PID for batch-transcode-
			# video in our 10-sec window.
			# echo "Transcode job started, PID: $_PID"

			# Exit on error if _PID is not a valid integer (transcode didn't
			# start, or exited on error, and didn't set _PID as we expect)
			# if [[ ! "$_PID" =~ ^-?[0-9]+$ ]]; then

				# write_host --error="No good, bad PID."
				# exit_script --error

			# fi

			# Emulate 'wait PID' on non-child process, before post-processing
			# while [[ "$(pgrep batch-transcode-video)" = "$_PID" ]]; do

			# 	# echo "$(pgrep batch-transcode-video)"
			# 	sleep 1

			# done
