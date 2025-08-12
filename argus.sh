#!/bin/bash

path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')
line="\n============================================================\n"
mode=""
module_args=()

detected_module=false
detected_help=false

Help()
{
cat << EOF

Argus will interactively prompt you for input unless you provide the necessary arguments for the selected module.
	
[Options]
	-h: Show this help menu
	-m <MODULE>: Specify the module you want to use
	-m <MODULE> -h: Show specified module's help menu

[Modules]
	scan: TCP & UDP port scan
	web: Web App recon
	smb: SMB recon
	krb: Kerberos recon
	dns: DNS recon

EOF
exit 0
}

for arg in "$@"
do
  [[ "$arg" == "-m" ]] && detected_module=true
  [[ "$arg" == "-h" ]] && detected_help=true
done	

# If -h was used but -m wasn't, show Argus help menu
if $detected_help && ! $detected_module
then
  Help
fi

while [[ $# -gt 0 ]]
do
  case "$1" in
    -m)
      mode="$2"
      shift 2
      ;;

    -*)
      #Handle module args, using shift to process args regardless of order
      
      module_args+=("$1")
      if [[ -n "$2" && "$2" != -* ]]; then
        module_args+=("$2")
	shift
      fi
      shift
      ;;

    *)
      shift
      ;;
  esac
done


if [[ -z "$mode" ]]
then
  cat <<EOF
Select a Module

[Modules]
	[1] Port Scan
	[2] Web App
	[3] SMB
	[4] Kerberos
	[5] DNS
EOF
  read mode
fi

case "$mode" in
  scan|1)
    echo -e "$line\n[Port Scan]\n"
    bash "$path"port_scan.sh "${module_args[@]}"
    ;;

  web|2)
    echo -e "$line\n[Web App]\n"
    bash "$path"web_enum.sh "${module_args[@]}"
    ;;

  smb|3)
    echo -e "$line\n[SMB]\n"
    bash "$path"smb_enum.sh "${module_args[@]}"
    ;;

  krb|4)
    echo -e "$line\n[Kerberos]\n"
    bash "$path"krb_enum.sh "${module_args[@]}"
    ;;

  dns|5)
    echo -e "$line\n[DNS]\n"
    bash "$path"dns_enum.sh "${module_args[@]}"
    ;;

  *)
    echo -e "\nYou did not select a valid option\n"
    Help
    ;;
esac
