#!/bin/bash
#
# Copy the aurmgr scripts to /usr/local/bin so it can be called from
# anywhere in the command line.
#

dir=$PWD

git clone https://github.com/carlyle-felix/aurmgr.git ~/.aur/aurmgr
cd ~/.aur/aurmgr

echo "Making aurmgr executable and copying aurmgr to /usr/local/bin/"
chmod +x aurmgr.sh && sudo cp -p aurmgr.sh /usr/local/bin/aurmgr

cd "$dir"

echo "done."