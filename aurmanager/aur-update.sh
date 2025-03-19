#!/bin/bash
#
# Check for AUR updates
# 
# The script assumes all AUR sources are in ~/.build
#

# Check for updates and install
check() {

  if git pull | grep -q "Already up to date." ; then
    echo " up to date."
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
}

# Traverse folders and call check()
for path in ~/.build/*/ ; do
  name=${path::-1}
  name=${name##*/}
  (cd "$path" && echo "-> $name" && check)
done
