#!/bin/bash

line="\n============================================================\n"
hostname=""
server=""

Help(){
cat <<EOF
[Options]
	-h: Display this help menu
	-i <HOSTNAME>: The target's hostname
	-s <DNS_SERVER>: The DNS Server's IP Address

[!] Tip: This queries a DNS Server, but it isn't a replacement for other DNS Enumeration techniques (e.g. fuzzing subdomains with ffuf)
EOF
exit 0
}

while getops ":hi:s:" option; do
  case "$option" in
    h)
      Help
      ;;
    i)
      hostname="$OPTARG"
      ;;
    s)
      server="$OPTARG"
      ;;
  esac
done

if [[ -z "$hostname" ]]; then
  echo -e "\nEnter the target's hostname:"
  read hostname
fi

if [[ -z "$server" ]] ; then
  echo -e "\nEnter the DNS Server's IP Address:"
  read server
fi

echo -e "$line\n[Basic DNS Queries]\n$line\nLookup any records:\n"

dig any $hostname @$server

echo -e "$line\nLookup additional DNS Server info:\n"

dig all $hostname @$server

echo -e "$line\n[AXFR]\n$line\n[!] Tip: If the output shows 'Transfer failed' it means that this type of query isn't supported by the DNS Server\n\nAttempting Zone Transfer:\n"

dig axfr $hostname @$server
