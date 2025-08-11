#!/bin/bash
cat <<EOF

What format do you want the impacket dependencies?

[1] Create Symlinks for Kali (e.g. impacket-lookupsid)

[2] Create Symlinks for standalone installation (e.g. lookupsid.py)

EOF

read choice

depends=( "lookupsid" )

if (( choice == 1 ))
then
  for i in "${depends[@]}"; do 
    src=$(which impacket-$i 2>/dev/null)
    dest="$HOME/.local/bin/$i.py"

    if [[ -x "$src" ]]; then
      ln -s "$src" "$dest"
      echo "Linked $src -> $dest"
    else
      echo "impacket-$i not found in PATH"
    fi
  done

elif (( choice == 2 ))
then
  for i in "${depends[@]}"; do
    src=$(which $i.py 2>/dev/null)
    dest="$HOME/.local/bin/impacket-$i"
    if [[ -x "$src" ]]; then
      ln -s "$src" "$dest"
      echo "Linked $src -> $dest"
    else
      echo "$i.py not found in PATH"
    fi
  done

else
  echo "Invalid selection. When prompted, enter a either 1 or 2"
fi
