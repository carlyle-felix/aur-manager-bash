#!/bin/bash
#
# Simple AUR helper script that maintains the manual installation experience.
#
# This tool will create the directory ~/.aur if its not present and will use
# it to store AUR sources.
#
args="$@"

main() {

  dir=$PWD
  aur_dir=~/".aur"

  if [ "$1" = "update" ]; then 

    updates=false
    update_list=()

    # Traverse folders and call check().
    for path in "$aur_dir"/*/ ; do
      name=${path::-1}
      name=${name##*/}

      if [ $name = ".backup" ]; then
        continue
      else
        backup store && cd "$path" && check
      fi
    done

    if [ $updates = true ]; then
      echo ":: The following packages has updates..."
      for package in ${update_list[@]}; do
      echo " $package"
      done
      update
    else  
      echo " There's nothing to do."
    fi

    cd "$dir"

  elif [ "$1" = "install" ]; then

    if [ ! -d ~/.aur ]; then
      echo "Creating "$aur_dir" directory..."
      mkdir "$aur_dir"
    fi

    if [ -n "$2" ]; then
      url="$2"
    else
      read -p ":: Enter package git clone URL: " url
    fi  
    cd ~/.aur && git clone $url

    name=${url##*/}
    name=${name::-4}
    cd $name
    script="PKGBUILD"
    less_prompt && install_prompt
    
    cd "$dir"

  elif [ "$1" = "clean" ]; then # Delete directories of packages no longer installed

    installed=( $(pacman -Qm | cut -f 1 -d " ") )  # Retrieve list of installed AUR packages from pacman and store in an array

    ntd=true

    for path in "$aur_dir"/*/ ; do
      name=${path::-1}
      name=${name##*/}
      
      match=false

      if [ "$name" = ".backup" ]; then
          continue
      fi

      for package in ${installed[@]}; do
        if [ $name = $package ]; then
            match=true
        fi
      done

      if [ $match = false ]; then
        echo " Package \"$name\" not installed, removing..."
        rm -rf "$aur_dir"/"$name"
        ntd=false
      fi
    done
    
    if [ $ntd = true ]; then
        echo " Theres nothing to do."
    fi

    cd "$dir"
  fi
}

# Give user option to view the PKGBUILD/script.
less_prompt() {

  read -p ":: View $name $script in less? [y/n] " choice
  if [ $choice = "y" ] || [ $choice = "Y" ]; then
    less "$script"
  elif [ $choice = "n" ] || [ "$choice" = "N" ]; then
    return
  else 
    less_prompt
  fi
}

# Store folder in case user chooses to not update, for whatever reason, then replace the updated
# folder with the stored folder in order to prompt the user to update it during the next update.
backup() {

  backup_dir="$aur_dir/.backup/$name"
  origin_dir="$aur_dir/$name"

  if [ ! -d ~/.aur/.backup ]; then
    mkdir "$dir"
  fi

  if [ "$1" = "store" ]; then
    if [ ! -d "$backup_dir" ]; then
      cp -r "$origin_dir" "$backup_dir"
    else  
      echo " Backup for "$name" already exists."
    fi
  elif [ "$1" = "retrieve" ]; then
    rm -rf "$origin_dir" && mv "$backup_dir" "$aur_dir"
  elif [ "$1" = "discard" ]; then
    if [ -d "$backup_dir" ]; then
      rm -rf "$backup_dir"
    fi
  fi
} 

# Evaluate which method to use for installation.
method() {
  makepkg -sirc 
  if [ $args = "update" ]; then
    if [ "$?" = 0 ]; then
      backup discard
    else  
      backup retrieve
      return
    fi
  fi
  git clean -dfx
}

# Prompt user to install or reject.
install_prompt() {

  read -p ":: Proceed with installation? [y/n] " choice
    if [ $choice = "y" ] || [ $choice = "Y" ]; then
      method
    elif [ $choice = "n" ] || [ $choice = "N" ]; then
      backup retrieve
    else  
      install_prompt
    fi
}

# Check for updates and install.
check() {

  if git pull | grep -q "Already up to date." ; then
    backup discard
  else
    updates=true
    update_list+=("$name")
  fi
}

update() {

  read -p ":: Continue to update? [y/n] " choice
  if [ $choice = "y" ] || [ $choice = "Y" ]; then
    for name in ${update_list[@]}; do
      script="PKGBUILD"
      cd "$aur_dir/$name" && less_prompt && install_prompt
    done
  elif [ $choice = "n" ] || [ "$choice" = "N" ]; then
    backup retrieve
  else 
    update
  fi
}

main "$@"
