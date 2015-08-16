#!/usr/bin/env bash

# installing according to handbook up until "Installing stage3"
# Starts to differ at "Installing base system" at eselect profile


fetch_stage3() {
  cd /mnt/gentoo
  echo "Fetch stage3"
  echo "links http://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64"
  echo "wget http://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20150730.tar.bz2"
  tar xvjpf stage3-*.tar.bz2 --xattrs
  #TODO wget lepší make conf.
  # nastav makeopts jako pocet jader+1
  
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
  echo "MAKEOPTS=\"-j"$((`nproc` + 1))\" >> /etc/portage/make.conf # PRESUNUTO DO CHROOTU
  emerge-webrsync
  eselect profile list # default/linux/amd64/13.0/desktop/gnome/systemd
  mkdir -p /etc/portage/{package.mask,package.unmask,sets,repos.conf,package.accept_keywords,package.use,env,package}
  emerge app-portage/cpuinfo2cpuflags
  cpuinfo2cpuflags-x86 >> /etc/portage/make.conf # test if admin stage got it
  cd /etc/portage/sets/
  wget https://raw.githubusercontent.com/killua-eu/Mage/master/sets/{portage,boot,kernel,tools} #core nedavam


echo 'INPUT_DEVICES="evdev libinput synaptics tslib wacom"' >> /etc/portage/make.conf
echo 'VIDEO_CARDS="intel modsetting v4l vesa"' >> /etc/portage/make.conf
flaggie systemd
flaggie openssl -bindist
flaggie openssh -bindist
https://raw.githubusercontent.com/killua-eu/Mage/master/sets/{unarchivers,czech,gnome-desktop}
emerge -uDNa @boot @czech @gnome-desktop @kernel @portage @tools
systemctl enable gdm.service
systemctl enable NetworkManager 
echo 'VIDEO_CARDS="intel"' >> /etc/portage/make.conf
ln -sf /proc/self/mounts /etc/mtab
cd /usr/src/linux
make nconfig
make && make modules_install
make install
mkdir -p /boot/efi/boot
cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi
nano /etc/fstab
passwd
echo 'GRUB_CMDLINE_LINUX="rootfstype=ext4 real_init=/usr/lib/systemd/systemd"' >> /etc/default/grub
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
useradd -m -G users,wheel,audio,video,plugdev,portage,games,usb -s /bin/bash <user>
passwd <user>
echo "en_US ISO-8859-1
en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.utf8
timedatectl set-timezone Europe/Prague

# todo
* For passwordless login to unlock your keyring, you need to set an empty password on your keyring.
* eselect gnome-shell-extensions


 * be in the 'games' group.
 * Just run 'gpasswd -a <USER> games', then have <USER> re-login.
 
 * To get previous working directory inherited in new opened tab you
 * will need to add the following line to your ~/.bashrc:
 * . /etc/profile.d/vte.sh
 * . /usr/libexec/mc/mc.sh
 * 
  * Messages for package sys-boot/grub-2.02_beta2-r7:

 * The grub directory has changed from /boot/grub2 to /boot/grub.
 * Please run grub2-install and grub2-mkconfig -o /boot/grub/grub.cfg.
 * For information on how to configure GRUB2 please refer to the guide:
 *     http://wiki.gentoo.org/wiki/GRUB2_Quick_Start
 * 
 * You may consider installing the following optional packages:
 *   dev-libs/libisoburn for Create rescue media (grub-mkrescue)
 *   sys-fs/mdadm for Enable RAID device detection
 
 
 
  **add yourself to plugdev







#


  ls /usr/share/zoneinfo
  echo "Europe/Prague" > /etc/timezone
  emerge --config sys-libs/timezone-data
  echo "en_US ISO-8859-1
en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  eselect locale list # select en_US.utf8
  
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
  grub2-install /dev/sda
  grub2-install /dev/sdb
  grub2-mkconfig -o /boot/grub/grub.cfg
  # errors
  #  /run/lvm/lvmetad.socket: connect failed: No such file or directory
  # WARNING: Failed to connect to lvmetad. Falling back to internal scanning.
  # No volume groups found
  # can be ignored
  echo "
# <fs>              <mountpoint>    <type>      <opts>                                              <dump/pass>
LABEL="boot"        /boot           ext2        noauto,noatime                                          1 2
LABEL="root"        /               brtfs       defaults,noatime,compress=lzo,autodefrag,subvol=root    0 0
LABEL="root"        /home           brtfs       defaults,noatime,compress=lzo,autodefrag,subvol=home    0 0
LABEL="swap"        none            swap        sw                                                      0 0
" >> /etc/fstab
}
# todo: fstab ma nejaka preddefinovana cosi, co se musi zakomentovat
 mdadm --detail --scan >> /etc/mdadm.conf
 ####
 nano -w /etc/conf.d/hostname  # nejede augtool  ls /etc/conf.d/hostname
 nano -w /etc/conf.d/net
 useradd -m -G users,wheel,portage -s /bin/bash pavel
 passwd
 passwd pavel

systemd_shit() {
  ln -sf /proc/self/mounts /etc/mtab
  emerge --unmerge virtual/libudev sysfs/udev
  emerge sys-apps/systemd
  echo "GRUB_CMDLINE_LINUX=\"init=/usr/lib/systemd/systemd\"" >> /etc/default/grub
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



