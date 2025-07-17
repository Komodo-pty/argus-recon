#!/bin/bash

path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')
line="\n============================================================\n"
target=""

Help()
{
cat << EOF

Argus will interactively prompt you for input unless you provide the necessary arguments for the selected module.
	
[Options]
	-h: Show this help message
	-i <IP / HOSTNAME>: Enter the target's IP Address
	-m <MODULE>: Specify the module you want to use

[Modules]
	scan: TCP & UDP port scan
	web: Web App recon
	smb: SMB recon
	krb: Kerberos recon
	dns: DNS recon

EOF
}
	
if [ $# -eq 0 ]
then
        echo -e "$line\nNo arguments provided. Defaulting to interactive mode.\n\n[!] Tip: Use the -h argument to view the help menu\n"
else
	while getopts ":hi:m:" option; do
		case $option in
			h)
                        	Help
                                exit;;

			i)
				target=$OPTARG;;

			m)
				mode=$OPTARG;;
		
			\?)
                                echo -e "\nError: Invalid argument"
                                exit;;
                esac
	done
fi

if [[ -z "$mode" ]]
then
	echo -e "\nSelect an operation:\n[1] Port Scan\n[2] Web App\n[3] SMB\n[4] Kerberos\n[5] DNS\n"
	read mode
fi

case "$mode" in
	scan|1)
		echo -e "$line\n[Port Scan]"

		if [[ -n "$target" ]];
		then
			bash "$path"port_scan.sh -i "$target"
		else
			bash "$path"port_scan.sh
		fi
		;;

	web|2)
		echo -e "$line\n[Web App]"

		if [[ -n "$target" ]];
		then
			bash "$path"web_enum.sh -i "$target"
		else
			bash "$path"web_enum.sh
		fi
		;;

	smb|3)
		echo -e "$line\n[SMB]"

		if [[ -n "$target" ]];
		then
			bash "$path"smb_enum.sh -i "$target"
		else
			bash "$path"smb_enum.sh
		fi
		;;

	krb|4)
		echo -e "$line\n[Kerberos]"

		if [[ -n "$target" ]];
		then
			bash "$path"krb_enum.sh -i "$target"
		else
			bash "$path"krb_enum.sh
		fi
		;;

	dns|5)
		echo -e "$line\n[DNS]"

		if [[ -n "$target" ]];
		then
			bash "$path"dns_enum.sh -i "$target"
		else
			bash "$path"dns_enum.sh
		fi
		;;

	*)
		echo -e "\nYou did not select a valid option\n"
		;;
esac
