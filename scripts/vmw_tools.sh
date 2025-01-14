#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# mount the iso and install
hdiutil mount ~/darwin.iso
sudo installer -pkg "/Volumes/VMware Tools/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target / || true
hdiutil unmount /Volumes/VMware\ Tools
rm ~/darwin.iso

# authorize kexts

# authorize tools binary

# output version installed
/Library/Application\ Support/VMware\ Tools/vmware-tools-cli -v

# restart the box
sudo reboot

exit 0
