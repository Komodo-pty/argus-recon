#!/bin/bash

echo -e "What format do you want the impacket dependencies?\n"
echo -e "[1] Kali (impacket-lookupsid)\n[2] Standalone installation (lookupsid.py)\n"
read choice

if [ $choice == 1 ]
then
	sed -i 's/lookupsid.py/impacket-lookupsid/g' smb_enum.sh
elif [ $choice == 2 ]
then
	sed -i 's/impacket-lookupsid/lookupsid.py/g' smb_enum.sh
else
	echo "Invalid selection. When prompted, enter either 1 or 2"
fi
