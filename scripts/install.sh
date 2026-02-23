#!/bin/bash

echo "Installing packages..."

sudo apt update

sudo dpkg --set-selections < packages/installed-packages.txt
sudo apt-get dselect-upgrade -y

echo "✅ Packages installed!"
