#!/bin/bash
#
# Copy the aurb scripts to /usr/local/bin so it can be called from
# anywhere in the command line.
#

dir=$PWD

git clone https://github.com/carlyle-felix/aurb.git
cd ~/aurb

echo "Making aurb executable and copying aurb to /usr/local/bin/"
chmod +x aurb.sh && sudo cp -p aurb.sh /usr/local/bin/aurb

cd "$dir"

echo "done."