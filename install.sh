#!/bin/bash
#
# Copy the aurmgr scripts to /usr/local/bin so it can be called from
# anywhere in the command line.
#

git clone https://github.com/carlyle-felix/aurmgr.git ~/.build/aurmgr
cd ~/.build/aurmgr
chmod +x aurmgr.sh
sudo cp aurmgr.sh /usr/local/bin/aurmgr
cd