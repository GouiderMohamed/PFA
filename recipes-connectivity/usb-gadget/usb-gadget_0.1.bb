SUMMARY = "USB Gadget RNDIS/NCM networking for BeagleBone Black"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://usb-gadget.sh \
    file://usb-gadget.service \
    file://usb-gadget.conf \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "usb-gadget.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

do_install() {
    # Script
    install -d ${D}/usr/lib/usb-gadget
    install -m 0755 ${WORKDIR}/usb-gadget.sh \
        ${D}/usr/lib/usb-gadget/usb-gadget.sh

    # Systemd unit
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/usb-gadget.service \
        ${D}${systemd_system_unitdir}/usb-gadget.service

    # Config file
    install -d ${D}/etc/conf.d
    install -m 0644 ${WORKDIR}/usb-gadget.conf \
        ${D}/etc/conf.d/usb-gadget
}

FILES:${PN} += " \
    /usr/lib/usb-gadget/usb-gadget.sh \
    ${systemd_system_unitdir}/usb-gadget.service \
    /etc/conf.d/usb-gadget \
"

RDEPENDS:${PN} += "bash"