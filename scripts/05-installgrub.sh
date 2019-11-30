#!/bin/sh

#
# create efi partion on usb drive
#
USBFLASHNAME=Samsung
USBFLASHID='usb-Samsung_Flash_Drive_0374917090029038-0:0'


read -p "Insert ${USBFLASHNAME} USB and Press Enter to wipe USB drive and create efi partition..."

echo "wipe ${USBFLASHNAME} USB Flash Drive"
sgdisk -z /dev/disk/by-id/${USBFLASHID}

echo "create efi partition on ${USBFLASHNAME} USB Flash Drive"
sgdisk -n3:1M:+512M -t3:EF)) /dev/disk/by-id/${USBFLASHID}

echo "new partion info:"
fdisk -l /dev/disk/by-id/${USBFLASHID}


#
# format efi partion
#

read -p "Press Enter to format efi partition (if it was created successfully)..."

echo formatting efi partition on ${USBFLASHNAME} USB Flash Drive"
mkfs.vfat -n EFIZFS -F 32 /dev/disk/by-id/${USBFLASHID}-part1

#
# create and mount efi directory
#

read -p "Press enter to create and mount efi directory (if efi partition formatted successfully)..."

echo "creating efi directory"
mkdir /boot/efi

echo "mounting efi parition"
mount /dev/disk/by-id/${USBFLASHID}-part1 /boot/efi

#
# install grub
#

echo "if grub recognizes zfs then next line is zfs"
grub-probe

read -p "Press Enter to install grub (if efi partition mounted successfully)..."

echo "adding iommu=soft to /etc/default/grub"

sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="iommu=soft"/' /etc/default/grub

echo "creating grub config"

ZPOOL_VDEV_NAME_PATH=1 grub-mkconfig -o /boot/grub/grub.cfg

echo "installing grub to efi partition"

ZPOOL_VDEV_NAME_PATH=1 grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux_on_${USBFLASHNAME} --recheck --no-floppy

echo "verify zfs module installed"
ls /boot/grub/*/zfs.mod


#
# unmount efi partition
#

read -p "Press Enter if grub installed successfully to unmount efi partition..."

umount /dev/disk/by-id/${USBFLASHID}-part1

