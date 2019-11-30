#!/bin/sh

#
# Variables
#

DISTROS='arch debu manj'
VIRT_DATASETS='docker libvirt lxc lxd machines'
SYS_DATASETS='var var/cache var/log var/tmp home home/jj home/leah home/root'
BOOTPOOL=zboot
ROOTPOOL=zroot
DRIVE1=ata-CT500MX500SSD1_1822E1414B85
DRIVE2=ata-CT500MX500SSD1_1825E14530EF

#
# Check ZFS kernel module
#

echo "checking for ZFS module"

modprobe zfs
if [ $? -ne 0 ]; then
   echo "Unable to load ZFS kernel module" >&2
   exit 1
fi

#
# create BOOT pool
#

read -p "Press Enter to create ${BOOTPOOL} pool..."

echo "create ${BOOTPOOL}"
zpool create -d -o cachefile= \
   -O atime=off \
   -O canmount=off \
   -m none \
   -R /mnt \
   ${BOOTPOOL} mirror \
   ${DRIVE1}-part2 \
   ${DRIVE2}-part2

echo "enable grub supported features"
for ZFS_FEAT in async_destroy empty_bpobj lz4_compress spacemap_histogram enabled_txg extensible_dataset bookmarks filesystem_limits large_blocks; do
    zpool set feature@${ZFS_FEAT}=enabled ${BOOTPOOL}
done

echo "turn on compression and xattr"
zfs set compression=lz4 xattr=sa ${BOOTPOOL}

read -p "Press Enter to see pool features..."
zpool get all ${BOOTPOOL}

read -p "Press Enter to see pool status..."
zpool status ${BOOTPOOL}

#
# create BOOT pool datasets
#

read -p "Press Enter to create ${BOOTPOOL} datasets..."

echo "create ${BOOTPOOL} parent datasets"
zfs create -o mountpoint=none -o canmount=off -o reservation=1G ${BOOTPOOL}/reserve
zfs create -o mountpoint=none -o canmount=off ${BOOTPOOL}/BOOT

echo "create boot environment datasets"
for dist in ${DISTROS}; do
    zfs create -o mountpoint=/boot -o canmount=noauto ${BOOTPOOL}/BOOT/${dist}-ins
done

read -p "Press Enter to see pool datasets..."
zfs list -r -o name,used,available,mountpoint,mounted,canmount

read -p "Press Enter to export ${BOOTPOOL}..."

zpool export ${BOOTPOOL}

#
# create ROOT pool
#

read -p "Press Enter to create ${ROOTPOOL} pool..."

echo "creating ${ROOTPOOL}"
zpool create -o cachefile=  \
   -O compression=lz4 \
   -O xattr=sa \
   -O acltype=posixacl \
   -O normalization=formD \
   -O atime=off \
   -O canmount=off \
   -m none \
   -R /mnt \
   ${ROOTPOOL} \
   ${DRIVE1}-part3 \
   ${DRIVE2}-part3

zpool status ${ROOTPOOL}

#
# create ROOT pool datasets
#

read -p "Press Enter to create ${ROOTPOOL} datasets..."

echo "create ${ROOTPOOL} parent datasets"
zfs create -o mountpoint=none -o canmount=off -o reservation=172G ${ROOTPOOL}/reserve
zfs create -o mountpoint=none -o canmount=off ${ROOTPOOL}/ROOT
zfs create -o mountpoint=/var/lib -o canmount=off \
           -o devices=off -o setuid=off ${ROOTPOOL}/virt

#echo "create swap zvol"
#zfs create -V 8G -b $(getconf PAGESIZE) \
#           -o compression=zle \
#           -o logbias=throughput \
#           -o sync=always \
#           -o primarycache=metadata \
#           -o secondarycache=none \
#            ${ROOTPOOL}/swap


echo "create ${ROOTPOOL} system datasets"
for dist in ${DISTROS}; do
    zfs create -o mountpoint=/ -o canmount=noauto ${ROOTPOOL}/ROOT/${dist}-ins
    zfs create -o mountpoint=none -o canmount=off \
               -o devices=off -o exec=off -o setuid=off ${ROOTPOOL}/${dist}
    for ds in ${SYS_DATASETS}; do
        zfs create -o mountpoint=legacy -o canmount=off ${ROOTPOOL}/${dist}/${ds}
    done
    zfs set exec=on ${ROOTPOOL}/${dist}/var/tmp ${ROOTPOOL}/${dist}/home
done

echo "set ${ROOTPOOL} bootfs dataset"
zpool set bootfs=${ROOTPOOL}/ROOT/arch-ins ${ROOTPOOL}


echo "create ${ROOTPOOL} shared distro virtual datasets"
for ds in ${VIRT_DATASETS}; do
    zfs create -o canmount=noauto ${ROOTPOOL}/virt/${ds}
done

read -p "Press Enter to to see pools datasets..."
zfs list -r -o name,used,available,mountpoint,mounted,canmount,exec,devices,setuid,compression,xattr,atime,acltype ${ROOTPOOL}


read -p "Press Enter to export ${ROOTPOOL}..."

zpool export ${ROOTPOOL}
