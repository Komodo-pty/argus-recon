#!/bin/bash
cat <<EOF

Adding argus to PATH & verifying that impacket dependencies are in the correct format

Creating Symlinks for impacket tools from standalone installation (e.g. lookupsid.py -> impacket-lookupsid)

EOF

depends=( "lookupsid" )

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

src="$(pwd)/argus.sh"
chmod +x "$src"
ln -s "$src" "$HOME/.local/bin/argus"
ls -l $(which argus)
