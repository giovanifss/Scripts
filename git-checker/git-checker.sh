#!/bin/bash

THREADS=true

RED='\033[0;31m'
NC='\033[0m'

# Truncate large paths to better display in screen
function truncate_pwd
{
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

function recursively-check {
    cd "$1"
    branches=$(git branch 2>/dev/null)
    if [ ! -z "$branches" ]; then
        for branch in $(echo "$branches" | sed 's/*/ /g' | cut -d ' ' -f 3); do
            topush=$(git log "$branch" --not --remotes)
            if [ ! -z "$topush" ]; then
                branch=$(highlight "$branch")
                path=$(highlight "$(pwd)")
                prefix=$(highlight "[+]")
                if $THREADS; then
                    echo "(PID:$BASHPID) $prefix Commits to push on branch $branch at $path"
                else
                    echo "$prefix Commits to push on branch $branch at $path"
                fi
            fi
        done
    else
        for dir in *; do
        # ls -d */ 2>/dev/null | while read dir; do
            if [[ -d "$dir" ]]; then
                if $THREADS; then
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

if $THREADS; then
    echo "==> Start parallel recursive search in $1"
fi
recursively-check $1
