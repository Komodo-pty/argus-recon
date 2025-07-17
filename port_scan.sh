#!/bin/bash

line="\n============================================================\n"
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


echo -e "\nSave Scan Output to file?\n[1] Yes\n[2] No\n"
read opt

while true;
do
	echo -e "\nHow fast should the scan be? Enter a timing value (1-5):\n\n[!] Tip: 3 is the default speed. Anything faster may be less reliable.\n"
	read timing

	if [[ "$timing" == "1" || "$timing" == "2" || "$timing" == "3" || "$timing" == "4" || "$timing" == "5" ]]
	then
		break 
	else
		echo "Invalid input. Please enter a number from 1 to 5."
	fi
done

if [ "$opt" == "1" ]
then
	tcp_out="-oN ${target}_TCP.nmap"
	udp_out="-oN ${target}_Top_UDP.nmap"
else
	tcp_out=""
	udp_out=""
fi

echo -e "\nSpecify Scan Type for TCP Ports:\n[1] TCP-Connect\n[2] SYN-Stealth\n\n[!] Tip: Depending on config, one type of scan may be more accurate.\n"
read scan
echo -e $line
if [ $scan == 1 ]
then
	echo -e "\nTCP-Connect Scan: All ports & default scripts used\n"
	sudo nmap -sT -p- -T"$timing" -sVC -O -Pn -vv $target $tcp_out
	
elif [ $scan == 2 ]
then
	echo -e "\nTCP SYN Scan: All ports & default scripts used\n\n[!] Tip: Consider TCP Connect Scan for OSCP\n"
	echo -e "[!] Tip: Even if Nmap's output says 'Not shown: 1000 open|filtered udp ports (no-response)', there could be UDP Ports in use (i.e. SNMP on 161)\n"
	sudo nmap -p- -T"$timing" -sVC -O -Pn -vv $target $tcp_out
else
	echo -e "\nYou did not select a valid option\n"
	return
fi
echo -e $line
echo -e "\nUDP Scan: Top 1000 ports\n"
sudo nmap -sUV -T"$timing" -Pn -v $target $udp_out
echo -e $line
