#!/bin/bash

# Exit on error
set -e

# Declare vars
source=./home/*
destination="$HOME/.shared-config-nix"

# Make install dir if it doesn't exist
mkdir -p "$destination"

# Remove previous contents
rm -r "$destination"/*

# Copy new contents
cp -r $source "$destination"

# Prompt user for follow-up actions
echo "Files copied to $destination. Now add to PATH in bash profile. Go away."
