import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width: 400
    height: 400

    property int speedValue: typeof backend !== "undefined" && backend !== null ? backend.vitesse : 0
    property int maxSpeed: 260

    readonly property real startAngle: 140
    readonly property real sweepAngle: 260

    // Couleurs
    readonly property color cyanColor: "#87CEEB" // Bleu ciel
    readonly property color lightBlueColor: "#ADD8E6" // Bleu clair
    readonly property color redColor: "#ff1744"
    readonly property color orangeColor: "#ff9100"

    // Arcs fixes
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        // Arc cyan principal
        ShapePath {
            strokeColor: cyanColor
            strokeWidth: 8
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                centerX: 200; centerY: 200
                radiusX: 190; radiusY: 190
                startAngle: root.startAngle
                sweepAngle: root.sweepAngle
            }
        }

        // Arc rouge en bas
        ShapePath {
            strokeColor: redColor
            strokeWidth: 8
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                centerX: 200; centerY: 200
                radiusX: 190; radiusY: 190
                startAngle: root.startAngle + root.sweepAngle
                sweepAngle: 360 - root.sweepAngle
            }
        }
    }

    // Ticks de l'arc rouge (miles)
    Repeater {
        model: 20
        delegate: Rectangle {
            readonly property real angleOffset: (index / 19) * (360 - root.sweepAngle)
            readonly property real angleDeg: root.startAngle + root.sweepAngle + angleOffset
            readonly property real angleRad: angleDeg * Math.PI / 180

            width: 2
            height: 8
            color: redColor
            x: 200 + 190 * Math.cos(angleRad) - width / 2
            y: 200 + 190 * Math.sin(angleRad) - height / 2
            rotation: angleDeg + 90
        }
    }

    // Graduations orange classiques (0 - 260)
    Repeater {
        model: 14 // 0, 20, 40, ..., 260 -> 14 ticks
        delegate: Item {
            width: 400; height: 400
            readonly property real val: index * 20
            readonly property real angleDeg: root.startAngle + (val / root.maxSpeed) * root.sweepAngle
            readonly property real angleRad: angleDeg * Math.PI / 180

            // Tick mark
            Rectangle {
                width: 4; height: 16
                color: orangeColor
                x: 200 + 175 * Math.cos(angleRad) - width / 2
                y: 200 + 175 * Math.sin(angleRad) - height / 2
                rotation: angleDeg + 90
            }

            // Texte (valeurs de vitesse)
            Text {
                text: val.toString()
                color: orangeColor
                font.pixelSize: 18
                font.bold: true
                x: 200 + 145 * Math.cos(angleRad) - width / 2
                y: 200 + 145 * Math.sin(angleRad) - height / 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    // Graduations mineures (orange)
    Repeater {
        model: 26 // 13 intervalles * 2
        delegate: Rectangle {
            readonly property real val: index * 10
            readonly property real angleDeg: root.startAngle + (val / root.maxSpeed) * root.sweepAngle
            readonly property real angleRad: angleDeg * Math.PI / 180
            visible: index % 2 !== 0

            width: 2; height: 8
            color: orangeColor
            x: 200 + 175 * Math.cos(angleRad) - width / 2
            y: 200 + 175 * Math.sin(angleRad) - height / 2
            rotation: angleDeg + 90
        }
    }

    // Aiguille (orange)
    Rectangle {
        id: needle
        width: 4; height: 150
        color: orangeColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: root.startAngle + 90 + (Math.min(root.speedValue, root.maxSpeed) / root.maxSpeed) * root.sweepAngle
        antialiasing: true

        Behavior on rotation {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
    
    // Pivot central
    Rectangle {
        anchors.centerIn: parent
        width: 30; height: 30
        radius: 15
        color: "#0a0a0a"
        border.color: orangeColor
        border.width: 2
    }
    
    // Label
    Text {
        text: "km/h"
        color: orangeColor
        font.pixelSize: 14
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: 60
    }
}
