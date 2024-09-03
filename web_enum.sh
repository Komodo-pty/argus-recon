#!/bin/bash

line="\n============================================================\n"
proxy=""
ext=""
webroot=""
path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')

#Add option to run as is in interactive mode OR 1) set all args @ start 2) supply args for main script that are passed to this?
#Output is grouped for each type of Enum. Instead group results by each target? There'd only need to be 1 for loop for ports
#Add output file option & set name var for each test. If out=yes make file based off of name var's value

echo -e "\nEnter target IP / hostname:"
read ip
echo -e $line

echo -e "\nEnter space seperated list of Web App ports (e.g. 80 8080)\n"
read ports

echo -e "\nWill you be using the default webroot base path? (e.g. http://site.com/) [Y/n]\n"
read choice

if [ $choice == "n" ]
then
	echo -e "\nInput the Subdirectory name to use. (e.g. wordpress)\n"
	read webroot
fi

for p in $ports
do
	echo -e "\nFingerprinting: http://$ip:$p/$webroot\n"
	whatweb -a 3 -v --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.1" "http://$ip:$p/$webroot"
	echo -e $line
done

for p in $ports
do
	if [ -z "$webroot" ]
        	then
                	site="http://$ip:$p"
        	else
                	site="http://$ip:$p/$webroot"
        	fi

	echo -e "\nLinks on webpage: $site\n\nLook for Domain Names\n"
	
	export site

	result=$(python3 $path/web_scraper.py)

	echo "${result[@]}" | sort | uniq

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

#Check if a webroot was specified. This ensures there's no extra / which can help ffuf

	if [ -z "$webroot" ]
	then
		site="http://$ip:$p"
	else
		site="http://$ip:$p/$webroot"
	fi

	for w in $lists
	do
		ffuf -c -u "$site/FUZZ" -w $w $ext -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.1" $proxy | tee -a "$ip"_"$p"_ffuf.txt
		echo -e $line
	done

	cewl --with-numbers -e -d 4 -u "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.1" "$site/" | grep -v CeWL >> /dev/shm/"$ip"_"$p"_CeWL.txt

#Create lowercase duplicate of the wordlist, merge the lists, & remove any duplicate entries

	duplicut -c /dev/shm/"$ip"_"$p"_CeWL.txt -o /dev/shm/"$ip"_"$p"_lower_CeWL.txt
	cat /dev/shm/"$ip"_"$p"_lower_CeWL.txt >> /dev/shm/"$ip"_"$p"_CeWL.txt
	duplicut /dev/shm/"$ip"_"$p"_CeWL.txt -o "$ip"_"$p"_CeWL.txt

	ffuf -c -u "$site/FUZZ" -w "$ip"_"$p"_CeWL.txt $ext -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.1" $proxy | tee -a "$ip"_"$p"_ffuf.txt
	echo -e $line
done



echo -e "\n[+] Manually perform Subdomain Enumeration for each Web App!\n"
echo -e "\nAdd IP to /etc/hosts if necessary. May need to filter content to exclude results from wildcard DNS resulotion (e.g. -fw 3). Use a command like:\n"
echo 'ffuf -c -u http://example.com:8080 -H "Host: FUZZ.example.com" -w /usr/share/seclists/Discovery/DNS/shubs-subdomains.txt'
