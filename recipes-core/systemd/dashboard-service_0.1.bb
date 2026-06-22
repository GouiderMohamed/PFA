# ==============================================================================
# SECTION COMPLÉMENTAIRE ET INFORMATIONS SUR LA RECETTE
# ==============================================================================

# Une description courte qui explique ce que fait cette recette Yocto.
SUMMARY = "Configuration Systemd pour le Dashboard"

# Type de licence appliqué à cette recette (ici, la licence MIT, très courante).
LICENSE = "MIT"

# Vérification de l'intégrité de la licence. BitBake calcule le MD5 du fichier 
# pour s'assurer que les termes de la licence n'ont pas été modifiés.
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"


# ==============================================================================
# SOURCES ET GESTION DES DOSSIERS
# ==============================================================================

# Liste des fichiers locaux à récupérer. BitBake va chercher ces fichiers .service 
# dans le dossier "files/" de ton layer et va les copier dans le WORKDIR.
SRC_URI = "file://dashboard.service \
           file://sim-script.service"

# Définit le dossier des sources (S). On dit à Yocto que nos fichiers 
# de travail se trouvent directement à la racine du WORKDIR.
S = "${WORKDIR}"


# ==============================================================================
# CONFIGURATION DE SYSTEMD (INTEGRATION AUTOMATIQUE)
# ==============================================================================

# On hérite de la classe systemd de Yocto. C'est elle qui gère automatiquement 
# l'enregistrement, les dépendances et le cycle de vie des services au boot.
inherit systemd

# Indique à la classe systemd quels sont les fichiers de services qui appartiennent 
# à ce paquet principal (${PN} = Package Name, qui prend le nom de la recette).
SYSTEMD_SERVICE:${PN} = "dashboard.service sim-script.service"

# Configure le comportement initial : "enable" signifie que les services 
# seront automatiquement activés au démarrage de la BeagleBone / QEMU.
SYSTEMD_AUTO_ENABLE = "enable"


# ==============================================================================
# ÉTAPE D'INSTALLATION (LE DÉMÉNAGEMENT DANS LA FAUSSE RACINE)
# ==============================================================================

do_install() {
    # 1. Crée le dossier standard de Systemd (/lib/systemd/system) 
    # dans la fausse racine destination (${D}).
    install -d ${D}${systemd_system_unitdir}
    
    # 2. Copie le fichier dashboard.service depuis le WORKDIR vers le dossier systemd final 
    # avec les droits de lecture seule pour tout le monde (0644).
    install -m 0644 ${WORKDIR}/dashboard.service ${D}${systemd_system_unitdir}
    
    # 3. Fait la même chose pour le deuxième service (le script de simulation Python).
    install -m 0644 ${WORKDIR}/sim-script.service ${D}${systemd_system_unitdir}
}