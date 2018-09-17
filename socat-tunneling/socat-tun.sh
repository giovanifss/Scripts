#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# Socat Tunneling
#
# Start Socat in client and generate server side command/script to tunnel remote services
# 
# This code is under the GPLv3 license. See LICENSE for more informations.
#
# Developer - Giovani Ferreira
#------------------------------------------------------------------------------------------------------------

#-------------------------------------------- Attack Configuration ------------------------------------------
LSERVICE=
LPORT=
LHOST=
RPORT=
RHOST=
#-------------------------------------------- Script Configuration ------------------------------------------
OUTPUT=
#------------------------------------------------------------------------------------------------------------

function main {
    servercommand="socat TCP4:$LHOST:$LPORT TCP4:$RHOST:$RPORT"
    
    if [ -z $OUTPUT ]; then
        echo -e ":: Run the following command on server:\n\n$servercommand\n"
    else
        echo "==> Generating server script"

	cat <<- EOF > $OUTPUT
	#!/bin/bash
	while true; do
	    $servercommand
	done
	EOF

        echo "[+] Server script generated to $OUTPUT" 
        chmod 777 $OUTPUT
    fi

    echo "==> Starting socat in client"
    echo "==> Waiting for connection"
    socat TCP4-LISTEN:$LPORT,reuseaddr,fork TCP4-LISTEN:$LSERVICE,reuseaddr

    echo -e "\nSocat tunneling finished in $(date)"
} 

function prompt-input {
    echo -e "Socat tunneling started in $(date)\n"

    if [ -z $LPORT ]; then
        echo -n "=: Set local port for reverse connection: "
        read LPORT
    fi

    if [ -z $LSERVICE ]; then
        echo -n "=: Set local port for interaction with service: "
        read LSERVICE
    fi

    if [ -z $LHOST ]; then
        echo -n "=: Set your IP: "
        read LHOST
    fi

    if [ -z $RPORT ]; then
        echo -n "=: Set remote port that is running the service: "
        read RPORT
    fi

    if [ -z $RHOST ]; then
        echo -n "=: Set remote ip running the service: "
        read RHOST
    fi

    return 0
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

            -o|--output)                    # Get the next arg to be the output file
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after output file option"
                fi
                OUTPUT=$2
                shift;;                     # To ensure that the next parameter will not be evaluated again

            -l|--listen)                    # Set the first host in the network to scan
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after listen port option"
                fi

                LPORT=$2
                shift;;

            -L|--local-ip)
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after remote host option"
                fi

                regex="\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"

                if [[ ! $2 =~ $regex ]]; then
                    error_with_message "Invalid IP for external connection"
                fi

                LHOST=$2
                shift;;

            -s|--serve)                     # Set the first host in the network to scan
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after serve option"
                fi

                LSERVICE=$2
                shift;;

            -p|--remote-port)               # Hosts to ignore
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after remote host port option"
                fi

                RPORT=$2
                shift;;

            -h|--host)
                if [ -z $2 ] || [[ $2 == -* ]]; then
                    error_with_message "Expected argument after remote host option"
                fi

                regex="\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"

                if [[ ! $2 =~ $regex ]]; then
                    error_with_message "Invalid host IP"
                fi

                RHOST=$2
                shift;;

            --help)                         # Display the help message
                display_help
                exit 0;;

            *)                              # If a different parameter was passed
                display_help
                exit 1
        esac
        shift                               # Removes the element used in this iteration from parameters
    done

    return 0
}

function display_help {
    echo
    echo ":: Usage: socat-tun -L XXX.XXX.XXX.XXX -l XXX -s XXX -p XXX -h XXX.XXX.XXX.XXX [-o FILE]"
    echo
    echo ":: LOCAL HOST: Your IP. Use '-L|--local-ip'"
    echo ":: LOCAL PORT: Your port for reverse connection. Use '-l|--listen'"
    echo ":: LOCAL SERVICE: Local port for interaction with service. Use '-s|--serve'"
    echo ":: REMOTE HOST: The internal IP of the attacker. Use '-h|--host'"
    echo ":: REMOTE PORT: The port running the service in target. Use '-p|--remote-port'"
    echo ":: OUTPUT: The file to store the output generated. Use '-o | --output'"
    echo ":: VERSION: To see the version and useful informations, use '-V|--version'"
    echo ":: HELP: Display this help message. Use '--help'"

    return 0
}

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
prompt-input
main
