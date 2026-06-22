FILESEXTRAPATHS:prepend := "${THISDIR}/${MACHINE}:"

SRC_URI:append:beaglebone-yocto = " file://usb-gadget.cfg"