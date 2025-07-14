#!/bin/sh

IMG=Sniffer-FreeBSD-14.3-bootable.img
DEV=/dev/da0
BS=8192
COUNT=`gpart show /dev/da0 | awk "/freebsd-swap/{print \\$1 * 512 / $BS + 1}"`

gpart show $DEV

echo "Dumping $COUNT blocks per $BS bytes of image from $DEV to $IMG"

echo -n "Is this reasonable (y/N) ? "

read yesno

if [ "$yesno" != "y" ]; then
	echo "Abort!"
	exit 1
fi


dd if=/dev/da0 of=Sniffer-FreeBSD-14.3-bootable.img bs=$BS count=$COUNT status=progress

ls -al ${IMG}

echo

echo "Compressing $IMG to $IMG.xz"

xz -z -f -f $IMG

ls -al ${IMG}.*

echo

echo "Done!"


