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

### Install new machine

helper_netsetup() {
  echo "Use the following to test network (with and without dns lookup):"
  echo "     ping -c 3 google.com"
  echo "     ping -c 3 8.8.8.8"
  echo "Does it work? If not do:"
  echo "     ifconfig"
  echo "     net-setup <device-name>"
  echo "where <device-name> is, for example, \"enp6s4f0\"."
  echo "Test with ping. DNS problems can be sometimes worked around by"
  echo "using the public DNS server from google. To do that, just"
  echo "    echo "nameserver 8.8.8.8" >> /etc/resolv.conf" 
  echo "If still no joy, refer to the Gentoo Handbook." 
}

As long as netsetup is a piece of crap, lets just use

config_enp6s4f0="x.x.x.124 broadcast x.x.x.255 netmask 255.255.255.0"
routes_enp6s4f0="default via x.x.x.254"
metric_enp6s4f0="1"
dns_servers_enp6s4f0="x.x.x.124 y.y.y.y z.z.z.z 8.8.8.8"
dns_domain="ravu.maj.domain"



local_install_hello() {
  helper_netsetup;
}

remote_install_hello() {
  helper_netsetup;
  echo "Once network is up,"
  echo "* start sshd:"
  echo "    /etc/init.d/sshd start"
  echo "* set a temporary (install-time) root password"
  echo "    passwd"
  echo "* create a temporary (install-time) user"
  echo "    useradd -m -G users,wheel <username>"
  echo "    passwd <username>"
  echo "You're now ready to connect to the installation environment"
  echo "over ssh by issuing `ssh <username>@<ipaddress>`"
}

#######################################################################

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
  sgdisk -p ${1}
}

mk_btrfs_raid1_root {
dev1=${1};
dev2=${2};
dev1=/dev/sda4
dev2=/dev/sdb4
# TODO: warn that this is a desctructive process due to -f in mkfs.btrfs
mkfs.btrfs -f -L "root" -d raid1 -m raid1 ${dev1} ${dev2}
mkdir /mnt/btrfs
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag ${dev1} /mnt/btrfs
btrfs subvolume create /mnt/btrfs/root
umount /mnt/btrfs
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag,subvol=root ${dev1} /mnt/gentoo
btrfs subvol create /mnt/gentoo/home
mount -t btrfs -o defaults,noatime,compress=lzo,autodefrag,subvol=home /dev/sda4 /mnt/gentoo/home
}

mk_ext4_mdraid1_boot {
mdadm --create /dev/md0 --name boot --level 1 --metadata 0.9 --raid-devices=2 /dev/sda2 /dev/sdb2
mkfs.ext4 -L boot /dev/md0
mkdir /mnt/gentoo/boot
mount /dev/md0 /mnt/gentoo/boot
}

md_swap_mdraid1 {
# Swapping on a mirrored RAID can help you survive a failing disk. If a disk fails, 
# then data for swapped processes would be inaccessable in a non-mirrored environment.
mdadm --create /dev/md1 --name boot --level 1 --metadata 0.9 --raid-devices=2 /dev/sda3 /dev/sdb3
mkswap /dev/md1
swapon /dev/md1
}

#######################################################################

check_date() {
  echo "Is this the correct date?"
  date
  echo "If not, set propper date with `date` command to avoid an insane install."
}

fetch_stage3() {
  cd /mnt/gentoo
  echo "Fetch stage3"
  echo "links http://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64"
  echo "wget http://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20150730.tar.bz2"
  tar xvjpf stage3-*.tar.bz2 --xattrs
  #TODO wget lepší make conf.
  # nastav makeopts jako pocet jader+1
  echo "MAKEOPTS=\"-j"$((`nproc` + 1))\" >> /mnt/gentoo/etc/portage/make.conf

  cp -L /etc/resolv.conf /mnt/gentoo/etc/
  mount -t proc proc /mnt/gentoo/proc
  mount --rbind /sys /mnt/gentoo/sys
  mount --make-rslave /mnt/gentoo/sys
  mount --rbind /dev /mnt/gentoo/dev
  mount --make-rslave /mnt/gentoo/dev
  #entering chroot
  chroot /mnt/gentoo /bin/bash
  source /etc/profile
  export PS1="(chroot) $PS1"
  emerge-webrsync
  eselect profile list # select hardened/linux/amd64
  ls /usr/share/zoneinfo
  echo "Europe/Prague" > /etc/timezone
  emerge --config sys-libs/timezone-data
  echo "en_US ISO-8859-1
en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  eselect locale list # select en_US.utf8
  mkdir -p /etc/portage/{package.mask,package.unmask,sets,repos.conf,package.accept_keywords,package.use,env,package}
  # download sets
  emerge @portage
  flaggie dracut +amd64 
  cpuinfo2cpuflags-x86 >> /etc/portage/make.conf # test if admin stage got it
  eix-update
  eix-sync
  emerge -uDN @kernel @boot @core @tools
  cd /usr/src/linux
  make nconfig
  make && make modules_install
  make install # copy stuff to /boot
  
  mkdir -p /var/mage/repos
  ln -s /usr/portage /var/mage/repos/gentoo
  ln -s /usr/local/portage /var/mage/repos/local
  ln -s /var/lib/layman /var/mage/repos/layman
  ln -s /usr/lib/portage /var/mage/repos/layman
  {gentoo,distfiles,local,layman}
  mkdir -p /tmp/portage
  mv /usr/portage/* /var/portage/gentoo/
  mkdir -p /boot/efi/boot
  cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi
  dracut --hostonly 
  emerge sys-boot/grub
  grub2-install /dev/sda
  grub2-mkconfig -o /boot/grub/grub.cfg
  
}

systemd_shit() {
  ln -sf /proc/self/mounts /etc/mtab
  emerge --unmerge virtual/libudev sysfs/udev
  emerge sys-apps/systemd
}
#######################################################################
#######################################################################
#######################################################################
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
  
  

 * Messages for package mail-mta/nullmailer-1.13-r5:

 * To create an initial setup, please do:
 * emerge --config =mail-mta/nullmailer-1.13-r5
