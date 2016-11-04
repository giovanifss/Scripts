# Mac Spoofer
Script to spoof the MAC address of a given interface. This script support spoofing through ip addr and ifconfig.

## What it does?
This script turn down a given interface and change the MAC address to the one provided as argument, then turn up the interface again (For this, root priveleges are required).

## Usage
First, give execution permission to the file:  
```$ chmod +x mac-spoofer.sh```  

Then execute the file considering the following options:  
```
INTERFACE: positional argument  
-a|--address: The MAC address to use
```
