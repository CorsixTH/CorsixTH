How to create a debian package in ubuntu:
(should work on other distributions as well, but has not been tested)

1. Compile the game, if desired the map editor and install them with "make install". For the map editor, make sure wxWidgets has been compiled as static libraries.

2. Update the file "control" with a new version number. In the same way edit the menu shortcuts in "usr/share/applications".

3. Create these tarballs in the current directory:

tar --exclude-vcs -chzf data.tar.gz usr/
tar -czf control.tar.gz control prerm postinst

4. Create the package with ar:

ar rcv corsix-th_<version>_<architecture>.deb debian-binary control.data.gz data.tar.gz

where <version> should be the same as specified in "control" and <architecture> either i386 for 32-bit or amd64 for 64-bit packaging.
