#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# stop screensaver from wheezing the juice
defaults -currentHost write com.apple.screensaver idleTime 0

# kill feedback assistant
pkill Feedback || true

# cleanup ssh enablement from install process
if [[ -e /Library/LaunchDaemons/ssh.plist ]]; then
  printf "vagrant\n" | sudo -S launchctl unload -w /Library/LaunchDaemons/ssh.plist
  printf "vagrant\n" | sudo -S rm /Library/LaunchDaemons/ssh.plist
  #sudo /usr/sbin/systemsetup -f -setremotelogin on
  printf "vagrant\n" | sudo -S launchctl load -w /System/Library/LaunchDaemons/ssh.plist
fi

# printf "vagrant\n" | sudo -S echo "vagrant     ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

exit 0
