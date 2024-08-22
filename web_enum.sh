#!/bin/bash

line="\n============================================================\n"
proxy=""
ext=""
echo -e "\nEnter target IP / hostname:"
read ip
echo -e $line

echo -e "\nEnter space seperated list of Web App ports (e.g. 80 8080)\n"
read ports
	for p in $ports
	do
		echo -e "\nFingerprinting: http://$ip:$p\n"
		whatweb -a 3 -v "http://$ip:$p"
		echo -e $line
	done
	for p in $ports
	do
		echo -e "\nLinks on homepage: http://$ip:$p\n\nLook for Domain Names\n"
		curl -s http://$ip:$p | grep '://'| awk -F '://' '{print $2}' | awk -F '/' '{print $1}' | uniq

#Misses things outside webroot & some links may not end in /

		echo -e $line

	done

#ffuf is having issues when supplied with comma seperated wordlists, so iterate through wordlists with for loop instead
	echo -e "\nEnter space seperated list of wordlist paths for Subdirectory Enumeration\n"
	read lists

	echo -e "\nAre you using burpsuite or ZAP? [y/N]\n"
	read choice

	if [ $choice == "y" ]
	then
		proxy="-replay-proxy http://localhost:8080"
	fi
	echo -e "\nDo you want to use extensions for Subdirectory Enumeration? [y/N]\n"
	read choice

	if [ $choice == "y" ]
	then
		echo -e "\nEnter comma seperated list of extensions for ffuf (e.g. .php,.bak)\n"
		read choice
		ext="-e $choice"
	fi
	echo -e $line

	for p in $ports
	do
		for w in $lists
		do
			ffuf -c -u "http://$ip:$p/FUZZ" -ic -w $w $ext $proxy | tee -a "$ip:$p"_ffuf.txt
			echo -e $line
		done

		cewl "http://$ip:$p" --with-numbers -e -d 4 | grep -v CeWL >> /dev/shm/"$ip:$p"_CeWL.txt

#Create lowercase duplicate of the wordlist, merge the lists, & remove any duplicate entries

		duplicut -c /dev/shm/"$ip:$p"_CeWL.txt -o /dev/shm/"$ip:$p"_lower_CeWL.txt
		cat /dev/shm/"$ip:$p"_lower_CeWL.txt >> /dev/shm/"$ip:$p"_CeWL.txt
		duplicut /dev/shm/"$ip:$p"_CeWL.txt -o "$ip:$p"_CeWL.txt

		ffuf -c -u "http://$ip:$p/FUZZ" -w "$ip:$p"_CeWL.txt $ext $proxy | tee -a "$ip:$p"_ffuf.txt
		echo -e $line
	done
	echo -e "\n[+] Manually perform Subdomain Enumeration for each Web App!\n"
	echo -e "\nAdd IP to /etc/hosts if necessary. May need to filter content to exclude results from wildcard DNS resulotion (e.g. -fw 30. Use a command like:\n"
	echo 'ffuf -c -u http://example.com:8080 -H "Host: FUZZ.example.com" -w /usr/share/seclists/Discovery/DNS/shubs-subdomains.txt'
