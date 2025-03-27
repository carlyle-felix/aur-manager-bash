A helper for the Arch User Repository.

These scripts automates some of the steps found in the official AUR guide without the need to remember the commands.


## MANUAL INSTALLATION

```
git clone https://github.com/carlyle-felix/aurb.git ~/.build/aurb
cd ~/.build/aurb
chmod +x aurb.sh
sudo cp aurb.sh /usr/local/bin/aurb
```
## AUTOMATED INSTALL (install.sh)

This script automates the steps in the manual installation, user password is
requested for the copying in final command.
```
curl -LSs "https://raw.githubusercontent.com/carlyle-felix/aurb/refs/heads/main/install.sh" | bash -
```

## NO INSTALL

Use `./aurb.sh [option]` instead of `aurb [option]` in the directory where aurb.sh is stored.

## USAGE
***


`aurb update` updates packages found in ~/.aur.

`aurb install` or `aurb install [AUR package git clone URL]` clones package to ~/.aur and installs.

`aurb clean` deletes directories in ~/.aur if they're not found in `pacman -Qm`