#!/usr/bin/env bash

debug_parms() {
  # Prints script parameters.
  # Call with `debug_parms $@`
  echo "Number of params: "$#
  echo "All params: "$@
  while [ "$#" != "0" ]; do
    shift
    echo "Param: "$@
  done
}

hw_hdd_sector_size() {
  # Prints HDD sector size
  # Call with a single string parameter (hdd device name), i.e. `hw_hdd_sector_size sda`
  echo "Physical block size of /dev/${1}: `cat /sys/class/block/${1}/queue/physical_block_size`"
  echo "Physical block size of /dev/${1}: `cat /sys/class/block/${1}/queue/logical_block_size`"
}

mk_partition() {
  # TODO: device ${1} exists check
  parted -a optimal ${1} mklabel gpt # convert mbr to gpt
  sgdisk -o ${1} # clear partition table
  FS=`sgdisk -F ${1}` ; sgdisk -n 1:${FS}:4M -c 1:"biosboot" -t 1:ef02 ${1}	 # GRUB partition (4MB)
  FS=`sgdisk -F ${1}` ; sgdisk -n 2:${FS}:400M -c 2:"boot" -t 2:8300 ${1}    # /boot partition (400M)
  FS=`sgdisk -F ${1}` ; sgdisk -n 3:${FS}:12GB -c 3:"swap" -t 3:8200 ${1}    # swap partition
  FS=`sgdisk -F ${1}` ; 
  ES=`sgdisk -E ${1}` ; sgdisk -n 4:${FS}:${ES} -c 4:"root" -t 4:8300 ${1}   # root partition
  sgdisk -p $1
}

mk_btrfs_single_perf {
# set some global to see that mk_partition was run?
# if mk_partition works on /dev/sda, then the parameter should be /dev/sda
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
mkfs -t btrfs -L "sysroot" -m single -d single /dev/sda4

# We mount the default volume for the root partition on /mnt/btrfs but will be putting
# the actual contents into subvolumes with different btrfs features enabled or disabled. 
mkdir /mnt/btrfs
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag /dev/sda4 /mnt/btrfs
# The new root filesystem will go onto a subvolume (activeroot) which is created on the 
# btrfs disk and then mounted to /mnt/gentoo
mkdir /mnt/gentoo
btrfs subvol create /mnt/btrfs/activeroot
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag,subvol=activeroot /dev/sda4 /mnt/gentoo
-o noatime,discard,ssd,autodefrag,compress=lzo,space_cache ${1}

}
  
  