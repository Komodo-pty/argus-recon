#!/bin/bash

path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')
while true;
do
	echo -e "\nSelect an operation:\n[0] Exit\n[1] Port Scan\n[2] Web App\n[3] SMB\n"
	read mode
	if [ $mode == 0 ]
	then
		break
	fi
	if [ $mode == 1 ]
	then
		source $path/port_scan.sh
	fi
	if [ $mode == 2 ]
	then
		source $path/web_enum.sh
	fi
	if [ $mode == 3 ]
	then
		source $path/smb_logins.sh
	fi

done
