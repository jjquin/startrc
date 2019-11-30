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
sgdisk -n3:1M:+2G -t3:EF)) /dev/disk/by-id/${USBFLASHID}

echo "new partion info:"
fdisk -l /dev/disk/by-id/${USBFLASHID}


#
# format efi partion
#

read -p "Press Enter to format efi partition (if it was created successfully)..."

echo formatting efi partition on ${USBFLASHNAME} USB Flash Drive"
mkfs.vfat -n GUMMI_EFI -F 32 /dev/disk/by-id/${USBFLASHID}-part1

#
# create and mount efi directory
#

read -p "Press enter to create and mount efi directory (if efi partition formatted successfully)..."

echo "creating efi directory"
mkdir /boot/efi

echo "mounting efi parition"
mount /dev/disk/by-id/${USBFLASHID}-part1 /boot/efi
mount | grep boot

#
# install systemd-boot to /boot/efi
#

read -p "Press Enter to install systemd-boot to efi (if it was mounted successfully)..."

echo "installing systemd.boot"
bootctl --path=/boot/efi install
bootctl status

read -p "Press Enter to copy kernel to efi partition..."

echo "create kernel directories"
mkdir -p /boot/efi/kernels/arch/current
ls -lRh /boot/efi/kernels

echo "copy current arch kernel to efi partition"
cp /boot/vmlinuz-linux /boot/intramfs-linux.img /boot/efi/kernels/arch/current
ls -lh /boot/efi/kernels/arch/current


#
# create systemd-boot configuration
#

read -p "Press Enter to create systemd.boot loader.conf and arch-current.conf..."

echo "configure systemd.boot loader.conf"

mv /boot/efi/loader/loader.conf /boot/efi/loader/loader.conf-orig

echo "default   arch-current" > /boot/efi/loader/loader.conf
echo "timeout   5"           >> /boot/efi/loader/loader.conf
echo "editor    no           >> /boot/efi/loader/loader.conf

echo "configure systemd-boot arch-current.conf"

echo "title    Arch Linux - Current"                             > /boot/efi/loader/entries/arch-current.conf
echo "linux    /kernels/arch/current/vmlinux-linux"             >> /boot/efi/loader/entries/arch-current.conf
echo "initrd   /kernels/arch/current/initramfs-linux.img"       >> /boot/efi/loader/entries/arch-current.conf
echo "options  iommu=soft rw quiet zfs=zroot/arch/ROOT/install" >> /boot/efi/loader/entries/arch-current.conf

bootctl list

#
# unmount efi partition
#

read -p "Press Enter if grub installed successfully to unmount efi partition..."

echo "unmounting efi partition"
umount /dev/disk/by-id/${USBFLASHID}-part1

