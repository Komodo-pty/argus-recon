#!/bin/bash

path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')
while true;
do
	echo -e "\nSelect an operation:\n[0] Exit\n[1] Port Scan\n[2] Web App\n[3] SMB\n[4] Kerberos\n[5] DNS"
	read mode

	if [ $mode == 0 ]
	then
		break

	elif [ $mode == 1 ]
	then
		source "$path"port_scan.sh

	elif [ $mode == 2 ]
	then
		source "$path"web_enum.sh

	elif [ $mode == 3 ]
	then
		source "$path"smb_enum.sh

	elif [ $mode == 4 ]
	then
		source "$path"krb_enum.sh
	elif [ $mode == 5 ]
	then
		source "$path"dns_enum.sh

	else
		echo -e "\nYou did not select a valid option\n"
	fi

done
