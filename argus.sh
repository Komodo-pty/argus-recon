#!/bin/bash

path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')
while true;
do
	echo -e "\nSelect an operation:\n[0] Exit\n[1] Port Scan\n[2] Web App\n[3] SMB\n"
	read mode

	if [ $mode == 0 ]
	then
		break

	elif [ $mode == 1 ]
	then
		source $path/port_scan.sh

	elif [ $mode == 2 ]
	then
		source $path/web_enum.sh

	elif [ $mode == 3 ]
	then
		source $path/smb_logins.sh

	else
		echo -e "\nYou did not select a valid option\n"
	fi

done
