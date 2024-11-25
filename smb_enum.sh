#!/bin/bash

line="\n============================================================\n"
echo -e "\nEnter the target IP / hostname:"
read target

echo -e "\nSelect an operation:\n[1] Test default logins\n[2] Enumerate users via Read access to IPC$\n[3] List contents & permissions for all shares"
echo -e "[4] Enumerate Server Info (e.g. Get Account Descriptions)\n"
read mode

if [ $mode == 1 ] || [ $mode == 2 ]
then
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
		ad=1
	fi
fi
echo -e "$line"

if [ $mode == 1 ]
then
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
elif [ $mode == 2 ]
then
	echo -e "\nDo you want to extract usernames & save them to a file?\n[1] No. Print results to STDOUT\n[2] Yes. Print results & then write usernames to a file\n"
	read opt

	if [ "$opt" == "1" ] || [ "$opt" == "2" ]
	then
		echo -e "\nEnter the Username to use (Use Syntax DOMAIN/USER or HOSTNAME/USER):\n"
		read user

		echo -e "\nSelect an option:\n[1] Authenticate using a password\n[2] Authenticate using an NTLM hash\n[3] Use an account that doesn't have a password\n"
		read cred

		if [ $cred == 1 ]
		then
			echo -e "\nEnter the Password:\n"
			read pass

		elif [ $cred == 2 ]
		then
			echo -e "\nEnter the NTLM hash:\n"
			read ntlm

		elif [ $cred == 3 ]
		then
			echo -e "\nConnecting using an account with a Null password\n"
		else
			echo -e "\nYou did not select a valid option\n"
			return
		fi
	fi

	if [ "$opt" == "1" ] || [ "$opt" == "2" ]
	then
		if [ $cred == 1 ]
		then
			echo -e "\n[Local SIDs]\n"
			lUsers=$(lookupsid.py "$user":"$pass"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
			echo -e "$line"
		
			if  [ $ad -eq 1 ]
			then
				echo -e "\n[Domain SIDs]\n"
				dUsers=$(lookupsid.py -domain-sids "$user":"$pass"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
			fi

		elif [ $cred == 2 ]
		then
			echo -e "\n[Local SIDs]\n"
                        lUsers=$(lookupsid.py -hashes :$ntlm "$user"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
                        echo -e "$line"
                
                        if  [ $ad -eq 1 ]
                        then
                                echo -e "\n[Domain SIDs]\n"
                                dUsers=$(lookupsid.py -domain-sids -hashes :$ntlm "$user"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
                        fi

		elif [ $cred == 3 ]
		then
			echo -e "\n[Local SIDs]\n"
			lUsers=$(lookupsid.py -no-pass "$user"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
			echo -e "$line"

			if [ $ad -eq 1 ]
			then
				echo -e "\n[Domain SIDs]\n"
				dUsers=$(lookupsid.py -no-pass -domain-sids "$user"@"$target" | tee /dev/tty | grep  "SidTypeUser" | awk -F '\' '{print $2}' | awk -F ' \\(' '{print $1}')
			fi
		fi
	
		if [ "$opt" == "2" ]
		then
			echo -e "\nLocal Users: Path to output file\n"
			read out1
			echo -e "\nDomain Users: Path to output file (can be the same file path)\n"
			read out2

			if [ "$out1" == "$out2" ]
			then
				for l in $lUsers
                        	do
                                	echo $l >> /dev/shm/smb_user_enum.txt
                        	done

                        	for d in $dUsers
                        	do
                                	echo $d >> /dev/shm/smb_user_enum.txt
                        	done

				duplicut /dev/shm/smb_user_enum.txt -o $out1 	

			else
				for l in $lUsers
				do
					echo $l >> $out1
				done

				for d in $dUsers
				do
					echo $d >> $out2
				done
			fi

		fi
	else
		echo -e "\nYou did not select a valid option\n"
	fi

elif [ $mode == 3 ]
then
	echo -e "\nEnter the Domain name or Hostname to use:\n"
	read dom
	echo -e "\nEnter the Username to use:\n"
	read user

	echo -e "\n\n[!] Tip: You can authenticate with a password, or with LMHASH:NTHASH (to use hashes, you must specify both seperated with a colon as shown)\n"
	echo -e "\nEnter the password or the hashes:\n"
	read cred

	set -x
	smbmap -H $target -u "$user" -p "$cred" -d $dom -r
	set +x

elif [ $mode == 4 ]
then

# May want to specify domain with -w ?
#	echo -e "\nEnter the Domain name or Hostname to use:\n"
#        read dom
        echo -e "\n[!] Tip: If Null Sessions are supported, just enter a blank username & password\n\nEnter the Username to use:\n"
        read user

	echo -e "\nHow do you want to authenticate?\n[1] Password\n[2] NTLM Hash\n"
	read cred

	if [ $cred == 1 ]
	then

		echo -e "Enter the Password:\n"
                read pass 
		
		enum4linux-ng -u "$user" -p "$pass" -R -d -A "$target"

	elif [ $cred == 2 ]
	then
		echo -e "\nEnter the NTLM hash:\n"
                read ntlm

		enum4linux-ng -u "$user" -H "$ntlm" -R -d -A "$target"

	else
		echo -e "\nYou did not select a valid option\n"
                return
        fi
        
else
	echo -e "\nYou did not select a valid option\n"
fi
