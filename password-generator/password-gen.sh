#!/bin/bash

#-------------------------------------------------------------------
# Password Generator
#
# Script to generate random passwords. Useful for self managed pass-
# words instead of using a password manager.
#-------------------------------------------------------------------

# How many chars the password will contain, default 20
NUMCHARS=20

# Generated password
PASSWORD=""

# Abort on errors
set -euo pipefail

function echoerr {
    cat <<< "$@" 1>&2
}

function display_help () {
    echo
    echo ":: Usage: password-gen [Number of characters]"
    echo ":: Default number of chars = 20"
    echo ":: Use -h|--help for help"
    echo ":: Use -V|--version for info"
    echo
    return 0
}

function parse_args () {
  while (( "$#" )); do
    case $1 in
      -V|--version) 
        echo ":: Author: Giovani Ferreira"
        echo ":: Source: https://github.com/giovanifss/Scripts"
        echo ":: License: GPLv3"
        echo ":: Version: 0.1"
        exit 0;;

      -h|--help)
        display_help;;

      *)
        regex='^[0-9]+$'
        if ! [[ $1 =~ $regex ]] ; then
          echoerr ":: Error: Argument is not a number"
          exit 1
        fi
        NUMCHARS=$1;;
    esac
    shift
  done
}

function generate_password() {
  PASSWORD=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$1"; echo -n)
}

function main () {
  copied=false

  echo "==> Generating password with $NUMCHARS characters"
  generate_password "$NUMCHARS"
  echo "[+] Password generated: $PASSWORD"

  command -v xsel &>/dev/null &&
    echo -n "$PASSWORD" | xsel -b &&
    copied=true

  if ! $copied; then
    command -v xclip &>/dev/null &&
      echo -n "$PASSWORD" | xclip -sel clip &&
      copied=true
  fi

  if $copied; then
    echo ":: Password copied to clipboard"
  else
    echo ":: You will need to copy the password manually"
  fi
}

parse_args $@
main
