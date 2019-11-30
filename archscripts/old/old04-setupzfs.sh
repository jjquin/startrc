#!/bin/sh

#
# chroot then start this script from /root in chroot
#


#
# add archzfs repository to pacman.conf
#

read -p "Press Enter to add archzfs repository to pacman.conf..."

echo "adding archzfs repository to pacman.conf"
sed -i -e '/# uncommented to enable the repo./ a\
[archzfs]\
SigLevel = Optional TrustAll\
Server = http://archzfs.com/$repo/x86_64' /etc/pacman.conf

grep -A 2 archzfs /etc/pacman.conf
read -p "Press Enter if pacman.conf changed correctly..."


#
# adding archzfs keys
#

read -p "Press Enter to add archzfs keys..."

echo "requesting key"
pacman-key -r 5E1ABF240EE7A126

echo "signing key"
pacman-key --lsign-key 5E1ABF240EE7A126

#
# installing zfs on linux
#

read -p "Press Enter to install zfs on linux..."

echo "updating arch linux"
pacman -Syu

echo "instaling zfs on linux"
pacman -S zfs-linux

echo "copy zfs.conf to /etc/modprobe.d"
cp /root/zfs.conf /etc/modprobe.d/zfs.conf

read -p "Press Enter to enable systemctl zfs services..."

echo "enabling zfs systemd services"
systemctl enable zfs.target
systemctl enable zfs-import-cache
systemctl enable zfs-mount
systemctl enable zfs-import.target



