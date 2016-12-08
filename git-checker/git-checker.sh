#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Git Checker
#
# Script to locate git branches that have commits not pushed to remote yet
# 
# This code is under the GPLv3 license. See LICENSE for more informations.
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

#------------------------------------------- Argument Options -----------------------------------------------
PARALLEL=false
BASEDIR=$HOME
DEFAULTDIR=true
ALL=false
#--------------------------------------------- Color Settings -----------------------------------------------
RED='\033[0;31m'
NC='\033[0m'
#------------------------------------------------------------------------------------------------------------

trap "echo; exit 1" INT                       # Set trap to exit script when receiving a sigint

function main {
    if $PARALLEL; then
        echo "==> Start parallel recursive search in $BASEDIR"
    else
        echo "==> Start serial recursive search in $BASEDIR"
    fi

    recursively-check $BASEDIR
}

# Check directory recursively for git repositories
function recursively-check {
    cd "$1"
        
    if $ALL; then
        check-include
    fi

    branches=$(git branch 2>/dev/null)
    if [ ! -z "$branches" ]; then
        check-branches "$branches"
    else
        for dir in *; do
            if [[ -d "$dir" ]]; then
                if $PARALLEL; then
                    recursively-check "$dir" &
                else
                    echo -ne "--> Searching in $(truncate_pwd)                                                      \r"
                    recursively-check "$dir"
               fi
            fi
        done
        wait
    fi

    cd ..
}

# See if there are files to include in commits
function check-include {
    toinclude=$(git status -s 2>/dev/null | awk -F ' ' '{print $NF}')
    if [ ! -z "$toinclude" ]; then
        path=$(highlight "$(pwd)")
        prefix=$(highlight "[*]")
        echo "$prefix Files to include in $path:"
        for file in $toinclude; do
            echo "        $(highlight '-') $file" 
        done
    fi
}

function check-branches {
    for branch in $(echo "$1" | sed 's/*/ /g' | cut -d ' ' -f 3); do
        topush=$(git log "$branch" --not --remotes)
        if [ ! -z "$topush" ]; then
            branch=$(highlight "$branch")
            path=$(highlight "$(pwd)")
            prefix=$(highlight "[+]")
            if $PARALLEL; then
                echo "(PID:$BASHPID) $prefix Commits to push on branch $branch at $path"
            else
                echo "$prefix Commits to push on branch $branch at $path"
            fi
        fi
    done
}


# Truncate large paths to better display in screen
function truncate_pwd {
    if [ "$HOME" == "$PWD" ]; then
        newPWD="~"
    elif [ "$HOME" ==  "${PWD:0:${#HOME}}" ]; then
        newPWD="~${PWD:${#HOME}}"
    else
        newPWD=$PWD
    fi

    local pwdmaxlen=75
    local pwdbase=20
    local pwdrest=$(( $pwdmaxlen - $pwdbase ))
    if [ ${#newPWD} -gt $pwdmaxlen ]; then
        local pwdoffset=$(( ${#newPWD} - $pwdrest  ))
        newPWD="${newPWD:0:$pwdbase}  (...)  ${newPWD:$pwdoffset:$pwdrest}"
    fi

    echo -n "$newPWD"
}

# Display a red message in the script
function highlight {
    echo -e ${RED}$1${NC}
}

# Parse all arguments received from command line
function parse_args {
    while (( "$#" )); do                    # Stays in the loop as long as the number of parameters is greater than 0
        case $1 in                          # Switch through cases to see what arg was passed
            -V|--version) 
                echo ":: Author: Giovani Ferreira"
                echo ":: Source: https://github.com/giovanifss/Scripts"
                echo ":: License: GPLv3"
                echo ":: Version: 0.1"
                exit 0;;

            -p|--parallel)
                PARALLEL=true;;

            -a|--all)
                ALL=true;;

            -h|--help)
                display_help
                exit 0;;

            *)                              # If a different parameter was passed
                if ! $DEFAULTDIR || [[ $1 == -* ]]; then
                    error_with_message "Invalid argument $1"
                fi

                DEFAULTDIR=false
                BASEDIR=$1;;
        esac
        shift                               # Removes the element used in this iteration from parameters
    done

    return 0
}

function display_help {
    echo
    echo ":: Usage: git-checker [BASEDIR] [options]"
    echo
    echo ":: ALL: Search for not included files too"
    echo ":: BASEDIR: Base directory to recursively check. Default=$HOME"
    echo ":: PARALLEL: Activate parallel mode. This means, subprocesses will be created for performance"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"

    return 0
}

# Finish program execution with a error message
function error_with_message {
    echoerr "[-] Error: $1"
    echoerr ":: Use -h for help"
    exit 1
}

function echoerr {
    cat <<< "$@" 1>&2
}

# Start of script
parse_args $@
main
