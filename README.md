# argus-recon
The goal of Argus is to speed up a Pentester's reconnaissance, and prevent them from forgetting to perform certain steps.

Argus will help you see more than its namesake.

## Functionality
Argus is a collection of scripts which perform different kinds of enumeration for Penetration Testing.

Each of these scripts can be run independently, or they can be launched from the main `argus.sh` script.

For the most part, this is a series of wrappers which utilize common Pentesting tools; why reinvent the wheel?

Argus also performs a few extra tricks, so I can impress users with its elegance.

### Modules
So far there are modules for: Port Scanning, Web App Enumeration, SMB Enumeration, Kerberos Enumeration, & DNS Enumeration.

In subsequent versions, each of these will be expanded upon, and more modules will be added.

## Setup
After installing the dependencies, give `argus.sh` permission to execute & create a symbolic link in your PATH.

For example, run the following in this Repo's directory:

`chmod +x argus.sh`

`ln -s $(pwd)/argus.sh /home/user/.local/bin/argus`

### Dependencies
nmap

whatweb

ffuf

cewl

duplicut

netexec

lookupsid.py

kerbrute

dig

smbmap

#### Note
Ensure all aforementioned dependencies are in your PATH and are named appropriately.

netexec should have the alias nxc.

Depending on how they are installed, the name of Impacket's tools can vary (e.g. impacket-lookupsid vs lookupsid.py).

You can convert the tool names to either format by running `kali_convert.sh`

# Related Projects
Check out the rest of the Pentesting Pantheon:

Prepare your next attack with Ares (https://github.com/Komodo-pty/ares-attack)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)

Perform Post-Exploitation enumeration against Windows hosts with Hades (https://github.com/Komodo-pty/hades-PrivEsc)
