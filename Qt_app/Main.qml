import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Window {
    id: root
    width: 1024
    height: 600
    visible: true
    color: "#000000"

    // Fond dégradé Bleu et Noir
    Rectangle {
        anchors.fill: parent
        z: -2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#001a33" } // Bleu
            GradientStop { position: 1.0; color: "#000000" } // Noir
        }
    }

    readonly property bool hasBackend: typeof backend !== "undefined" && backend !== null
    readonly property real speed:  hasBackend ? backend.vitesse : 0
    readonly property real rpm:    hasBackend ? backend.rpm     : 0
    readonly property bool leftOn: hasBackend ? backend.leftTurnActive  : false
    readonly property bool rightOn:hasBackend ? backend.rightTurnActive : false
    readonly property real temprature: hasBackend ? backend.temperature : 10

    // Jauge Essence (Fuel)
    Item {
        id: fuelGauge
        width: 150; height: 150
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80

        Shape {
            anchors.fill: parent
            layer.enabled: true; layer.samples: 4
            ShapePath {
                strokeColor: "#87CEEB"; strokeWidth: 4; fillColor: "transparent" // Bleu ciel
                PathAngleArc { centerX: 75; centerY: 75; radiusX: 70; radiusY: 70; startAngle: 120; sweepAngle: 120 }
            }
        }
        Repeater {
            model: ["0", "1/2", "1"]
            delegate: Text {
                text: modelData; color: "#ff9100"; font.pixelSize: 16; font.bold: true
                readonly property real angle: 120 + index * 60
                readonly property real rad: angle * Math.PI / 180
                x: 75 + 50 * Math.cos(rad) - width/2
                y: 75 + 50 * Math.sin(rad) - height/2
            }
        }
        
        // Aiguille
        Rectangle {
            width: 2; height: 50; color: "#ff9100"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            transformOrigin: Item.Top
            rotation: 120 - 90 + 60 // Pointe vers 1/2
        }
        
        Text { text: "⛽"; color: "#ff9100"; font.pixelSize: 20; anchors.centerIn: parent; anchors.verticalCenterOffset: 30 }
    }

    // Jauge Température
    Item {
        id: tempGauge
        width: 150; height: 150
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80

        Shape {
            anchors.fill: parent
            layer.enabled: true; layer.samples: 4
            ShapePath {
                strokeColor: "#ADD8E6"; strokeWidth: 4; fillColor: "transparent" // Bleu claire
                PathAngleArc { centerX: 75; centerY: 75; radiusX: 70; radiusY: 70; startAngle: -60; sweepAngle: 120 }
            }
        }
        Repeater {
            model: ["140", "250", "360"]
            delegate: Text {
                text: modelData; color: "#ff9100"; font.pixelSize: 16; font.bold: true
                readonly property real angle: -60 + index * 60
                readonly property real rad: angle * Math.PI / 180
                x: 75 + 50 * Math.cos(rad) - width/2
                y: 75 + 50 * Math.sin(rad) - height/2
            }
        }
        
        // Aiguille
        Rectangle {
            width: 2; height: 50; color: "#ff9100"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            transformOrigin: Item.Top
            rotation: -60 - 90 + Math.min(120, Math.max(0, (root.temprature / 100) * 120))
        }
        
        Text { text: "🌡️"; color: "#ff9100"; font.pixelSize: 20; anchors.centerIn: parent; anchors.verticalCenterOffset: 30 }
    }


    // Indicateurs (Top center)
    Row {
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 200 // Espacement large pour encadrer les alertes

        IndicatorIcon {
            direction: "left"
            isActive: root.leftOn
            width: 35; height: 35
        }
        IndicatorIcon {
            direction: "right"
            isActive: root.rightOn
            width: 35; height: 35
        }
    }
    
    // Alertes et Warnings (Centrés entre les clignotants)
    Row {
        anchors.top: parent.top
        anchors.topMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 25

        Text { text: "(!)"; color: "#ffff00"; font.pixelSize: 22; font.bold: true; opacity: 0.8 }
        Text { text: "ABS"; color: "#ffff00"; font.pixelSize: 20; font.bold: true; opacity: 0.8 }
        Text { text: "BRAKE"; color: "#ff1744"; font.pixelSize: 20; font.bold: true; opacity: 0.9 }
    }

    // Compteurs Principaux
    Speedometer {
        id: speedo
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 120
        speedValue: root.speed
        scale: 0.85 // Optimisation par rapport à transform: Scale {}
        antialiasing: true
    }

    RpmGauge {
        id: rpmGauge
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 120
        rpmValue: root.rpm
        scale: 0.85 // Optimisation par rapport à transform: Scale {}
        antialiasing: true
    }

    // Zone Centrale (Textes)
    Item {
        width: 300
        height: 280
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        Column {
            anchors.top: parent.top
            anchors.topMargin: 190
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Text {
                text: "Service due in"
                color: "#87CEEB"
                font.pixelSize: 14
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "8000 miles - 11/2026"
                color: "#ffffff"
                font.pixelSize: 16
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Repeater {
                model: 30
                delegate: Rectangle {
                    width: 5; height: 3; color: "#87CEEB"
                    opacity: Math.max(0.1, 1.0 - Math.abs(index - 15) * 0.06)
                }
            }
        }
    }

    // Heure et Température affichages
    Text {
        text: "TIME\n" + Qt.formatTime(new Date(), "HH:mm") + " PM"
        color: "#87CEEB"
        font.pixelSize: 13
        font.bold: true
        lineHeight: 1.3
        anchors.bottom: parent.bottom; anchors.bottomMargin: 32
        anchors.left: parent.left; anchors.leftMargin: 200
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        text: "TEMP\n+" + root.temprature + " °F"
        color: "#87CEEB"
        font.pixelSize: 13
        font.bold: true
        lineHeight: 1.3
        anchors.bottom: parent.bottom; anchors.bottomMargin: 32
        anchors.right: parent.right; anchors.rightMargin: 200
        horizontalAlignment: Text.AlignHCenter
    }
}
