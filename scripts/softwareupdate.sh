#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# boot in verbose mode to debug
# sudo nvram boot-args="-v"

# enable developer beta
if [[ $SEEDING_PROGRAM != "none" ]]; then
  printf "vagrant\n" | sudo -S /System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/seedutil enroll $SEEDING_PROGRAM
fi

# check update state and save it to a log file to survive reboots
printf "vagrant\n" | sudo -S softwareupdate -l 2>&1 | tee ~/Library/Logs/packer_softwareupdate.log

# check log file to see if updates are available and install them if so
if (grep "No new software available" ~/Library/Logs/packer_softwareupdate.log); then
  echo "No software updates found"
else
  echo "$(date +"%Y-%m-%d %T") packer installing software updates and rebooting" | tee ~/Library/Logs/install.log
  printf "vagrant\n" | sudo -S softwareupdate -iaR
  sleep 30
fi

exit 0
