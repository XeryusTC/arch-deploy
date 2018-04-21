#!/bin/sh

echoerr() { echo "$@" 1>&2; }

VOLUME_NAME=ssd-vg

# This is suppose to be run from the Arch Linux Live CD

echo "Validating environment"
if [ ! -d "/sys/firmware/efi/efivars/" ]; then
	echoerr "You are not running in UEFI mode"
	exit 1
fi

if ! ping -q -c 1 -W 1 archlinux.org > /dev/null; then
	echoerr "No internet connection"
	exit 1
fi

timedatectl set-ntp true

echo "Currently known block devices"
lsblk
echo -n "Block device to install to? "
read INSTALL_DEV

echo -n "Hostname? "
read HOSTNAME

echo "Partitioning disk"
parted $INSTALL_DEV mklabel gpt \
	mkpart primary fat32 1MiB 550MiB \
	set 1 boot on \
	mkpart primary ext4 550MiB 100%

echo "Creating entropy (this may take a while)..."
for i in {1..6}
do
	ls -Ra > /dev/null
done

echo "Creating logical encrypted volumes"
pvcreate ${INSTALL_DEV}2
vgcreate $VOLUME_NAME ${INSTALL_DEV}2
lvcreate -L 40G -n root $VOLUME_NAME
lvcreate -L 8G -n swap $VOLUME_NAME
lvcreate -l 100%FREE -n home $VOLUME_NAME

cryptsetup luksFormat --type luks2 /dev/mapper/${VOLUME_NAME}-root
cryptsetup open /dev/mapper/${VOLUME_NAME}-root root

echo "Formatting partitions"
mkfs.ext4 /dev/mapper/root
dd if=/dev/zero of=${INSTALL_DEV}1 bs=1M status=progress
mkfs.fat ${INSTALL_DEV}1
mount /dev/mapper/root /mnt
mkdir /mnt/boot
mount ${INSTALL_DEV}1 /mnt/boot

# The next step is pretty ghetto
echo "Setting up mkinitcpio"
sed -i 's/keyboard/keyboard/; t; /HOOKS/s/autodetect/autodetect keyboard keymap/' \
	/etc/mkinitcpio.conf
sed -i 's/lvm2/lvm2/; t; /HOOKS/s/filesystems/lvm2 encrypt filesystems/' \
	/etc/mkinitcpio.conf

echo "Creating fstab and crypttab"
echo "swap /dev/mapper/${VOLUME_NAME}-swap /dev/urandom swap,cipher=aes-xts-plain64,size=256" > /mnt/etc/crypttab
echo "tmp  /dev/mapper/${VOLUME_NAME}-tmp  /dev/urandom tmp,cipher=aes-xts-plain64,size=256" >> /mnt/etc/crypttab

echo "/dev/mapper/root / ext4  defaults 0 1" > /mnt/etc/fstab
echo "${INSTALL_DEV}1 /boot vfat  defaults 0 2" >> /mnt/etc/fstab
echo "/dev/mapper/swap none swap sw 0 0" >> /mnt/etc/fstab


echo "Installing Arch to file system"
pacstrap /mnt base base-devel

echo "Moving into chroot"
arch-chroot /mnt

echo "Setting timezone"
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

echo "Setting locale"
sed -i '/en_US.UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo "Setting hostname"
echo $HOSTNAME > /etc/hostname
echo '127.0.0.1 localhost' > /etc/hosts
echo '::1       localhost' >> /etc/hosts
echo '127.0.1.1 $HOSTNAME' >> /etc/hosts

echo "Configuring network"
sed 's/eth0/enp5s0/' /etc/netctl/examples/ethernet-dhcp > /etc/netctl/ethernet
netctl enable ethernet

echo "Creating initramfs"
mkinitcpio -p linux

echo "Please set a root password"
passwd

echo "Configuring GRUB"
sed -i -e '/GRUB_CMDLINE_LINUX_DEFAULT/s/crypt/crypt/' -t \
	-e '/GRUB_CMDLINE_LINUX_DEFAULT/s/"$/cryptdevice=/dev/mapper/${VOLUME_NAME}-root:root root=/dev/mapper/root"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --efi-directory /boot --bootloader-id arch_grub

exit
echo "Done, you should be able to reboot now"
