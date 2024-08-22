#!/bin/bash

line="\n============================================================\n"
echo -e "\nEnter target IP / hostname:"
read ip
echo -e $line
echo -e "\nTCP SYN Scan: All ports & default scripts used\n"
sudo nmap -p- -T4 -sVC -Pn -vv $ip | tee "$ip"_TCP.nmap
echo -e $line
echo -e "\nUDP Scan: Top 1000 ports\n"
sudo nmap -sUV -T4 -v $ip | tee "$ip"_Top_UDP.nmap
echo -e $line
