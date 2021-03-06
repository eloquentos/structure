#!/bin/bash

# TODO
# Set hostname etc.

# Successfully detects
# antergos-2014.08.07-x86_64.iso
# antergos-2015.11.14-x86_64.iso
# (BROKEN?) archlinux-2015.06.01-dual.iso
# (BROKEN?) bbqlinux-2015.05.16-x86_64-xfce4.iso


detect_arch() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

ls "$MOUNTPOINT"/eloquent 2>/dev/null || return

echo "$ISONAME" assumed to be ARCH

#
# Parse the required information out of the ISO
#

LIVETOOL=archiso
LIVETOOLVERSION=0

CFG=$(find "$MOUNTPOINT"/loader/entries/archiso-*.conf | head -n 1)

LINUX=$(cat $CFG | grep "linux " | head -n 1 | sed -e 's|linux ||g' | xargs)
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "archiso.img" | head -n 1 | sed -e 's|initrd ||g' | xargs)
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "options " | head -n 1 | sed -e 's|options ||g' | xargs)
echo "* APPEND $APPEND"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

set default=0
set timeout=3
set timeout_style=hidden

menuentry "Eloquent OS" --class arch {
        iso_path="/System/Images/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="img_loop=\${iso_path} img_dev=/dev/disk/by-uuid/$UUID max_loop=256"
        eloquent_args="quiet splash loglevel=0 rd.systemd.show_status=false rd.udev.log-priority=0"
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${eloquent_args} \${iso_args}
        initrd (loop)$INITRD
}
EOM

}
