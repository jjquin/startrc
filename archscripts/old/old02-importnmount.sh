#!/bin/sh

#
# Variables
#
BOOTPOOL=zboot
ROOTPOOL=zroot
DRIVE1=ata-CT500MX500SSD1_1822E1414B85
DRIVE2=ata-CT500MX500SSD1_1825E14530EF

read -p "Press Enter to Import Pools..."

echo "import ${ROOTPOOL}"
zpool import -R /mnt ${ROOTPOOL}

echo "import ${BOOTPOOL}"
zpool import -R /mnt ${BOOTPOOL}

zpool status

read -p "Press Enter to list mounts (cancel script if zfs mounted)..."
mount | grep zfs

read -p "Press Enter to mount datasets..."

echo "mount boot environment datasets"
zfs mount ${ROOTPOOL}/ROOT/arch-ins
zfs mount ${BOOTPOOL}/BOOT/arch-ins

mount | grep zfs
read -p "Press Enter if / and /boot mounted successfully..."

echo "make parent directores"
mkdir /mnt/{etc,home,var,root}

ls -l /mnt
read -p "Press Enter if directories were created successfully..."

echo "mount parent directories"
mount -t zfs ${ROOTPOOL}/arch/var /mnt/var
mount -t zfs ${ROOTPOOL}/arch/home /mnt/home
mount -t zfs ${ROOTPOOL}/arch/home/root /mnt/root

mount | grep zfs
read -p "Press Enter if parent directories mounted successfully..."


echo "make var directories"
mkdir /mnt/var/{cache,lib,log,tmp}

ls -l /mnt/var
read -p "Press Enter if /var child directories were created successfully..."


echo "mount var directories"
for ds in cache log tmp; do
    mount -t zfs ${ROOTPOOL}/arch/var/${ds} /mnt/var/${ds}
done

mount | grep zfs
read -p "Press Enter if /var child directories mounted successfully..."

echo "make home directories"
mkdir /mnt/home/{jj,leah}

ls -l /mnt/home
read -p "Press Enter if /home child directories were created successfully..."

echo "mount home directories"
mount -t zfs ${ROOTPOOL}/arch/home/jj /mnt/home/jj
mount -t zfs ${ROOTPOOL}/arch/home/leah /mnt/home/leah

mount | grep zfs
read -p "Press Enter if /home child directories mounted successfully..."

echo "mount shared virtual directories"

zfs set canmount=on ${ROOTPOOL}/virt/docker ${ROOTPOOL}/virt/libvirt ${ROOTPOOL}/virt/lxc ${ROOTPOOL}/virt/lxd ${ROOTPOOL}/virt/machines
zfs mount -a

mount | grep zfs
read -p "Press Enter to confirm all mounted successfully..."


read -p "Press Enter to list zfs mounts..."
zfs list -o name,mountpoint,mounted,canmount


read -p "Press Enter to format efi partition..."

echo "format efi partitions"
mkfs.vfat /dev/disk/by-id/${DRIVE1}-part1
mkfs.vfat /dev/disk/by-id/${DRIVE2}-part1

read -p "Press Enter to create and mount efi partition..."

echo "make boot efi directory"
mkdir /mnt/boot/efi

echo "mount efi partition"
mount /dev/disk/by-id/${DRIVE1}-part1 /mnt/boot/efi

mount | grep efi
read -p "Press Enter if efi partition mounted sucessfully..."

# generate fstab

read -p "Press Enter to generate fstab..."

echo "generating fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab

#echo "adding swap line to fstab"
#echo "/dev/zvol/${ROOTPOOL}/swap	none	swap	discard 0 0" >> /mnt/etc/fstab

read -p "Press Enter to import zarchive and setup zpool.cache file..."

echo "import zarchive pool"
zpool import -R /mnt zarchive

echo "setting zpool.cache file for each pool"
zpool set cachefile=/etc/zfs/zpool.cache ${ROOTPOOL}
zpool set cachefile=/etc/zfs/zpool.cache ${BOOTPOOL}
zpool set cachefile=/etc/zfs/zpool.cache zarchive

echo "creating /etc/zfs directory"
mkdir /mnt/etc/zfs

echo "copying zpool.cache to chroot"
cp /etc/zfs/zpool.cache /mnt/etc/zpool.cache

read -p "Press Enter to edit fstab..."

nano /mnt/etc/fstab


