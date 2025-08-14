# argus-recon
The goal of Argus is to automate several types of Pentesting enumeration.

## Functionality
Argus is a collection of scripts which perform different kinds of enumeration for Penetration Testing.

Each of these scripts can be run independently, or they can be launched from the main `argus.sh` script.

Run `argus -h`  for the main help menu, or specify a module to get its help menu (e.g. `argus -m scan -h`)

### Modules
So far there are modules for: Port Scanning, Web App Enumeration, SMB Enumeration, Kerberos Enumeration, & DNS Enumeration.

## Setup
After installing the dependencies, navigate to this Repo's directory & run `setup.sh`. 

`bash ./setup.sh`

### Dependencies
nmap

whatweb

ffuf

cewl

duplicut

netexec

impacket-lookupsid

kerbrute

dig

smbmap

#### Note
Ensure all aforementioned dependencies are in your PATH and are named appropriately.

netexec should have the alias nxc.

Depending on how they are installed, the name of Impacket's tools can vary (e.g. impacket-lookupsid vs lookupsid.py).

You can convert the tool names to the proper format by running `setup.sh`

# Related Projects
Check out the rest of the Pentesting Pantheon:

Prepare your next attack with Ares (https://github.com/Komodo-pty/ares-attack)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)

Perform Post-Exploitation enumeration against Windows hosts with Hades (https://github.com/Komodo-pty/hades-PrivEsc)
