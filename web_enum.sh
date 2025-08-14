#!/bin/bash

line="\n============================================================\n"
path=$(readlink $(which argus) | awk -F 'argus.sh' '{print $1}')

#Add output file option & set name var for each test. If out=yes make file based off of name var's value. Collect output with '| tee -a ...'
#Consider ffuf -timeout so you can move onto the next target if one isnt responding

target=""
ports=""
lists=""
ext=""
user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.1"

Help()
{
 cat <<EOF
[Options]
	-h: Display this help menu
	-i <IP_ADDRESS>: The target's IP Address
	-p <PORT[:tls][:url:WEBROOT]>: Comma seperated list of ports. HTTP is used unless ":tls" is specified. Optionally specify ":url:PATH" (e.g. 80:url:wordpress for /wordpress/)
	-w <WORDLISTS>: Comma seperated file paths to wordlists for subdirectory enumeration
	-e <EXTENSIONS>: Comma seperated file extensions to test (e.g. .php,.bak,.html,.txt,.old)
	-u <USER_AGENT>: Specify value for the User-Agent HTTP Header (between quotes)
EOF
exit 0
}


while getopts ":hi:p:w:e:u:" option; do
  case $option in
    h)
      Help
      ;;
    i)
      target="$OPTARG"
      ;;
    p)
      ports="$OPTARG"
      IFS=',' read -ra port_array <<< "$ports"
      ;;
    w)
      lists="$OPTARG"
      IFS=',' read -ra list_array <<< "$lists"
      ;;
    e)
      ext="-e $OPTARG"
      ;;
    u)
      user_agent="$OPTARG"
      ;;
  esac
done

if [[ -z "$target" ]];
then
	echo -e "\nEnter target IP / hostname:\n"
	read target
fi

if [[ -z "$ports" ]]; then
  cat <<EOF
Enter space seperated list of Web App ports

HTTP is used unless ":tls" is specified. Optionally specify subdirectory with ":url:PATH" (e.g. 80:url:wordpress for /wordpress/)

EOF
  read -ra port_array
fi

echo -e "\nAre you using burpsuite or ZAP? [y/N]\n"
read choice

if [ $choice == "y" ]
then
	proxy="-replay-proxy http://localhost:8080"
else
	proxy=""
fi
###

for entry in "${port_array[@]}"; do
  protocol="http"
  webroot=""

  # Check if the entry contains `:tls` or `:https` to set protocol
  if [[ "$entry" == *":tls" || "$entry" == *":https" ]]; then
    port=$(echo "$entry" | cut -d':' -f1)
    protocol="https"

    # Check if there's a webroot specified after :url:
    if [[ "$entry" == *":url:"* ]]; then
      webroot=$(echo "$entry" | cut -d':' -f4)  # Extract webroot after :url:
    fi
  else
    # Handle case for default HTTP protocol or user-specified webroot
    if [[ "$entry" == *":url:"* ]]; then
      port=$(echo "$entry" | cut -d':' -f1)
      webroot=$(echo "$entry" | cut -d':' -f3)  # Extract webroot after :url:
    else
      port="$entry"  # Just a port, default to HTTP
      protocol="http"
    fi
  fi

  site="$protocol://$target:$port"
  if [[ -n "$webroot" ]]; then
    site="$site/$webroot"
  fi
  echo -e "$line\n[Testing $site]\n$line"

#Fingerprinting
  echo -e "\nFingerprinting: $site\n"
  whatweb -a 3 -v --user-agent "$user_agent" "$site"
  echo -e $line

#Scraping Links
  echo -e "\nLinks on webpage: $site\n\nLook for Domain Names & interesting filenames\n[!] Tip: Manually review Source Code to ensure nothing was missed\n"
	
  export site

  result=$(python3 $path/web_scraper.py)
  scrape=$(echo "${result[@]}" | sort | uniq)
  echo "$scrape"

  if [ "$proxy" != "" ]; then
    echo -e "\nPopulating Burpsuite's sitemap with URLs found (Ensure that you setup Burp's scope)\n"
    for i in $scrape; do

      # Check if the link is a full URL
      if [[ "$i" =~ ^https?:// ]]; then		
        url="$i"  # It's a full URL
			
      elif [[ "$i" =~ ^/ ]]; then
        url="$site$i"  # It's an absolute path (starts with /), so prepend the base site URL
      else
        # It's a relative path without leading /, so append it to the current base URL
				
        url="$site/$i"
      fi
      curl -s "$url" -x http://localhost:8080 > /dev/null
    done
  else
    echo -e "\nManually check each of the links that are in your scope\n"
  fi

  echo -e $line

#Subdirectory Enumeration

#ffuf is having issues when supplied with comma seperated wordlists, so iterate through wordlists with for loop instead
  if [[ -z "$lists" ]]; then
    echo -e "\nEnter space seperated list of wordlist paths for Subdirectory Enumeration\n"
    read -ra list_array
  fi

  if [[ -z "$ext" ]]; then
    echo -e "\nDo you want to use extensions for Subdirectory Enumeration? [y/N]\n"
    read choice

    if [ $choice == "y" ]; then
      echo -e "\nEnter comma seperated list of extensions for ffuf (e.g. .php,.bak,.html,.txt,.old)\n"
      read choice
      ext="-e $choice"
    fi
  fi
 
  echo -e $line

  for w in "${list_array[@]}"; do
    ffuf -c -u "$site/FUZZ" -w "$w" $ext -H "User-Agent: $user_agent" $proxy 
    echo -e $line
  done

  cewl --with-numbers -e -d 4 -u "$user_agent" "$site/" | grep -v CeWL >> /dev/shm/"$target"_"$p"_basic_CeWL.txt

#Create lowercase duplicate of the wordlist, merge the lists, & remove any duplicate entries

  duplicut -c /dev/shm/"$target"_"$p"_basic_CeWL.txt -o /dev/shm/"$target"_"$p"_lower_CeWL.txt
  cat /dev/shm/"$target"_"$p"_lower_CeWL.txt >> /dev/shm/"$target"_"$p"_basic_CeWL.txt
  duplicut /dev/shm/"$target"_"$p"_basic_CeWL.txt -o "$target"_"$p"_CeWL.txt

  ffuf -c -u "$site/FUZZ" -w "$target"_"$p"_CeWL.txt $ext -H "User-Agent: $user_agent" $proxy 
  echo -e $line
done

cat <<EOF
	[+] Manually perform Subdomain Enumeration for each Web App!

	Add IP to /etc/hosts if necessary. May need to filter content to exclude results from wildcard DNS resulotion (e.g. -fw 3). Use a command like:
	ffuf -c -u http://example.com:8080 -H "Host: FUZZ.example.com" -w /usr/share/seclists/Discovery/DNS/shubs-subdomains.txt
EOF
