#!/bin/bash
# ---------------------------------------------------------------------------
# dummy - Dummy script for testing purposes.

# Usage: dummy

# Revision history:
# 2015-02-22 Created
# ---------------------------------------------------------------------------

# Note on Windows you may need to use double quotes instead of single.

# Download best mp4 format available or any other best if no mp4 available
# youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' $@

# Download best format available but not better that 480p
# $ youtube-dl -f 'bestvideo[height<=480]+bestaudio/best[height<=480]'

# Download best video only format but no bigger than 50 MB
# $ youtube-dl -f 'best[filesize<50M]'

# Download best format available via direct link over HTTP/HTTPS protocol
# $ youtube-dl -f '(bestvideo+bestaudio/best)[protocol^=http]'

# Download the best video format and the best audio format without merging them
# $ youtube-dl -f 'bestvideo,bestaudio' -o '%(title)s.f%(format_id)s.%(ext)s'

# Note that in the last example, an output template is recommended as bestvideo and bestaudio may have the same file name.

# facebook
# youtube-dl -u "jonathandudrey@gmail.com" -p "makomako06" -f 'worstvideo[ext=mp4]+worstaudio[ext=m4a]/worst[ext=mp4]/worst' -o "~/Desktop/Vimeo_Videos/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" $@
youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' -o "~/Desktop/Facebook_Videos/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" $@
