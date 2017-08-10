#!/bin/sh

echo "8636400">/proc/sys/net/core/rmem_max

echo "0" > /sys/class/android_usb/android0/enable
echo "iap,ncm" > /sys/class/android_usb/android0/functions
echo "1" > /sys/class/android_usb/android0/enable

ifconfig lo up
ifconfig usb0 up
ifconfig usb0 fe80::4859:5aff:fe42:efab/64

/bin/mdnsd




