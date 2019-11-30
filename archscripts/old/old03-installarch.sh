#!/bin/sh

#
# updating mirrorlist
#

read -p "Press Enter to update mirrorlist file..."

echo "backup up old mirrorlist"
mv /root/mirrorlist /root/mirrorlist.old

echo "creating updated mirrorlist"
curl -s "https://www.archlinux.org/mirrorlist/?country=US&use_mirror_status=on" | \
     sed -e 's/^#Server/Server/' -e '/^#/d' | \
     rankmirrors -n 20 - > /root/mirrorlist

#
# pacstrap
#

read -p "Press Enter to install basic arch (pacstrap)..."

echo "copying updated mirrorlist"
cp /root/mirrorlist /etc/pacman.d/mirrorlist

echo "pacstrap"
pacstrap -i /mnt base base-devel refind-efi efibootmgr dosfstools gptfdisk

#
# copy scripts and files from /root to /mnt/root
#

read -p "Press Enter to copy scripts to /mnt/root..."

echo "copying scripts"
cp /root/* /mnt/root

#
# fix mkinitcpio.conf
#

read -p "Press Enter to modify mkinitcpio.conf..."

echo "changing HOOKS line in mkinitcpio.conf"
sed -i -e 's/filesystems keyboard/keyboard zfs filesystems shutdown/' /mnt/etc/mkinitcpio.conf

#
# fix swappiness, journal size
#

read -p "Press Enter to fix swappiness and journal size..."

echo "creating journald.conf.d directory"
mkdir /mnt/etc/systemd/journald.conf.d

echo "copying swappinness.conf"
cp /root/99-swappinness.conf /mnt/etc/sysctl.d/99-swappinness.conf

echo "copying maxsize.conf"
cp /root/99-maxsize.conf /mnt/etc/systemd/journald.conf.d/99-maxsize.conf



