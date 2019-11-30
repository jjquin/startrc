#!/bin/sh


function create_dss {
    local DS_LIST="${1}"
    local DS_PAR="${2}"
        zfs create ${DS_PAR}/${DS}
    done
}

#
# Import configuration file
# 
source ./arch.conf

#
# Check ZFS kernel module
#

printf "\nchecking for ZFS module"

modprobe zfs && printf "\nZFS module loaded" || eof "Unable to load ZFS kernel module"

#
# create ROOT pool
#

if [[ ${1} == "destroy" ]]; then
    read -p "Warning: about to wipe out internal hard drive! Press Ctrl-C to cancel"
    printf "\nDestroying partitions on ${ZFS_DRIVE}"

    sgdisk --zap-all /dev/disk/by-id/${ZFS_DRIVE}

    printf "\nDestrying partitions on USB Drive: ${USB_DRIVE}"

    sgdisk --zap-all /dev/dis/by-id/${USB_DRIVE}

    sgdisk -n1:1M:+1G -t1:EF00 /dev/disk/by-id/${USB_DRIVE}

    mkfs.vfat -F32 -n BOOT_EFI /dev/disk/by-id/${USB_DRIVE}

fi

read -p "Press Enter to create ${ROOT_POOL} pool..."

printf "\ncreating ${ROOT_POOL}"
zpool create -o cachefile=  \
   -O compression=lz4 \
   -O normalization=formD \
   -O atime=off \
   -O canmount=off \
   -O exec=off \
   -O devices=off \
   -O setuid=off \
   -m none \
   -R /mnt \
   ${ROOT_POOL} \
   ${ZFS_DRIVE} || eof "Unable to create ZFS pool" 

if [ $? -ne 0 ]; then
   printf "\nUnable to create ${ROOT_POOL} pool" >&2
   exit 1
fi

zpool status ${ROOT_POOL}

#
# create ROOT pool datasets
#

read -p "Press Enter to create ${ROOT_POOL} datasets..."

printf "\ncreate ${ROOT_POOL} parent datasets"
zfs create -o mountpoint=none -o canmount=off -o reservation=84G ${ROOT_POOL}/reserve

#printf "\ncreate swap zvol"
#zfs create -V 8G -b $(getconf PAGESIZE) \
#           -o compression=zle \
#           -o logbias=throughput \
#           -o sync=always \
#           -o primarycache=metadata \
#           -o secondarycache=none \
#            ${ROOT_POOL}/swap


printf "\ncreate ${ROOT_POOL} system datasets"

zfs create -o mountpoint=none -o canmount=off ${SYS_PAR}
zfs create -o mountpoint=none -o canmount=off ${SYS_PAR}/ROOT
zfs create -o mountpoint=/ ${SYS_PAR}/ROOT/default
create_dss ${SYS_DSS} ${SYS_PAR}
create_dss ${VARLIB_DSS} "${SYS_PAR}/var/lib"
create_dss ${HOME_DSS} "${SYS_PAR}/home/${USER}"
create_dss 'data data/${USER}' "${ROOT_POOL}/${ENCRYPT_PAR}"
create_dss ${DATA_DSS} "${SYS_PAR}/data/${USER}"
zfs set canmount=off ${SYS_PAR}/usr ${SYS_PAR}/var ${SYS_PAR}/var/lib ${SYS_PAR}/var/lib/systemd
zfs set exec=on devices=on setuid=on ${SYS_PAR}/ROOT/default ${SYS_PAR}/usr
zfs set xattr=sa ${SYS_PAR}/var
zfs set exec=on ${SYS_PAR}/var/tmp ${SYS_PAR}/home ${DATA_PAR}/data/${USER}/code
zfs set acltype=posixacl ${SYS_PAR}/var/log
zfs set mountpoint=/root ${SYS_PAR}/home/root

read -p "Press Enter to to see pools datasets..."
zfs list -r -o name,used,available,mountpoint,mounted,canmount,exec,devices,setuid,compression,xattr,atime,acltype ${ROOT_POOL}

read -p "Press Enter if all zfs datasets created successfully"

read -p "Press Enter to export ${ROOT_POOL}..."

zpool export ${ROOT_POOL} && printf "\n${ROOT_POOL} exported." || eof "Failed to export pool ${ROOT_POOL}"

read -p "Press Enter to remove anything left in /mnt"

printf "\nCleaning /mnt"
rm -rf /mnt/* && printf "\n/mnt is now empty" || eof "Failed to remove leftover files and directories in /mnt"

read -p "Press Enter to reimport pool ${ROOT_POOL}"

printf "\nReimporting pool ${ROOT_POOL}"

zpool import -lR /mnt -d /dev/disk/by-id ${ROOT_POOL} && printf "\n${ROOT_POOL} imported to /mnt" || eof "Failed to import pool"

zpool status

read -p "Press Enter to check ${ROOT_POOL}'s mounts"

printf "\nChecking mounts:"

mount | grep zfs || eof "No zfs datasets mounted"

read -p "Continue if pool ${ROOT_POOL} mounted successfully"

read -p "Press Enter to mount USB Drive to /mnt/efi/"

printf "\nCreating /mnt/mnt/efi directory"

mkdir -p /mnt/mnt/efi || eof "Failed to create /mnt/mnt/efi"

printf "\nMounting USB Drive to /mnt/mnt/efi"

mount -L BOOT_EFI /mnt/mnt/efi && printf "\nSuccessfully mounted USB Drive to /mnt/mnt/efi" || eof "Failed to mount USB Drive to /mnt/mnt/efi






