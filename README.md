##Script to build some basic debian packages of ProjectTox related things.

###TODO:
- Add documentation to the package, where available
- Fix some things
- Add toxic

##USE AT YOUR OWN RISK
 - This script is made to provide an easy way to install/uninstall libsodium, ProjectTox-Core and tox-prpl, without clogging up the system with files that would need to uninstalled manually.
 - Both ProjectTox and this script are alpha-quality software.

###Tested on:
- Debian 7 (wheezy) i386
- Ubuntu 12.04 amd64

###Usage:
######(commands preceded by root# need to be run as root, use sudo on ubuntu)
1. Install the following packages:
```bash
root# apt-get install build-essential libtool autotools-dev automake libconfig-dev ncurses-dev libpurple-dev libglib2.0-dev check
```

2. Then clone this repository:
```bash
user$ git clone https://github.com/loadletter/debian-tox.git
user$ cd debian-tox/
```

3. Then build/install the needed libraries:
```bash
user$ make libsodium-all
root# dpkg -i libsodium1.deb libsodium-dev.deb
user$ make libtoxcore-all
root# dpkg -i libtoxcore1.deb libtoxcore-dev.deb
```

4. Then to build/install the Tox pidgin plugin:
```bash
user$ make toxprpl-all
root# dpkg -i toxprpl.deb
```


###Other usage:

- To uninstall everything:
```bash
root# apt-get remove libsodium1 libsodium-dev libtoxcore1 libtoxcore-dev toxprpl
```

- To update (assuming you're already in the debian-tox directory):
```bash
user$ make clean
user$ git pull
```
Then if it's not up-to-date, run the above uninstallation command and repeat installation from step 3.


###License:
GPL3
