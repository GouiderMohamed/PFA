import QtQuick

Item {
    id: root
    width: 300
    height: 300

    // ── Propriétés publiques ──────────────────────────────────
    property bool   isActive:    false      // Reçoit (Active && FlashState) du C++
    property color  activeColor: "#020a12"
    property string direction:   "left"

    // ── Taille de référence ───────────────────────────────────
    readonly property real u: Math.min(width, height)

    // ── Opacité globale ───────────────────────────────────────
    // On simplifie : si isActive est vrai (C++), on affiche. Sinon, opacité basse.
    opacity: root.isActive ? 2.0 : 0.07

    Behavior on opacity {
        NumberAnimation { duration: 70; easing.type: Easing.OutQuad }
    }

    // ── Halo circulaire externe ──
    Rectangle {
        anchors.centerIn: parent
        width:  root.u * 0.96
        height: root.u * 0.96
        radius: width / 2
        color:  "transparent"
        border.color: root.activeColor
        border.width: 1
        opacity: 0.20
    }

    // ── Demi-anneau directionnel ──
    Rectangle {
        id: ring
        anchors.centerIn: parent
        width:  root.u * 1
        height: root.u * 1
        radius: width / 2
        color:  "transparent"
        border.color: root.activeColor
        border.width: 2.5
        opacity: 0.60
        clip: true // Important pour que le masquage fonctionne bien

        Rectangle {
            width:  parent.width  / 2 + 2
            height: parent.height + 6
            color:  "black" // Doit correspondre à la couleur de fond du tableau de bord
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:  root.direction === "right" ? parent.left  : undefined
            anchors.right: root.direction === "left"  ? parent.right : undefined
        }
    }

    // ── Flèche centrale (Caractère spécial pour une flèche plus nette) ──
    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.direction === "left" ? -u*0.05 : u*0.05
        text: root.direction === "left" ? "◄" : "►" // Utilisation de triangles pleins
        color: root.activeColor
        font.pixelSize: root.u * 0.4
    }
}
