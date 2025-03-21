#!/bin/bash
#
# Simple AUR helper script that maintains the manual installation experience.
#
# This tool will create the directory ~/.aur if its not present and will use
# it to store AUR sources.
#
set -x
dir=$PWD
aur_dir=~/".aur"

# Give user option to view the PKGBUILD/script.
less_prompt() {

read -p ":: View script in less? [Y/n] " choice
  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    less "$script"
  elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
    return
  else 
    less_prompt
  fi
}

# Store folder in case user chooses to not update, for whatever reason, then replace the updated
# folder with the stored folder in order to prompt the user to update it during the next update.
backup() {

  backup_dir=~/".aur/.backup/$name"
  origin_dir="$aur_dir/$name"

  if [ ! -d ~/.aur/.backup ]; then
    mkdir "$dir"
  fi

  if [ "$1" = "store" ]; then
    cp -r "$origin_dir" "$backup_dir"
  elif [ "$1" = "retrieve" ]; then
    rm -rf "$origin_dir" && mv "$backup_dir" "$aur_dir"
  elif [ "$1" = "discard" ]; then
    rm -rf "$backup_dir"
  fi
} 

# Evaluate which method to use for installation.
method() {

  if [ $name = "aurmgr" ]; then
    echo ":: ELEVATED PRIVILEGE REQUIRED TO COPY AURMGR SCRIPT TO /USR/LOCAL/BIN..."
    chmod +x aurmgr.sh && sudo cp -p aurmgr.sh /usr/local/bin/aurmgr && exec "$0" "$@"
  else  
    makepkg -sirc && git clean -dfx
  fi
}

# Prompt user to install or reject.
install_prompt() {

  read -p ":: Proceed with installation? [Y/n] " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      method && backup discard
    elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
      backup retrieve
    fi
}

if [ "$1" = "update" ]; then 

  # Check for updates and install.
  check() {
  
    if git pull | grep -q "Already up to date." ; then
      echo " up to date."
      backup discard
    else
      if [ $name = "aurmgr" ]; then   # Since aurmgr is not an AUR package, it must be updated seperately.
        script="aurmgr.sh"
      else                            # Update AUR packages.
        script="PKGBUILD"
      fi
      echo ":: An update is available for $name..."
      less_prompt && install_prompt
    fi
  }

  # Traverse folders and call check().
  for path in "$aur_dir"/*/ ; do
    name=${path::-1}
    name=${name##*/}

    if [ "$name" = ".backup" ]; then
      continue
    else
      backup store && cd "$path" && echo "-> $name" && check
    fi
  done

  cd "$dir"   # In case script is run outside of /usr/local/bin

# Install new packages.
elif [ "$1" = "install" ]; then

  # Check if .aur exists, create it if not.
  if [ ! -d ~/.aur ]; then
    echo "Creating "$aur_dir" directory..."
    mkdir "$aur_dir"
  fi

  # Clone the source into .aur.
  if [ -n "$2" ]; then
    url="$2"
  else
    read -p ":: Enter package git clone URL: " url
  fi  
  cd ~/.aur && git clone $url

  # cd into new folder.
  name=${url##*/}
  name=${name::-4}
  cd $name

  # Display PKGBUILD and install.
  script="PKGBUILD"
  less_prompt && install_prompt

  cd "$dir"   # In case script is run outside of /usr/local/bin

# Delete directories of packages no longer installed
elif [ "$1" = "clean" ]; then

  # Retrieve list of installed AUR packages from pacman and store in an array
  echo ":: ELEVATED PRIVILEGE REQUIRED TO RETRIEVE INSTALLED LIST FROM PACMAN..."
  installed=( $(sudo pacman -Qm | cut -f 1 -d " ") )

  ntd=true

  # Traverse folders
  for path in "$aur_dir"/*/ ; do
    name=${path::-1}
    name=${name##*/}
    
    match=false

    # Ignore the aurmgr folder
    if [ "$name" = "aurmgr" ] || [ "$name" = ".backup" ]; then
        continue
    fi

    # Find a match for folder name in the array
    for package in ${installed[@]}; do
      if [ "$name" = "$package" ]; then
          match=true
      fi
    done

    # If a match is not found, delete the folder
    if [ "$match" = false ]; then
      echo ":: Package \"$name\" not installed, removing..."
      rm -rf "$aur_dir"/"$name"
      ntd=false
    fi
  done
  
  if [ "$ntd" = true ]; then
      echo " Nothing to do."
  fi

  cd "$dir"   # In case script is run outside of /usr/local/bin
fi
set +x