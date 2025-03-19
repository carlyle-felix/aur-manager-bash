#!/bin/bash
#
# Simple AUR helper script that maintains the manual installation experience.
#
# This tool will create the directory ~/.build if its not present and will use
# it to store AUR sources.
#

DIR=$PWD

if [ "$1" = "update" ]; then 
  
  # Check for updates and install
  check() {
  
    if git pull | grep -q "Already up to date." ; then
      echo " up to date."
    else 
      if [$name = "aurmgr"]; then
        less changelog
        read -p ":: Proceed with installation? [Y/n] " choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
          . install.sh
        elif [ "$choice" = "n" ] || [ "$choice" = "n" ]; then
          cd $DIR
          return
        fi
      else 
        less PKGBUILD
        read -p ":: Proceed with installation? [Y/n] " choice
          if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            makepkg -sirc
            git clean -dfx
          elif [ "$choice" = "n" ] || [ "$choice" = "n" ]; then
            cd $DIR
            return
          fi
      fi
    fi
  }

  # Traverse folders and call check()
  for path in ~/.build/*/ ; do
    name=${path::-1}
    name=${name##*/}
    (cd "$path" && echo "-> $name" && check)
  done

elif [ "$1" = "install" ]; then
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
fi