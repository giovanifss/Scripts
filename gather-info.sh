#!/bin/bash

#-----------------------------------------------------------------------------
# Script to gather information about the operating system
#
# This program will try to find informations about:
#   - Readable files in /etc
#   - Distribution and Kernel version
#   - Mounted filesystems
#   - Development tools available
#   - Installed packages
#   - Network configuration
#   - Services and processes running
#   - Scheduled jobs
#   - SUID and GUID files and writable files
#   - Writable files outside HOME
#   - Partitions and size
#
# The script was inspired by:
#   http://www.admin-magazine.com/Articles/Understanding-Privilege-Escalation
#
# It's an improvement of the presented script
#-----------------------------------------------------------------------------

RED='\033[0;31m'
NC='\033[0m'

# Display a red message in the script
function display-highlight-message {
    echo -e ${RED}$1${NC}
}

# Main function of the script
function main {
    display-highlight-message "\n==> Distribution and kernel version"
    cat /etc/issue
    cat /etc/*-release
    cat /proc/version
    uname -a
    lsb_release -a 2>/dev/null  # For ubuntu only

    display-highlight-message "\n==> Partitions"
    cat /proc/partitions
    lsblk 2>/dev/null
    df 2>/dev/null

    display-highlight-message "\n==> Readable files in /etc"
    find /etc -user `id -u` -perm -u=r -o -group `id -g` -perm -g=r -o perm -o=r -ls 2>/dev/null

    display-highlight-message "\n==> Mounted filesystems"
    mount -l
    echo
    cat /proc/mounts
    echo
    cat /etc/mtab
    echo

    display-highlight-message "\n==> Network configuration"
    ifconfig -a 2>/dev/null
    ip addr show 2>/dev/null
    ip route show 2>/dev/null
    netstat -nr 2>/dev/null
    cat /etc/hosts
    cat /etc/resolv.conf
    cat /etc/nsswitch.conf
    arp

    display-highlight-message "\n==> Development tools available"
    which gcc g++ python perl clisp nasm ruby gdb make java php clang clang++ 2>/dev/null

    display-highlight-message "\n==> Installed packages"
    dpkg -l 2>/dev/null
    pacman -Qqen 2>/dev/null
    rpm -qa 2>/dev/null
    yum list installed 2>/dev/null
    apt --installed list 2>/dev/null
    aptitude search '~i' 2>/dev/null
    dnf list installed 2>/dev/null

    display-highlight-message "\n==> Services"
    service --status-all 2>/dev/null
    chkconfig --list 2>/dev/null
    systemctl -t service -a
    netstat -tulnpe

    display-highlight-message "\n==> Processes"
    pstree 2>/dev/null
    ps aux

    display-highlight-message "\n==> Scheduled jobs"
    find /etc/cron* -ls 2>/dev/null
    find /var/spool/cron* -ls 2>/dev/null
    systemctl list-timers --all 2>/dev/null

    display-highlight-message "\n==> SUID and GUID files"
    find / -type f -perm -u=s -o -type f -perm -g=s -ls 2>/dev/null

    display-highlight-message "\n==> SUID and GUID writable files"
    find / -o -group `id -g` -perm -g=w -perm -u=s -o perm -o=w -perm -u=s -o -perm -o=w -perm -g=s -ls 2>/dev/null

    display-highlight-message "\n==> Writable files outside HOME"
    mount -l find / -path "$HOME" -prune -o -path "/proc" -prune -o \( ! -type l \) \( -user `id -u` -perm -u=w -o -group `id -g` -perm -g=w -o -perm -o=w \) -ls 2>/dev/null

    return 0
}

# Starting the script
main
