#!/bin/bash

line="\n============================================================\n"
echo -e "[!] Tip: This queries a DNS Server, but it isn't a replacement for other DNS Enumeration techniques (e.g. fuzzing subdomains with ffuf)\n"

echo -e "\nEnter the target's hostname:"
read hostname

echo -e "\nEnter the DNS Server's IP Address:"
read server

echo -e "$line\n[Basic DNS Queries]\n$line\nLookup any records:\n"

dig any $hostname @$server

echo -e "$line\nLookup additional DNS Server info:\n"

dig all $hostname @$server

echo -e "$line\n[AXFR]\n$line\n[!] Tip: If the output shows 'Transfer failed' it means that this type of query isn't supported by the DNS Server\n\nAttempting Zone Transfer:\n"

dig axfr $hostname @$server

echo -e "$line"
