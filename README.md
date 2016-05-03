# Linux-Info-Gather

Script to collect information of the linux system running on a machine.  

It's always important to be aware of what is and what is not accessible in your system. This tool have 2 objectives:
- Help pentesters to find misconfiguration in a server and start a privilege escalation  
- Help sysadmins to check and find possible privilege escalation vulnerabilites  

## What it does?
This script will try different ways to collect useful information for a privilege escalation attack:
- Readable files in ```/etc```
- Installed packages in the system
- Network configurations
- Partitions and size
- Mounted filesystems
- Distribution and kernel version running
- Development tools available
- SUID and GUID files and writable ones
- Writable files outside ```$HOME```
- Scheduled jobs
- Services and processes running

As you can see, it will generate a large output (needs improvements). You should consider redirect the ouput to a file for readability reasons.

## Usage
For sysadmins, it's recommended to test with different levels of privilegies to check what is accessible for that level.  

First, give permissions to the file:
```chmod +x gather-info.sh```

Second, execute file (you should consider redirect the output):
```./gather-info.sh```

## License
This script is under the GPLv3 License, see LICENSE for specific informations.
