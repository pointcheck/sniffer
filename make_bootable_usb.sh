#!/bin/sh

DEV=/dev/da0
ROOTSIZE=5GB
CLEANUP=/home/sniffer/cleanup.sh

ID=`id -u`

if [ "$ID" != "0" ]; then
	echo "Should be run as root, use: sudo $0 $*"
	exit 1;
fi

if [ ! -e "$DEV" ]; then
	echo "Block device $DEV not found, make sure you inserted USB stick!"	
	exit 1;
fi

gpart show $DEV

echo -n "All data on $DEV will be lost, continute (y/N) ? "

read yesno

if [ "$yesno" != "y" ]; then
	echo "Abort!"
	exit 1
fi

df -m

echo

ROOTSIZE=`df -m | awk '/ada0p2/{print $3+1 "M"}'`

echo -n "You will need ${ROOTSIZE} on $DEV, continue (y/N) ? "

read yesno

if [ "$yesno" != "y" ]; then
	echo "Abort!"
	exit 1
fi

if [ ! -d "/mnt" ]; then
	mkdir /mnt
fi

echo "Forcibly unmounting all ${DEV}*"

umount -f ${DEV}* 2>/dev/null 

echo "Destroting partition table on $DEV"

if gpart destroy -F $DEV ; then
else
	echo "Abort!"
	exit 1
fi

echo "Creating GPT table on $DEV"
if gpart create -s gpt $DEV ; then 
else
	echo "Abort!"
	exit 1
fi

if echo "Adding EFI partition to $DEV"
gpart add -t efi -l efiboot -a 4k -s 100M $DEV ; then 
else
	echo "Abort!"
	exit 1
fi

echo "Adding FreeBSD UFS partition to $DEV"
if gpart add -t freebsd-ufs -s $ROOTSIZE $DEV ; then
else
	echo "Abort!"
	exit 1
fi

echo "Adding FreeBSD Swap partition to $DEV"
if gpart add -t freebsd-swap -s 1G $DEV ; then
else
	echo "Abort!"
	exit 1
fi

echo "Formatting EFI on $DEV with FAT16"
if newfs_msdos -F 16 -c 1 ${DEV}p1 ; then
else
	echo "Abort!"
	exit 1
fi

echo "Mounting EFI partition ${DEV}p1 to /mnt"
if mount_msdosfs ${DEV}p1 /mnt ; then
else
	echo "Abort!"
	exit 1
fi

echo "Copying FreeBSD bootloader to /mnt/EFI"
if cp -r /boot/efi/efi /mnt/ ; then
else
	echo "Abort!"
	exit 1
fi

echo "Unmounting EFI partition ${DEV}p1"
if umount ${DEV}p1 ; then
else
	echo "Abort!"
	exit 1
fi

echo "Formatting FreeBSD UFS partition ${DEV}p2"
if newfs ${DEV}p2 ; then
else
	echo "Abort!"
	exit 1
fi

echo "Mounting FreeBSD UFS partition ${DEV}p2 to /mnt"
if mount ${DEV}p2 /mnt ; then
else
	echo "Abort!"
	exit 1
fi

echo "Dumping / filesystem to ${DEV}p2"
if (cd /mnt; dump -0 -L -f - / | restore -v -r -f - .); then 
else
	echo "Abort!"
	exit 1
fi

echo "Modifying /etc/fstab"
if sed -e 's/\/ada/\/da/' -i .old /mnt/etc/fstab ; then
else
	echo "Abort!"
	exit 1
fi
rm /mnt/etc/fstab.old

echo "Calling cleanup script $CLEANUP"
sh $CLEANUP 2> /dev/null

echo

df

echo

echo "Done!"
echo
echo "Please check /mnt manually before making image of $DEV"

exit 0


