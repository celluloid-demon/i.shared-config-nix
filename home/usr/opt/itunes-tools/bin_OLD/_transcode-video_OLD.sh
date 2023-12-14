#!/bin/bash
# convert-videos
# Script to run handbrake recursively through a folder.

# This uses the find command to traverse recursively through a directory
# structure. It will place the transcoded file in the same folder as its
# source and change its extension to ".mp4".

# NOTE: No spaces allowed in subfolder or device names!

# Usage: handbrakefolder.sh [FOLDER]
#   Run handbrake on all the files contained in [FOLDER]. (the current directory
#   by default)

# Change this to specify a different handbrake preset. You can list them by
# running: "HandBrakeCLI --preset-list"

# This method focuses on simplicity, scope and maintainability - the lines are
# short, and aim to encode ALL titles a DVD has to offer, so nothing is missed
# in automation. The philosophy of this script is to let Handbrake do what
# it's good at, which is batch-encoding a huge list of files, and let the
# human do what it's good at, which is checking video quality and identifying
# redundant streams to mark for deletion. For this, a manual post-processing
# step is involved in culling extra titles and audio/subtitle streams in
# MKVToolNix. Post-processing should also ensure that the encoded video files
# reflect all available titles on the source device.

# An accepted limitation of letting Handbrake iterate through all titles with
# abandon like this is that images with episodes on them will typically have
# their episodes listed under a single master title in addition to per-episode
# titles, essentially double-listing the episodes, so these images can take
# twice as long to render and the master titles will need to be manually
# deleted in post-processing. A possible workaround is to detect the longest
# title in a device and exclude that title - such a workaround would need to
# know whether it was looking at a film or a tv show.

PRESETDIR="$HOME/BTSync/shared-config/assets/home/opt/HandBrakeCLI/presets"
PRESETFILE="H.265_MKV_480pmax30_PASSTHRU_v1.json"
PRESET="H.265 MKV 480pmax30_PASSTHRU_v1"

INDIR=""
OUTDIR="$HOME/Desktop/HandbrakeH265_Videos"

EXT="mkv"

mkdir -p "$OUTDIR"

# NOTE: No spaces!
if [ -z "$1" ]; then
    INDIR="."
else
    INDIR="$1"
fi

device_array=$(find "$INDIR"/* -type f) # NOTE: No spaces!

for device in $device_array; do

	# It's worth noting that if you want the rawout + count values to be right,
	# you'll need to pass --min-duration 0 to HandBrakeCLI, otherwise you'll come
	# up short on some DVDs. For example, a test DVD can have a 10 second track 1
	# that will be ignored in the final output.

	# Edit: With the new way of counting titles, is the above note relevant anymore?

	rawout=$(HandBrakeCLI --min-duration 0 -i "$device" --title 0 2>&1 >/dev/null) # redirect stderr
	# only one of the following title_total_* vars will return a number, we'll use the fact that seq will throw an error for anything else as an easy mechanism for determining the device type, which we need to know in order to correctly count the titles
	title_total_dvd=$(echo "$rawout" | grep -Eao "scan: DVD has [0-9]+ title" | awk -F " " '{print $4}') # counting titles for a DVD
	title_total_stream=$(echo "$rawout" | grep -Eao "libhb: scan thread found [0-9]+ valid title" | awk -F " " '{print $5}') # counting titles for a video file (typically there's only one)
	# you can just come up w/ different title totals for each kind of device type, then run sequence tests on them - the seq call that doesn't throw an error will be the only one to populate title_array
	# SHIT it does override when seq throws an error... we need a way of figuring out which one contains a number

	# todo make script portable, give it an etc config file, let it initialize its own config file w/ defaults depending on OS, exit on unsupported OS's (start w/ Ubuntu and macOS, exit if missing dependencies: ffmpeg, ffprobe, HandbrakeCLI, test case files)

	# todo if the search patterns are broken, you can give the script some test case files to diagnose itself with - if handbrake output isn't what's expected, log it with a critical warning: immediate attention required (unexpected output from HandbrakeCLI: <test case file's> expected output: <output>)
	# todo let script diagnose itself w/ test case files before running full job, exit if unexpected output from test cases (means one or more search patterns for determining media type + title count are broken)

	# todo use ffprobe before handbrake to determine device type? lots of conditionals based on whether you're dealing w/ a dvd image or a video file

	# 4 use cases: 1, DVD image, encode as DVD, 2, non-HEVC video file, re-encode as HEVC, 3, HEVC video file, move to destination w/o encode job, 4, none of the above, not eligible for encode, left alone and noted in log as bad file
	# (decision tree time - this is similar to the one Handbrake uses):
	# if it's a DVD, encode titles as HEVC video files
	# if it's a file...
	# if it has a video stream...
	# if its video stream is anything other than HEVC, encode title as HEVC
	# if its video stream is HEVC, move to destination w/ note in log
	# if it has no video stream, file is invalid and left alone w/ note in log
	
	# need short logging mechanism + text file w/ record of what was done
	# (encode/pass) for each enumerated file in array, reduce the need for
	# checking by manually opening files

	# todo other non-DVD images can still contain video streams and trigger
	# false positives (BD images, for one), patch that

	# todo easier test for determining device type might just be to do what
	# handbrake does behind the scenes and mount the image to look for BD- or
	# DVD-specific directories (handbrake provides ample logs for mimmicking
	# this approach, but research on the latest BD and DVD directory standards
	# should be done)

	# the mount point for device testing should be OS-specific (macOS and
	# linux will have different directory trees), and exit if supported OS
	# isn't detected

	# mounting of course means this script will need to be elevated to a sudo-
	# only script

	# After ISO disk is mounted, you will receive the following message:
	# ‘mount: warning: /mnt/mount_point seems to be mounted read-only‘. You
	# can ignore it, because according to the ISO 9660 standard, ISO images
	# are always mounted in read-only mode.

	# todo the reason you're not asking if something's a BD in your decision tree is because BDs SHOULD be piped through MakeMKV as MKVs FIRST - DON'T let handbrake try to rip bd images from scratch (which means you need a BD check and termination)

	title_array=""

	# if title_total_dvd is the valid integer
	if [[ $title_total_dvd =~ ^[0-9]+$ ]]; then
		title_array=$(seq $title_total_dvd)
	fi

	# if title_total_stream is the valid integer
	if [[ $title_total_stream =~ ^[0-9]+$ ]]; then
		title_array=$(seq $title_total_stream)
	fi

	# if there are no valid numbers, the title_array is empty and the for loop is safely skipped

	# todo don't use for, using a while loop instead is the better practice (spaces in filenames being the main thing)
	for title in $title_array; do

		outfile=$(basename "$device")
		outfile="${outfile%\.*}_${title}.${EXT}"

		HandBrakeCLI -i "$device" --title "$title" --preset-import-file "${PRESETDIR}/${PRESETFILE}" --preset "$PRESET" -o "${OUTDIR}/${outfile}"

	done

done
