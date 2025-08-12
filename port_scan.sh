#!/bin/bash

line="\n============================================================\n"
target=""
outfile=false
scan="syn"
time="3"

Help()
{
  cat <<EOF
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target's IP Address
	-o: Save scan scan results to an output file
	-s <SCAN>: Type of TCP port scan to perform (in addition to UDP scan)
	-T <0-5>: Set timing template (higher is faster)

[Scans]
	[!] Tip: Some scans are more or less reliable depending on the target


	con|T: TCP Connect Scan
	syn|S: SYN Stealth Scan
	exo|E: Exotic scans (i.e. TCP Null, FIN, and Xmas scans) {COMING SOON}

	[+] Example: "-sT" is equivilent to "-s con"

EOF
exit 0
}

while getopts ":hi:os:T:" option
do
  case $option in
    h)
      Help
      ;;
    i)
      target="$OPTARG"
      ;;

    o)
      outfile=true
      ;;
    s)
      scan="$OPTARG"
      ;;
    T)
      time="$OPTARG"
      ;;
  esac
done

if [[ -z "$target" ]];
then
  echo -e "\nEnter target IP / hostname:\n"
  read target
fi

if [[ $outfile == true ]]
then
  tcp_out="-oN ${target}_TCP.nmap"
  udp_out="-oN ${target}_Top_UDP.nmap"
else
  tcp_out=""
  udp_out=""
fi

case "$scan" in

  con|T)
    echo -e "$line\n[TCP Connect Scan]\nAll ports & default scripts used\n"
    sudo nmap -sT -p- -T"$time" -sVC -O -Pn -vv $target $tcp_out
    ;;

  syn|S)
    echo -e "$line\n[TCP SYN Scan]\nAll ports & default scripts used\n"
    sudo nmap -p- -T"$time" -sVC -O -Pn -vv $target $tcp_out
    ;;

  *)
    echo -e "Select a different scan type. More scans coming soon."
    Help
    ;;

esac

echo -e "$line\n[UDP Scan]\nTop 1000 ports\n"
echo -e "[!] Tip: Even if Nmap's output says 'Not shown: 1000 open|filtered udp ports (no-response)', there could be UDP ports in use (i.e. SNMP on 161)\n"
sudo nmap -sUV -T"$time" -Pn -v $target $udp_out
