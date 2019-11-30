#!/bin/sh

#
# set timezone
#

read -p "Press Enter to set timezone and correct date and time..."

echo "setting New York timezone"
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

#
# Fix time
#

echo "setting clock to hardware clock"
hwclock --systohc

echo "installing network time protocol"
pacman -S ntp

echo "starting network time protocol daemon"
ntpd -q

echo "updating hardware clock"
hwclock -w

#
# set locale and language
#

read -p "Press Enter to set locale and language..."

echo "uncommenting US english locale"
sed -i -e 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

grep en_US /etc/locale.gen
read -p "Press Enter if /etc/local.get changed correctly..."

echo "generating locale"
locale-gen

echo "setting english language"
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#
# set hostname and hosts file
#

read -p "Press Enter to set hostname and hosts file..."

echo "setting hostname to parents-pc"
echo "parents-pc" > /etc/hostname

echo "setting /etc/hosts file"
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.0.1		parents-pc.quinlivan.org parents-pc" >> /etc/hosts

#
# set password
#

read -p "Press Enter to set root password..."

echo "set root password"
passwd

#
# setup swap
#

#read -p "Press Enter to setup swap zvol..."

#echo "making swap"
#mkswap -f /dev/zvol/zroot/swap

#echo "need to run swapon -av after reboot"
