# argus-recon
Too lazy to keep typing the same recon commands, or to write a simple shell script to run them for you?

Well then this is the tool suite for you!

The goal is to speed up a Pentester's reconnaissance, and prevent them from forgetting certain steps.

Argus will help you see more than its namesake.

## Functionality
Argus is a collection of scripts which perform different kinds of enumeration for Penetration Testing.

Each of these scripts can be run independently, or they can be launched from the main `argus.sh` script.

For the most part, this is a series of wrappers which utilize common Pentesting tools; why reinvent the wheel?

Argus also performs a few extra tricks, so I can impress users with its elegance.

### Modules
So far there are modules for: Port Scanning, Web App Enumeration, & SMB Enumeration.

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

#### Note
Ensure all aforementioned dependencies are in your PATH and are named appropriately.

Depending on how it was installed, Impacket's lookupsid may have another name (e.g. impacket-lookupsid).

netexec should have the alias nxc.
