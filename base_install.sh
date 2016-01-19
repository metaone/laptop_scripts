#!/bin/bash

echo "Step 1: Prepare the hard drive"

dd if=/dev/zero of=/dev/sda bs=512 count=1

parted /dev/sda mklabel msdos --script
parted /dev/sda mkpart primary linux-swap 1MiB 16GiB --script
parted /dev/sda mkpart primary ext4 16GiB 100% --script
parted /dev/sda set 2 boot on --script

mkswap /dev/sda1
swapon /dev/sda1
mkfs.ext4 /dev/sda2 -F

echo "Step 2: Install system"

mount /dev/sda2 /mnt
pacstrap -i /mnt base base-devel --noconfirm
genfstab -U /mnt /mnt/etc/fstab

echo "Step 3: Configure system"

arch-chroot /mnt /bin/bash -c '
sed -i "/#en_US.UTF-8/ s/# *//" /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8
locale-gen

ln -s /usr/share/zoneinfo/Europe/Kiev > /etc/localtime
hwclock --systohc --utc

pacman -S grub os-prober --noconfirm
grub-install --recheck --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo cyberpunk > /etc/hostname
echo "root:password" | chpasswd
' # END OF CHROOT

umount -R /mnt
reboot

