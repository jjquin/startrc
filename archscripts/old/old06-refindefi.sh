

#
# install rEFInd
#

read -p "Press Enter to install rEFInd..."

echo "install refind"
pacman -S refind-efi
cp /root/zfs_x64.efi /usr/share/refind/drivers_x64/

refind-install --usedefault /dev/sda1 --alldrivers

#echo "manually installing refind"

#echo "creating refind directories"
#mkdir -p /mnt/boot/efi/EFI/refind/{drivers_x64,icons,fonts}

#echo "copying default files"
#cp /usr/share/refind/refind_x64.efi /boot/efi/EFI/refind/
#cp /usr/share/refind/refind.conf-sample /boot/efi/EFI/refind/refind.conf
#cp /usr/share/refind/drivers_x64/* /boot/efi/EFI/refind/drivers_x64/
#cp -r /usr/share/refind/icons /boot/efi/EFI/refind/
#cp -r /usr/share/refind/fonts /boot/efi/EFI/refind/

#echo "setting up refind_linux.conf"
#echo '"Boot with defaults" "iommu=soft zfs=zroot/ROOT/arch-ins" > /boot/refind_linux.conf
#echo '"Boot to terminal" "iommu=soft zfs=zroot/ROOT/arch-ins" >> /boot/refind_linux.conf
#echo '"ZFS Boot Environments" "iommu=soft zfs=bootfs" >> /boot/refind_linxu.conf


#read -p "Press enter to add rEFInd to efi..."

#modprobe efivars
#efibootmgr -c -d /dev/disk/by-id/ata-CT500MX500SSD1_1822E1414B85-part1 \
#           -p 2 -loader /EFI/refind/refind_x64.efi --label "rEFInd ZFS" --verbose


   

