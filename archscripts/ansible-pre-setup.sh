#!/bin/sh

#
# Configure ZFS Pool, datasets and install arch base
#


ansible-pull -U https://gitlab.com/jjquin/ansible-arch-bmetal.git pre_setup.yml

#
# Chroot to finish installation
#


if [ $? == 0 ]; then
   cp /root/ansible-post-setup.sh /mnt/root/ansible-post-setup.sh

   arch-chroot /mnt ansible-pull -U https://gitlab.com/jjquin/ansible-arch-bmetal.git setup.yml
   
   if [ $? == 0 ]; then
      zfs umount -a
      umount -lf --recursive /mnt
      mount | grep -v zfs | tac | awk '/\/mnt/ {print $3}' | xargs -i{} umount -lf {}
      zfs export -a
      if [ $? == 0 ]; then
         reboot now
      fi
   fi
fi

echo "installation failed"


