main() {
  parse

  log "Wrote to a log."

  echo "Now printing pretty strings."
  pretty_strings

  e_success "Done!"
}

lockfile_main() {
  create_lockfile # Exits if lockfile present

  echo "Waiting five (5) seconds..."

  sleep 5

  remove_lockfile

  echo "Done!"
}

pretty_strings() {
  e_header "Hello!"
  e_arrow "Hello!"
  e_success "Hello!"
  e_error "Hello!"
  e_warning "Hello!"
  e_underline "Hello!"
  e_bold "Hello!"
  e_note "Hello!"
}

initialize() {
  make_sync_daemon
  write_crontab
}

write_crontab() {
  placeholder=

  # ...
}
