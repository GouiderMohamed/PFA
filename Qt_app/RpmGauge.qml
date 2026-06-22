import QtQuick
import QtQuick.Shapes

Item {
    id: root
    width: 400
    height: 400

    property real rpmValue: typeof backend !== "undefined" && backend !== null ? backend.rpm : 0
    property real maxRpm: 7000

    readonly property real startAngle: 140
    readonly property real sweepAngle: 260

    // Couleurs
    readonly property color cyanColor: "#ADD8E6" // Bleu clair
    readonly property color skyBlueColor: "#87CEEB" // Bleu ciel
    readonly property color redColor: "#ff1744"
    readonly property color orangeColor: "#ff9100"

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

    // Ticks de l'arc rouge (mpg)
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

    // Graduations orange majeures (0 - 7)
    Repeater {
        model: 8 // 0 à 7
        delegate: Item {
            width: 400; height: 400
            readonly property real val: index * 1000
            readonly property real angleDeg: root.startAngle + (val / root.maxRpm) * root.sweepAngle
            readonly property real angleRad: angleDeg * Math.PI / 180

            Rectangle {
                width: 4; height: 16
                color: orangeColor
                x: 200 + 175 * Math.cos(angleRad) - width / 2
                y: 200 + 175 * Math.sin(angleRad) - height / 2
                rotation: angleDeg + 90
            }

            Text {
                text: index.toString()
                color: orangeColor
                font.pixelSize: 22
                font.bold: true
                x: 200 + 145 * Math.cos(angleRad) - width / 2
                y: 200 + 145 * Math.sin(angleRad) - height / 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Mineures
    Repeater {
        model: 14 // 7 intervalles * 2
        delegate: Rectangle {
            readonly property real val: index * 500
            readonly property real angleDeg: root.startAngle + (val / root.maxRpm) * root.sweepAngle
            readonly property real angleRad: angleDeg * Math.PI / 180
            visible: index % 2 !== 0

            width: 2; height: 8
            color: orangeColor
            x: 200 + 175 * Math.cos(angleRad) - width / 2
            y: 200 + 175 * Math.sin(angleRad) - height / 2
            rotation: angleDeg + 90
        }
    }

    // Aiguille
    Rectangle {
        id: needle
        width: 4; height: 150
        color: orangeColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: root.startAngle + 90 + (Math.min(root.rpmValue, root.maxRpm) / root.maxRpm) * root.sweepAngle
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

    Text {
        text: "1/min x 1000"
        color: orangeColor
        font.pixelSize: 14
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: 60
    }
}
