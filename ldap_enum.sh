#!/bin/bash

line="\n============================================================\n"
target=""
domain=""
root=""
username=""
passwd=""
outfile=""

Help()
{
  cat <<EOF
[Options]
        -h: Display this help menu
        -i <IP_ADDRESS>: The target's IP Address
	-d <DOMAIN>: The target's domain (e.g., xample.local). If no domain is provided, it'll be automatically detected
	-u <USERNAME>: Specify a username
        -p <PASSWORD>: Specify a password
	-x <MODE>: Specify the operation to perform
	-o <OUTFILE>: Save output to specified file, extracting usernames & hosts

[Modes]
	enum: Basic enumeration
	user: Enumerate users
	host: Enumerate hosts
	hound: Remote Bloodhound enumeration against a DC

[!] Tip: Credentials are usually required for more detailed methods of enumeration

[Usage]
	argus -m ldap -x user -i 12.34.56.789 -d example.local -u bob -p 'passwd123!' -o user_list.txt
	argus -m ldap -x enum -i 12.34.56.789

EOF
  exit 0
}

Enum()
{
  nmap -n -sV --script "ldap* and not brute" -p389 "$target" -Pn
}

while getopts ":hi:d:u:p:x:o:" option; do
  case $option in
    h)
      Help
      ;;
    i)
      target="$OPTARG"
      ;;
    d)
      domain="$OPTARG"
      ;;
    u)
      username="$OPTARG"
      ;;
    p)
      passwd="$OPTARG"
      ;;
    x)
      mode="$OPTARG"
      ;;
    o)
      outfile="$OPTARG"
      ;;
  esac
done

if [[ -z "$target" ]]; then
  echo -e "\nEnter target IP / hostname:\n"
  read target
fi

if [[ -z "$mode" ]]; then
  cat << EOF
[Modes]
	enum: Basic enumeration
	user: Enumerate users
	host: Enumerate hosts
	hound: Remote Bloodhound enumeration against a DC

[!] Tip: Credentials are usually required for more detailed methods of enumeration
EOF
  read mode
fi

if [[ "$mode" != "enum" ]]; then

  if [[ -z "$domain" ]]; then
    echo -e "$line\nDomain not provided. Attempting to automatically retrieve it.\n"
    root=$(Enum | tee /dev/tty | grep "rootDomainNamingContext:" | awk -F 'rootDomainNamingContext: ' '{print $2}')
    echo -e "$line"

    if [[ "$mode" == "hound" ]]; then
      domain=$(echo -n "$root" | sed -E 's/DC=([^,]+)/\1/g; s/,/./g')
    fi
  fi

  if [[ -z "$username" || -z "$passwd" ]]; then
    echo -e "\nAttempting anonymous connection. Credentials are usually required for this action.\n$line"
    creds="false"

    if [[ "$mode" == "user" || "$mode" == "host" ]]; then
      dn="CN=$username,CN=Users,$root"
    fi

  else
    creds="true"
  fi
fi

case "$mode" in
  enum)
    if [[ -n "$outfile" ]]; then
      Enum | tee -a "$outfile"
    else
      Enum
    fi
    ;;
  user)
    if [[ "$creds" == "false" ]]; then
      output=$(ldapsearch -H "ldap://$target" -x -b "$root" "(objectClass=user)" sAMAccountName | tee /dev/tty | grep "sAMAccountName" | awk -F 'sAMAccountName: ' '{print $2}')
    elif [[ "$creds" == "true" ]]; then
      output=$(ldapsearch -H "ldap://$target" -x -D "$dn" -w "$passwd" -b "$root" "(objectClass=user)" sAMAccountName | tee /dev/tty | grep "sAMAccountName" | awk -F 'sAMAccountName: ' '{print $2}')
    fi

    if [[ -n "$outfile" ]]; then
      for user in "$output"; do
        echo "$user" >> "$outfile"
      done
    fi
    ;;
  host)
    if [[ "$creds" == "false" ]]; then
      output=$(ldapsearch -H "ldap://$target" -x -b "$root" "(objectClass=computer)" sAMAccountName | tee /dev/tty | grep "sAMAccountName" | awk -F 'sAMAccountName: ' '{print $2}')
    elif [[ "$creds" == "true" ]]; then
      output=$(ldapsearch -H "ldap://$target" -x -D "$dn" -w "$passwd" -b "$root" "(objectClass=computer)" sAMAccountName | tee /dev/tty | grep "sAMAccountName" | awk -F 'sAMAccountName: ' '{print $2}')
    fi

    if [[ -n "$outfile" ]]; then
      for computer in "$output"; do
        echo "$computer" >> "$outfile"
      done
    fi
    ;;

  hound)
    if [[ "$creds" == "false" ]]; then
      nxc ldap "$target" -d "$domain" --bloodhound -c All --dns-server "$target"
    elif [[ "$creds" == "true" ]]; then
      nxc ldap "$target" -d "$domain" -u "$username" -p "$passwd" --bloodhound -c All --dns-server "$target"
    fi
    ;;

  *)
    echo -e "\nYou did not select a valid mode\n"
    Help
    ;;
esac
