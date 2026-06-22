import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width: 400
    height: 400

    // Empêche le lissage inutile qui consomme du CPU sur processeur ARM
    layer.enabled: false

    property real rpmValue: backend.rpm
    property real maxRpm: 8000
    property real redlineRpm: 6500

    readonly property real startAngle: -220
    readonly property real totalArc: 260
    readonly property real ratio: Math.min(rpmValue / maxRpm, 1.0)

    // Couleurs optimisées (pas de gradients complexes)
    readonly property color arcColor: {
        if (ratio < 0.45) return "#00cfff"
        if (ratio < 0.65) return "#00e676"
        if (ratio < 0.82) return "#ff9100"
        return "#ff1744"
    }

    // Fond statique (Rectangle simple = très rapide)
    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
        radius: width / 2
    }

    // --- LOGIQUE SHAPE OPTIMISÉE POUR YOCTO ---
    // On regroupe les arcs dans un seul Shape si possible pour limiter les "Draw Calls"
    Shape {
        anchors.fill: parent
        // Force le moteur de rendu logiciel si le GPU est absent/faible
        preferredRendererType: Shape.SoftwareRenderer
        antialiasing: true

        // Arc de fond (Gris)
        ShapePath {
            strokeColor: "#1c1c1c"
            strokeWidth: 14
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 200; centerY: 200
                radiusX: 158; radiusY: 158
                startAngle: root.startAngle
                sweepAngle: root.totalArc
            }
        }

        // Arc de progression (Dynamique)
        ShapePath {
            strokeColor: root.arcColor
            strokeWidth: 14
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 200; centerY: 200
                radiusX: 158; radiusY: 158
                startAngle: root.startAngle
                sweepAngle: root.ratio * root.totalArc
            }
        }
    }

    // --- GRADUATIONS (Utilisation de Repeater) ---
    // Conseil : Dans Yocto, les Repeaters sont plus économes que de multiplier les Shapes
    Repeater {
        model: 25
        delegate: Rectangle {
            readonly property real fraction: index / 24.0
            readonly property real angleDeg: root.startAngle + fraction * root.totalArc
            readonly property real angleRad: angleDeg * Math.PI / 180

            width: (index % 4 === 0) ? 2 : 1
            height: (index % 4 === 0) ? 12 : 6
            color: (fraction >= root.redlineRpm / root.maxRpm) ? "#662222" : "#444444"

            x: 200 + 140 * Math.cos(angleRad) - width / 2
            y: 200 + 140 * Math.sin(angleRad) - height / 2
            rotation: angleDeg + 90
        }
    }

    // --- AIGUILLE (Animation simplifiée pour éviter les saccades) ---
    Rectangle {
        id: needle
        width: 3; height: 120
        color: "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: root.startAngle + 90 + root.ratio * root.totalArc

        Behavior on rotation {
            NumberAnimation {
                duration: 150 // Un peu plus court pour plus de réactivité sur écran LCD
                easing.type: Easing.OutQuad
            }
        }
    }

    // Cercle central (Pivot)
    Rectangle {
        anchors.centerIn: parent
        width: 12; height: 12; radius: 6
        color: "#ffffff"
    }

    // Texte Central
    Text {
        text: Math.round(root.rpmValue)
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 40
        color: "white"
        font.pixelSize: 24
        font.bold: true
    }
}
