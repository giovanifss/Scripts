#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Mac Spoofer
#
# Script to spoof mac address
# 
# This code is under the GPLv3 license. See LICENSE for more informations.
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

#------------------------------------------- Argument Options -----------------------------------------------
VERBOSE=false
IFCONFIG=false
ADDRESS=
INTERFACE=
#------------------------------------------------------------------------------------------------------------

function main {
    if [ $EUID -ne 0 ]; then
        error_with_message "Run this script as root"
    fi

    echo "[*] Preparing to spoof mac"

    if $IFCONFIG; then
        ifconfig $INTERFACE down
        ifconfig $INTERFACE hw ether $ADDRESS
        ifconfig $INTERFACE up
    else
        ip link set dev $INTERFACE down
        ip link set dev $INTERFACE address $ADDRESS
        ip link set dev $INTERFACE up
    fi

    echo "[+] Mac address spoofed"
}

function parse_args {
    if [ $# -eq 0 ]; then                   # Check if at least one arg was passed
        display_help
        exit 1
    fi

    while (( "$#" )); do                    # Stays in the loop as long as the number of parameters is greater than 0
        case $1 in                          # Switch through cases to see what arg was passed
            -V|--version) 
                echo ":: Author: Giovani Ferreira"
                echo ":: Source: https://github.com/giovanifss/Scripts"
                echo ":: License: GPLv3"
                echo ":: Version: 0.1"
                exit 0;;

            -a|--address)
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after address option"
                fi
                ADDRESS=$2
                shift;;                     # To ensure that the next parameter will not be evaluated again

            -v|--verbose)                   # Set the program operation mode to verbose 
                VERBOSE=true;;

            --ifconfig)
                IFCONFIG=true;;

            *)                              # If a different parameter was passed
                if [ ! -z "$INTERFACE" ] || [[ $1 == -* ]]; then
                    error_with_message "Unknow argument $1"
                fi

                INTERFACE=$1;;
        esac
        shift                               # Removes the element used in this iteration from parameters
    done

    if [ -z $ADDRESS ]; then
        error_with_message "Missing required argument address"
    fi

    if [ -z $INTERFACE ]; then
        error_with_message "Missing required argument interface"
    fi

    return 0
}

function display_help {
    echo
    echo ":: Usage: macspoofer [INTERFACE] [-a ADDRESS]"
    echo
    echo ":: ADDRESS: Set the desired address to spoof. Use '-a|--address'"
    echo ":: IFCONFIG: Enable macspoofing through ifconfig package. Use '--ifconfig'"
    echo ":: VERBOSE: Operation mode can be specified by '-v|--verbose'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"

    return 0
}

function error_with_message {
    echo ":: Error: $1"
    echo ":: Use -h for help"
    exit 1
}

# Start of script
parse_args $@
main
