#!/bin/bash

echo ":: Uninstalling aurb..."

echo ":: ELEVATED PRIVILEGE REQUIRED TO DELETE AURB FROM /USR/LOCAL/BIN..."
sudo rm /usr/local/bin/aurb && rm -rf ~/.aur/aurb

read -p ":: Remove .aur directory recursively? [Y/n] " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then 
    rm -rf ~/.aur
elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
    echo " .aur directory left intact."
fi

echo " done."