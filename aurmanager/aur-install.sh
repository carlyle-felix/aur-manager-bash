#!/bin/bash
#
# Install AUR packages
# 
# The script downloads all AUR sources into ~/.build
#
build=~/.build

# Check if .build exists, create it if not.
if [ ! -d $build ]; then
  echo "Creating .build"
  mkdir $build
fi

# Clone the source into .build.
read -p ":: Enter package git clone URL: " url
cd $build
git clone $url

# cd into new folder.
name=${url##*/}
name=${name::-4}
cd $name

# Display PKGBUILD and install 
less PKGBUILD
read -p ":: Proceed with installation? [Y/n] " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
  makepkg -sirc
  git clean -dfx
elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
  cd $DIR
  return
fi
