A helper for the Arch User Repository.

These scripts automates some of the steps found in the official AUR guide without the need to remember the commands.


## MANUAL INSTALLATION
***
```
git clone https://github.com/carlyle-felix/aurmgr.git ~/.build/aurmgr
cd ~/.build/aurmgr
chmod +x aurmgr.sh
sudo cp aurmgr.sh /usr/local/bin/aurmgr
```
## AUTOMATED INSTALL (install.sh)
***
This script automates the steps in the manual installation, user password is
requested for the copying in final command.
```
curl -LSs "https://raw.githubusercontent.com/carlyle-felix/aurmgr/refs/heads/main/install.sh" | bash -
```

## USAGE
***


`aurmgr update`
`aurmgr install` or `aurmgr install _[AUR package git clone URL]_`