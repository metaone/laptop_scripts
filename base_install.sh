#!/bin/bash

DISK="/dev/sda"
SWAP="16GiB"

echo "Step 1: Prepare the hard drive"

dd if=/dev/zero of=/dev/sda bs=512 count=1

parted ${DISK} mklabel msdos --script
parted ${DISK} mkpart primary linux-swap 1MiB ${SWAP} --script
parted ${DISK} mkpart primary ext4 ${SWAP} 100% --script
parted ${DISK} set 2 boot on --script

mkswap ${DISK}1
swapon ${DISK}1
mkfs.ext4 ${DISK}2 -F

echo "Step 2: Install system"

mount ${DISK}2 /mnt
pacstrap -i /mnt base base-devel --noconfirm
genfstab -U /mnt /mnt/etc/fstab

echo "Step 3: Configure system"
sed -i "/#en_US.UTF-8/ s/# *//" /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

arch-chroot /mnt /bin/bash -c '
locale-gen
' # END OF CHROOT

