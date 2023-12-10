#!/bin/bash
# remux-video
# multiplex-video
# mkvtomp4-qt
# tomp4-qt
# repacktomp4-qt

# Takes a video and re-packs it as a Quicktime-compatible file.

# todo the whole point of the audio component of that handbrake preset you're
# using is that you want the destination file's audio setup to be Quicktime-
# compatible (first track always stereo)... but if you're trying to script a
# solution that involves you as little as possible and gives you more time
# back, why not stick with the MKVs like you're already doing anyway? NONE of
# your videos are fully quicktime-compatible - they all have vobsubs.
# simplifying your handbrake preset to worry just about a 1:1 transaction of
# audio tracks (stereo to stereo, surround to passthru) means you can cut out
# the manual stream culling step altogether, and make this setup fully
# automated, IF you're okay w/ a fully-MKV library.

# note: this script DOES NOT RE-ENCODE, it only multiplexes, so its primary
# use is for losslessly repacking H264 and H265 videos in QT-compatible MP4
# containers.

# note: this script ONLY SHIFTS AN MKV CONTAINER TO A QUICKTIME-COMPATIBLE
# MP4/M4V FILE w/o re-encoding the video stream, thus if the source video
# stream itself is not Quicktime-compatible, this script will exit in error.

# technically this can be used on any source device that ffmpeg supports, but
# the primary use case is repacking MKVs as QT- and Quicklook-compatible
# mp4/m4v's.

# Containers are files that wrap around video and audio tracks—indexing and
# organizing the streams for playback—in addition to providing advanced
# features, like chapters similar to those on DVDs. This script shifts
# Matroska videos into MP4 containers and correctly labels H265 streams w/ the
# hvc1 tag to maintain macOS High Sierra Quicktime/Quicklook compatibility.

# todo set EXT as mp4 by default, m4v if source device contains passthru audio
# (AC3), SRT subs or a chapter list.

# addendum workflow should extract any subtitles, including SRT, from source
# device before multiplexing, so destination file shouldn't attempt to save
# any subtitles. thus, if source device contains SRT subs but no AC3 audio or
# chapter list, the destination file will be saved with the mp4 extension.

INDIR=""
OUTDIR="$HOME/Desktop/ffmpegH265_Videos"
EXT=".mp4"

mkdir -p "$OUTDIR"

# NOTE: No spaces!
# todo to get around spaces in filenames, convert for loop to while-read loop (that's the standard tool for use w/ find arrays anyway)
if [ -z "$1" ]; then
    INDIR="."
else
    INDIR="$1"
fi

device_array=$(find "$INDIR"/* -type f) # NOTE: No spaces!

for device in $device_array; do

	outfile=$(basename "$device")
	outfile="${outfile%\.*}${EXT}"

	# todo add conditional that checks for source video codec, 
	# ffmpeg -i "$device" -map 0 -c copy -sn -tag:v hvc1 "${OUTDIR}/${outfile}" # the -sn option is to stop ffmpeg from copying subtitle streams, useful if you don't want vobsubs embedded in your output and have already extracted them
	ffmpeg \
		-i "$device" \
		-map 0 \
		-c copy \
		-tag:v hvc1 \
		"${OUTDIR}/${outfile}"
	# todo add override that re-adds subtiles if they're QT-compatible SRT streams

done
