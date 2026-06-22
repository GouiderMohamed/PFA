SUMMARY = "Script Python de simulation de données automobile"
SECTION = "devtools"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Source du script
SRC_URI = "file://simulator.py"

S = "${WORKDIR}"

# On s'assure que python3 est disponible pour exécuter ce script
RDEPENDS:${PN} += "python3-core python3-io python3-netclient"

do_install() {
    # Création du dossier /usr/bin dans l'image
    install -d ${D}${bindir}
    # Installation du script avec les droits d'exécution
    install -m 0755 simulator.py ${D}${bindir}/simulator.py
}