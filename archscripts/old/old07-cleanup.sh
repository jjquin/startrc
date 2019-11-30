#!/bin/sh

#
# cleanup start by umounting everything under /mnt
#

echo "Make sure you exit chroot before running this!"

read -p "Press Enter to unmount everything under /mnt..."

echo "unmounting udev"
umount -fl /mnt/udev

UMOUNT_DATASETS='home/jj home/leah /root /home /boot/efi /boot /var/tmp /var/log /var/cache /var'

echo "unmounting legacy mounts"
for ds in ${UMOUNT_DATASETS}; do
   umount -f /mnt/${ds}
done

zfs umount -a

if [ $? -ne 0 ]; then
   echo 'mount | grep zfs'
   mount | grep -v zfs | tac | awk '/\/mnt/ {print $3}' | xargs -i{} umount -lf {}
   if [ $? -ne 0 ]; then
      echo "unable to automatically unmount all datasets"
      exit 1
   fi
fi

echo 'mount | grep zfs'

read -p "Press Enter to export pools IF all unmounts were successful..."

echo "exporting zarchive"
zpool export zarchive

echo "exporting zboot"
zpool export zboot

echo "exporting zroot"
zpool export zroot

zpool status

echo "if all pools were successfully exported it is safe to reboot"


