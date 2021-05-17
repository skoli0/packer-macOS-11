#!/bin/sh

set -eo pipefail

TOOLS_PATH="/Users/$USER/prl-tools-mac.iso"
# Parallels Tools specific items
if [ -e .PACKER_BUILDER_TYPE ] || [[ "$PACKER_BUILDER_TYPE" == parallels* ]]; then
    if [ ! -e "$TOOLS_PATH" ]; then
        echo "Couldn't locate uploaded tools iso at $TOOLS_PATH!"
        exit 1
    fi

    TMPMOUNT=`/usr/bin/mktemp -d /tmp/parallels-tools.XXXX`
    hdiutil attach "$TOOLS_PATH" -mountpoint "$TMPMOUNT"

    INSTALLER_PKG="$TMPMOUNT/Install.app/Contents/Resources/Install.mpkg"
    if [ ! -e "$INSTALLER_PKG" ]; then
        echo "Couldn't locate Parallels Tools installer pkg at $INSTALLER_PKG!"
        exit 1
    fi

    echo "Installing Parallels Tools..."
    printf "vagrant\n" | sudo -S installer -pkg "$INSTALLER_PKG" -target /

    # This usually fails
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm -f "$TOOLS_PATH"
fi

