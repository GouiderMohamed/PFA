SUMMARY = "Qt6 Automotive Dashboard"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Ajoute TOUS les fichiers mentionnés dans ton CMake
SRC_URI = "file://CMakeLists.txt \
           file://main.cpp \
           file://Main.qml \
           file://Speedometer.qml \
           file://RpmGauge.qml \
           file://IndicatorIcon.qml \
           file://backend.h \
           file://backend.cpp \
           file://gpio_handler.h \
           file://gpio_handler.cpp \
           file://i2c_handler.h \
           file://i2c_handler.cpp \
"

S = "${WORKDIR}"

DEPENDS += "qtbase qtdeclarative qtdeclarative-native"

inherit qt6-cmake

# Correction du nom de l'exécutable pour l'installation
do_install:append() {
    # On s'assure que le binaire est bien installé là où on l'attend
    # CMake installe déjà dans ${bindir} grâce à 'install(TARGETS...)'
    # Mais si tu veux un nom plus simple dans l'image :
    ln -sf appAutomotiveDashboard ${D}${bindir}/dashboard
}

RDEPENDS:${PN} += "qtdeclarative-qmlplugins"