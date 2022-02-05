#!/bin/sh

SOURCE_REPO="deb [signed-by=/usr/share/keyrings/raspotify_key.asc] https://dtcooper.github.io/raspotify raspotify main"

# Install script for Raspotify. Adds the Debian repo and installs.
set -e

if ! which apt-get apt-key > /dev/null || uname -a | fgrep -ivq -e armv7 -e aarch64 -e x86_64; then
    echo "The Raspotify installer only runs on armhf (ARMv7), arm64, and amd64 Debian based systems."
    exit 1
fi

# You probably have these
PREREQ_PACKAGES="curl apt-transport-https"
PREREQ_PACKAGES_TO_INSTALL=
for package in $PREREQ_PACKAGES; do
    if ! dpkg-query --show --showformat='${db:Status-Status}\n' "$package" 2> /dev/null | grep -q '^installed$'; then
        PREREQ_PACKAGES_TO_INSTALL="$package $PREREQ_PACKAGES_TO_INSTALL"
    fi
done

if [ "$PREREQ_PACKAGES_TO_INSTALL" ]; then
    sudo apt-get update
    sudo apt-get -y install $PREREQ_PACKAGES_TO_INSTALL
fi

# Add public key to apt
curl -sSL https://dtcooper.github.io/raspotify/key.asc | sudo tee /usr/share/keyrings/raspotify_key.asc  > /dev/null
sudo chmod 644 /usr/share/keyrings/raspotify_key.asc
echo "$SOURCE_REPO" | sudo tee /etc/apt/sources.list.d/raspotify.list

sudo apt-get update
sudo apt-get -y install raspotify
