#!/bin/sh

#
# updating mirrorlist
#

read -p "Press Enter to update mirrorlist file..."

[ -x $(command -v "reflector" ] !! pacman -S reflector

printf "\nCreating updated mirrorlist"

reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || eof "Mirror list update failed"

printf "\nNew Mirror list created: \n"
grep "Server" /etc/pacman.d/mirrorlist

#
# pacstrap
#

read -p "Press Enter to install basic arch (pacstrap)..."

printf "\npacstrap"
pacstrap -i /mnt base base-devel efibootmgr dosfstools gptfdisk git || eof "pacstrap failed"

#
# copy scripts and files from /root to /mnt/root
#

read -p "Press Enter to copy archrc repository to /mnt/root..."

printf "\nCopying repository"

mkdir /root/archrc
cp -r /root/archrc /mnt/root/

#
# fix mkinitcpio.conf
#

read -p "Press Enter to modify mkinitcpio.conf..."

printf "\nchanging HOOKS line in mkinitcpio.conf"
sed -i -e 's/filesystems keyboard fsck/keyboard zfs filesystems shutdown/' /mnt/etc/mkinitcpio.conf

#
# fix swappiness, journal size
#

read -p "Press Enter to fix swappiness and journal size..."

printf "\ncreating journald.conf.d directory"
mkdir /mnt/etc/systemd/journald.conf.d

printf "\ncopying swappinness.conf"
cp /root/99-swappinness.conf /mnt/etc/sysctl.d/99-swappinness.conf

printf "\ncopying maxsize.conf"
cp /root/99-maxsize.conf /mnt/etc/systemd/journald.conf.d/99-maxsize.conf



