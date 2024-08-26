#!/bin/bash

line="\n============================================================\n"
echo -e "\nEnter the target IP / hostname:"
read target

query=$(nxc smb $target -u '' -p '')
domain=$(echo "$query" | grep domain | awk -F 'domain:' '{print $2}' | awk -F ')' '{print $1}')
host=$(echo "$query" | awk -F 'name:' '{print $2}' | awk -F ')' '{print $1}')
dom="\n[+] Using Domain: $domain\n"
hostname="\n[+] Using Hostname: $host\n"
ad=0

if [ "$host" == "$domain" ]
then
	echo -e "\nThe Hostname is identical to the Domain Name\n"

elif [ "$domain" == "" ]
then
	echo -e "\nNo Domain Name detected\n"

else
	echo -e "The 4 default logins will be tested\n$hostname\n&\n$dom"
	ad=1
fi

echo -e "$line"

echo -e "$hostname"

echo -e "Null Login. No creds\n"
nxc smb "$target" -u '' -p '' -d "$host" --shares
echo -e "$line"

echo -e "Anonymous username & no password\n"
nxc smb "$target" -u 'Anonymous' -p '' -d "$host" --shares
echo -e "$line"

echo -e "Anonymous:Anonymous\n"
nxc smb "$target" -u 'Anonymous' -p 'Anonymous' -d "$host" --shares
echo -e "$line"

echo -e "Guest login\n"
nxc smb "$target" -u 'guest' -p '' -d "$host" --shares
echo -e "$line"

if [ $ad -eq 1 ]
then
	echo -e "$dom"

	echo -e "Null Login. No creds\n"
	nxc smb "$target" -u '' -p '' -d "$domain" --shares
	echo -e "$line"

	echo -e "Anonymous username & no password\n"
	nxc smb "$target" -u 'Anonymous' -p '' -d "$domain" --shares
	echo -e "$line"

	echo -e "Anonymous:Anonymous\n"
	nxc smb "$target" -u 'Anonymous' -p 'Anonymous' -d "$domain" --shares
	echo -e "$line"

	echo -e "Guest login\n"
	nxc smb "$target" -u 'guest' -p '' -d "$domain" --shares
	echo -e "$line"
fi

echo -e "\nDo you want to enumerate Users via Read access to the IPC$ share?

[0] No. Exit

[1] Yes. Print results to STDOUT

[2] Yes. Print results & then write usernames to a file\n"

read opt

if [ "$opt" == "1" ] || [ "$opt" == "2" ]
then
	echo -e "Enter the Username to use (optionally specify 'DOMAIN/USER')\n"
	read user
	echo -e "Will you be using a Password? [y/N]\n"
	read cred

	if [ "$cred" == "y" ]
	then
		echo -e "Enter the Password\n"
		read pass
	fi
fi

if [ "$opt" == "1" ] || [ "$opt" == "2" ]
then
	if [ "$cred" == "y" ]
	then
		login="'${user}':'${pass}'"
		echo -e "\nLocal SIDs\n"
		lUsers=$(lookupsid.py "$login"@"$target")
		echo $lUsers
		echo -e "$line"
		
		if  [ $ad -eq 1 ]
		then
			echo -e "\nDomain SIDs\n"
			dUsers=$(lookupsid.py "$login"@"$target" -domain-sids)
			echo $dUsers
		fi
	else
		echo -e "\nLocal SIDs\n"
		lUsers=$(lookupsid.py -no-pass "'$user'"@"$target")
		echo $lUsers
		echo -e "$line"

		if [ $ad -eq 1 ]
		then
			echo -e "\nDomain SIDs\n"
			dUsers=$(lookupsid.py "'$user'"@"$target" -domain-sids)
			echo $dUsers
		fi
	fi
	
	if [ "$opt" == "2" ]
	then
		echo -e "\nLocal Users: Path to output file\n"
		read out1
		echo -e "\nDomain Users: Path to output file (can be the same file path)\n"
		read out2


		echo $lUsers | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}' >> "$out1"
		echo $dUsers | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}' >> "$out2"


	fi
fi
