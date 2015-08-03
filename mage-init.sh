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

bootstrap_user() {
  echo "Set your root password by calling:"
  echo "     passwd"
  echo "Create a user for yourself:"
  echo "     useradd -m -G users <username>"
}

bootstrap_net() {
  echo "Use the following commands to configure / test the network:"
  echo "     ping -c 3 google.com"
  echo "Does it work? If not do:"
  echo "     ifconfig"
  echo "     net-setup <device-name>"
  echo "where <device-name> is, for example, \"enp6s4f0\"."
  echo "Test with ping. If still no joy, refer to the Gentoo Handbook." 
  echo ""
  echo "If you're bootstrapping a server over a physical remote"
  echo "console (kvm/lom), fire up sshd now with"
  echo "     /etc/init.d/sshd start"
  echo "and finish the install over ssh from your laptop. Its"
  echo "way more convenient. To connect to the server from your laptop,"
  echo "just `ssh <username>@<ipaddress>`"
  }
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
  FS=`sgdisk -F ${1}` ; sgdisk -n 1:${FS}:8M -c 1:"biosboot" -t 1:ef02 ${1}	 # GRUB partition (4MB)
  FS=`sgdisk -F ${1}` ; sgdisk -n 2:${FS}:500M -c 2:"boot" -t 2:8300 ${1}    # /boot partition (400M)
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



mkdir /mnt/gentoo/boot
mount /dev/sda2 /mnt/gentoo/boot
#Note
#If /tmp/ needs to reside on a separate partition, be sure to change its permissions after mounting:
root #chmod 1777 /mnt/gentoo/tmp
btrfs subvol create /mnt/btrfs/home
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag,subvol=home /dev/sda4 /mnt/gentoo/home
btrfs subvol create /mnt/btrfs/distfiles
btrfs subvol create /mnt/btrfs/vm
btrfs subvol create /mnt/btrfs/vmcrypt
btrfs subvol create /mnt/btrfs/tmp

btrfs subvol create /mnt/btrfs/mysql

PORTAGE_TMPDIR=/var/tmp # memory mapped
PORTDIR=/usr/portage -> PORTDIR=/var/gentoo/portage
DISTDIR=/usr/portage/distfiles -> /var/gentoo/distfiles
PKGDIR=/usr/portage/packages -> /var/gentoo/packages
PORTDIR_OVERLAY=/usr/local/portage -> PORTDIR_OVERLAY=/var/gentoo/local
PORTDIR_OVERLAY=/usr/local/portage -> PORTDIR_OVERLAY=/var/gentoo/local
/var/lib/layman -> /var/gentoo/layman

root #btrfs subvol create /mnt/newmirror/distfiles
root #mount -t btrfs -o defaults,noatime,autodefrag,subvol=distfiles /dev/sdc3 /mnt/newroot/distfiles
root #btrfs subvol create /mnt/newmirror/vm
root #mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag,subvol=vm /dev/sdc3 /mnt/newroot/vm
root #btrfs subvol create /mnt/newmirror/vmcrypt
root #mount -t btrfs -o defaults,noatime,autodefrag,subvol=vmcrypt /dev/sdc3 /mnt/newroot/vmcrypt

}
  
  
