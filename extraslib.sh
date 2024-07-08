#!/usr/bin/env bash

# -*- mode: sh -*-
# shellcheck shell=bash

EXTRASLIB_DIRENV_VERSION=0.1.0

# ensure_directory_exists <dir>
#
# Creates the directory if it doesn't exist
ensure_directory_exists() {
  local dir="${1}"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
}

# use_flake_if_nix_installed
#
# Uses flake if Nix is installed, otherwise skips
use_flake_if_nix_installed() {
  if command -v nix >/dev/null 2>&1; then
    # Nix is installed, proceed to use flake
    use flake
  else
    echo "Nix is not installed, skipping flake configuration."
  fi
}

# use_sops [path]
#
# Decrypts and loads environment variables from a SOPS-encrypted file if it exists.
# If no path is specified, defaults to './secrets.yaml' in the current directory.
#
# Arguments:
#   path: Optional. Path to the SOPS-encrypted file. Default: $PWD/secrets.yaml
#
# Side effects:
#   - If the specified file exists:
#     - Decrypts the file using SOPS
#     - Loads the decrypted environment variables into the current shell
#     - Sets up a watch on the encrypted file for automatic reloading
#   - If the file doesn't exist, does nothing and prints a warning
use_sops() {
  local path=${1:-$PWD/secrets.yaml}
  if [[ -f "$path" ]]; then
    eval "$(sops -d --output-type dotenv "$path" | direnv dotenv bash /dev/stdin)"
    watch_file "$path"
  fi
}
