#!/bin/bash

line="\n============================================================\n"
echo -e "\nEnter target IP / hostname:\n"
read target
echo -e "\nSpecify Scan Type for TCP Ports:\n[1] TCP-Connect (More Accurate?)\n[2] SYN-Stealth"
read scan
echo -e $line
if [ $scan == 1 ]
then
	echo -e "\nTCP-Connect Scan: All ports & default scripts used\n"
	sudo nmap -sT -p- -T4 -sVC -Pn -vv $target | tee "$target"_TCP.nmap
	
elif [ $scan == 2 ]
then
	echo -e "\nTCP SYN Scan: All ports & default scripts used\n\n[!] Tip: Consider TCP Connect Scan for OSCP\n"
	sudo nmap -p- -T4 -sVC -Pn -vv $target | tee "$target"_TCP_SYN.nmap
else
	echo -e "\nYou did not select a valid option\n"
	return
fi
echo -e $line
echo -e "\nUDP Scan: Top 1000 ports\n"
sudo nmap -sUV -T4 -Pn -v $target | tee "$target"_Top_UDP.nmap
echo -e $line
