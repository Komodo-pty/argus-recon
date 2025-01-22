#!/bin/bash

line="\n============================================================\n"
echo -e "\nEnter target IP / hostname:\n"
read target
echo -e "\nSave Scan Output to file?\n[1] Yes\n[2] No"
read opt

if [ "$opt" == "1" ]
then
	tcp_out="| tee ${target}_TCP.nmap"
	udp_out="| tee ${target}_Top_UDP.nmap"
else
	tcp_out=""
	udp_out=""
fi

echo -e "\nSpecify Scan Type for TCP Ports:\n[1] TCP-Connect (More Accurate?)\n[2] SYN-Stealth"
read scan
echo -e $line
if [ $scan == 1 ]
then
	echo -e "\nTCP-Connect Scan: All ports & default scripts used\n"
	sudo nmap -sT -p- -T4 -sVC -O -Pn -vv $target $tcp_out
	
elif [ $scan == 2 ]
then
	echo -e "\nTCP SYN Scan: All ports & default scripts used\n\n[!] Tip: Consider TCP Connect Scan for OSCP\n"
	echo -e "[!] Tip: Even if Nmap's output says 'Not shown: 1000 open|filtered udp ports (no-response)', there could be UDP Ports in use (i.e. SNMP on 161)\n"
	sudo nmap -p- -T4 -sVC -Pn -vv $target $tcp_out
else
	echo -e "\nYou did not select a valid option\n"
	return
fi
echo -e $line
echo -e "\nUDP Scan: Top 1000 ports\n"
sudo nmap -sUV -T4 -Pn -v $target $udp_out
echo -e $line
