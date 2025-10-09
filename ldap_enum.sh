#!/bin/bash

line="\n============================================================\n"
target=""
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

[!] Tip: You usually need to authenticate for user & host enumeration

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
      dom=$(echo -n "$OPTARG" | awk -F '.' '{print $1}')
      tld=$(echo -n "$OPTARG" | awk -F '.' '{print $2}')
      root="DC=$dom,DC=$tld"
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
Select the operation to perform:

[1] enum: Basic enumeration
[2] user: Enumerate users
[3] host: Enumerate hosts

[!] Tip: User & host enum usually requires creds for authentication
EOF
  read mode
fi

if [[ "$mode" != "enum" && "$mode" != "1" ]]; then
  if [[ -z "$root" ]]; then
    echo -e "$line\nDomain not provided. Attempting to automatically retrieve it.\n"
    root=$(Enum | tee /dev/tty | grep "rootDomainNamingContext:" | awk -F 'rootDomainNamingContext: ' '{print $2}')
    echo -e "$line" 
  fi

  if [[ -z "$username" || -z "$passwd" ]]; then
    echo -e "\nAttempting anonymous connection. Credentials are usually required for this action.\n$line"
    creds="false"
  else
    dn="CN=$username,CN=Users,$root"
    creds="true"
  fi
fi

case "$mode" in
  enum|1)
    if [[ -n "$outfile" ]]; then
      Enum | tee -a "$outfile"
    else
      Enum
    fi
    ;;
  user|2)
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
  host|3)
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
  *)
    echo -e "\nYou did not select a valid mode\n"
    Help
    ;;
esac
