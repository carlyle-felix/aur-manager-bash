#!/bin/bash
#
# Main script for aurmgr
#

DIR=$PWD

if [ "$1" = "update" ]; then 
  . aurmanager/aur-update.sh
elif [ "$1" = "install" ]; then
  . aurmanager/aur-install.sh
fi
