#!/bin/bash
#
# Simple AUR helper script that maintains the manual installation experience.
#
# This tool will create the directory ~/.build if its not present and will use
# it to store AUR sources.
#
#

DIR=$PWD

# Give user option to view the PKGBUILD/script.
less_prompt() {

read -p ":: View script in less? [Y/n] " choice
  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    less "$script"
  elif [ "$choice" = "n" ] || [ "$choice" = "n" ]; then
    cd $DIR
    return
  fi
}

# Evaluate which method to use for installation.
method() {

  if [ $name = "aurmgr" ]; then
    chmod +x aurmgr.sh
    sudo cp aurmgr.sh /usr/local/bin/aurmgr
  else  
    makepkg -sirc
    git clean -dfx
  fi
}

# Prompt user to install or reject.
install_prompt() {

  read -p ":: Proceed with installation? [Y/n] " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      method
    elif [ "$choice" = "n" ] || [ "$choice" = "n" ]; then
      cd $DIR
      return
    fi
}

if [ "$1" = "update" ]; then 

  # Check for updates and install.
  check() {
  
    if git pull | grep -q "Already up to date." ; then
      echo " up to date."
    else
      if [ $name = "aurmgr" ]; then   # Since aurmgr is not an AUR package, it must be updated seperately.
        script="aurmgr.sh"
      else                            # Update AUR packages.
        script="PKGBUILD"
      fi
      echo ":: An update is available for $name..."
      less_prompt
      install_prompt
    fi
  }

  # Traverse folders and call check().
  for path in ~/.build/*/ ; do
    name=${path::-1}
    name=${name##*/}
    (cd "$path" && echo "-> $name" && check)
  done

# Install new packages.
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

  # Display PKGBUILD and install.
  script="PKGBUILD"
  less_prompt
  install_prompt
fi