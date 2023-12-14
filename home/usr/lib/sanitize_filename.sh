#!/bin/bash

# Sanitize a given filename
# $ sanitize_filename <file> [--dry-run]
sanitize_filename() {

  local item="$1"
  local item_sanitized="$item" # default value
  local dir=$(dirname "$item") # path sans file
  local file=$(basename "$item") # file sans path
  local dry_run="$2" # --dry-run

  # Split the filename into the base name and extension (and preserve other
  # filename parts that may be using period as separator)
  local base_name="${file%%.*}"
  local extension="${file##*.}"

  # Remove leading and trailing whitespace
  base_name="$(echo -e "${base_name}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  # Replace spaces with underscores
  base_name="${base_name// /_}"

  # Remove special characters and replace with underscores
  base_name="$(echo -e "${base_name}" | sed -e 's/[^A-Za-z0-9._-]/_/g')"

  # Concatenate the sanitized base name and extension
  local sanitized_file="${base_name}.${extension}"

  # Rename the file only if $sanitized_file is different from $file (AND if not in dry run mode) 
  if [ "$sanitized_file" != "$file" ]; then

    item_sanitized="$dir/$sanitized_file" # update $item_sanitized

    if [ "$dry_run" != "--dry-run" ]; then

      mv "$item" "$item_sanitized"

    fi

    # echo "Renamed file '$file' to '$sanitized_file'"

  fi

  # Output
  echo "$item_sanitized"

}

# Recursively sanitize filenames in a given directory (by having the
# batch-wrapper function recursively call itself)
# $ batch_sanitize_filenames <indir> [--dry-run]
batch_sanitize_filenames() {

  local indir="$1"
  local dry_run="$2"

  # Iterate over all files in the given directory (recursively)
  for item in "$indir"/*; do

    if [[ -f "$item" ]]; then

      # Process file: sanitize the filename
      sanitize_filename "$item" "$dry_run"

    elif [[ -d "$item" ]]; then

      # Skip if Maya project directory
      shopt -s nullglob
      maya_files=("$item"/*.ma "$item"/*.mb "$item/scenes"/*ma "$item"/scenes/*mb)
      shopt -u nullglob
  
      if (( ${#maya_files[@]} > 0 )); then
  
          echo "[SKIP] Ignoring Maya project folder: $(basename "$item")"

      elif

        # Process directory: recursively sanitize filenames in subdirectories
        batch_sanitize_filenames "$item" "$dry_run"

      fi

    fi

  done

}
