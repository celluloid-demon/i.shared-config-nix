# Non-reusable
# (If it's unique, then it can very well be generated in-line on the main script)

# COLORS, HEADERS, and LOGGING commands:
#   e_header
#   e_arrow
#   e_success
#   e_error
#   e_warning
#   e_underline
#   e_bold
#   e_note

main() { # Main programming block
 #initialize

  parse
  log "Wrote to a log."
  e_success "Done!"

  graceful_exit
}

initialize() { # Create necessary system files
  make_sync_daemon
  write_crontab
}

write_crontab() { # Create schedule that will automate rsync in the background
  echo "Your crontab has been updated." # Save this for a verbose mode with the -v or --verbose option?
}
