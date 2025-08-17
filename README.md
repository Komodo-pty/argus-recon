# argus-recon
Argus performs automated enumeration for several services.

## Table of Contents

- [Setup](#setup)
- [Functionality](#functionality)
- [Scanner](#scanner)
- [Web App](#web-app)
- [SMB](#smb)
- [Kerberos](#kerberos)
- [DNS](#dns)

## Setup
After installing the dependencies, navigate to this Repo's directory & run `setup.sh`. 

Depending on how they are installed, the name of Impacket's tools can vary (e.g., `impacket-lookupsid` vs `lookupsid.py`). This script ensures that tool names use the proper format.

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

## Functionality
```
Argus will interactively prompt you for input unless you provide the necessary arguments for the selected module.
	
[Options]
	-h: Show this help menu
	-m <MODULE>: Specify the module you want to use
	-m <MODULE> -h: Show specified module's help menu

[Modules]
	scan: TCP & UDP port scan
	web: Web App recon
	smb: SMB recon
	krb: Kerberos recon
	dns: DNS recon
```

### Scanner
Perform various port scans.

```
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target's IP Address
	-o: Save scan scan results to an output file
	-s <SCAN>: Type of TCP port scan to perform (in addition to UDP scan)
	-T <0-5>: Set timing template (higher is faster)

[Scans]
	[!] Tip: Some scans are more or less reliable depending on the target


	con|T: TCP Connect Scan
	syn|S: SYN Stealth Scan
	exo|E: Exotic scans (i.e. TCP Null, FIN, and Xmas scans) {COMING SOON}

	[+] Example: "-sT" is equivilent to "-s con"

[Usage]
    argus -m scan -i 10.201.109.255 -sS -T 3
    argus -m scan -i 10.201.109.255 -s syn -T 4 -o
```

### Web App
```
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target's IP Address
	-p <PORT[:tls][:url:WEBROOT]>: Comma seperated list of ports. HTTP is used unless ":tls" is specified. Optionally specify ":url:PATH" (e.g. 80:url:wordpress for /wordpress/)
	-w <WORDLISTS>: Comma seperated file paths to wordlists for subdirectory enumeration
	-e <EXTENSIONS>: Comma seperated file extensions to test (e.g. .php,.bak,.html,.txt,.old)
	-u <USER_AGENT>: Specify value for the User-Agent HTTP Header (between quotes)

[Usage]
    argus -m web -i 127.0.0.1 -p 443:tls:wordpress,8000 -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -e .php,.bak,.html,.txt,.old
```

### SMB
```
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target's IP Address
	-x <MODE>: Specify the operation to perform

[Modes]
	logins: Test default logins
	users: Enumerate users via Read access to IPC$
	shares: List contents & permissions for all shares
	enum: Enumerate server info (e.g. account descriptions)

[Usage]
    argus -m smb -i 127.0.0.1 -x users
```

### Kerberos
```
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target Domain Controller's IP Address
	-d <DOMAIN>: The target's domain (e.g. xample.local)
	-u <USERNAME>: Specify a username [bruteuser]
	-p <PASSWORD>: Specify a password [passwordspray]
	-U <USER_LIST>: Specify a wordlist for usernames
	-P <PASS_LIST>: Specify a wordlist for passwords
	-c <CRED_LIST>: Specify a wordlist of colon seperated credentials [credpairs]
	-x <MODE>: Specify the operation to perform

[Modes]
	bu: (bruteuser) Bruteforce a single user's password from a wordlist
	cred: (credpairs) Read username:password combos from a file
	spray: (passwordspray) Test a single password against a list of users
	enum: (userenum) Enumerate valid domain usernames via Kerberos
	bf: (bruteforce) Bruteforce usenames & passwords

[!] Tip: Password attacks may lockout accounts depending on target's configuration

[Usage]
	argus -m krb -x spray -i 127.0.0.1 -d xample.local -p 'passwrd123!' -U ./users.txt

```

### DNS
```
[Options]
	-h: Display this help menu
	-i <HOSTNAME>: The target's hostname
	-s <DNS_SERVER>: The DNS Server's IP Address

[Usage]
        argus -m dns -i host01 -s 12.34.567.890

```
## Related Projects
Check out the rest of the Pentesting Pantheon:

Prepare your next attack with Ares (https://github.com/Komodo-pty/ares-attack)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)

Perform Post-Exploitation enumeration against Windows hosts with Hades (https://github.com/Komodo-pty/hades-PrivEsc)
