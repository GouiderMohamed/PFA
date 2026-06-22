import QtQuick
import QtQuick.Controls
import QtQuick.Effects // Standard pour Scarthgap (Qt 6) à la place de Qt5Compat

Window {
    id: root
    width: 800
    height: 480
    visible: true
    color: "#020a12" // Couleur de secours très sombre

    // ── Accès Backend ─────────────────────────────────────────
    readonly property bool hasBackend: typeof backend !== "undefined" && backend !== null
    readonly property real speed:  hasBackend ? backend.vitesse : 0
    readonly property real rpm:    hasBackend ? backend.rpm     : 0
    readonly property bool leftOn: hasBackend ? backend.leftTurnActive  : false
    readonly property bool rightOn:hasBackend ? backend.rightTurnActive : false
    readonly property real temprature: hasBackend ? backend.temperature : 10

    // ── Fond Moderne Bleu ──────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#08203e" } // Bleu profond au centre
            GradientStop { position: 1.0; color: "#000000" } // Noir sur les bords
        }
    }

    // ── Lignes de Structure du Dashboard (Look Moderne) ────────
    Canvas {
        id: dashboardLines
        anchors.fill: parent
        opacity: 0.4
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "#00cfff";
            ctx.lineWidth = 1.5;
            ctx.beginPath();

            // Ligne supérieure stylisée
            ctx.moveTo(100, 60);
            ctx.lineTo(700, 60);

            // Arcs décoratifs autour des compteurs
            ctx.arc(0, 240, 280, -1.2, 1.2, false);
            ctx.moveTo(800, 240);
            ctx.arc(800, 240, 280, 1.9, 4.3, false);

            ctx.stroke();
        }
    }


    Item {
        id: header
        width: parent.width
        height: 60
        anchors.top: parent.top

        IndicatorIcon {
            id: leftIcon
            anchors.left: parent.left; anchors.leftMargin: 40; anchors.verticalCenter: parent.verticalCenter
            width: 35; height: 35
            direction: "left"
            isActive: root.leftOn
            activeColor: "#00ff88"
        }



        IndicatorIcon {
            id: rightIcon
            anchors.right: parent.right; anchors.rightMargin: 40; anchors.verticalCenter: parent.verticalCenter
            width: 35; height: 35
            direction: "right"
            isActive: root.rightOn
            activeColor: "#00ff88"
        }
    }


    Speedometer {
        id: speedo
        width: 420; height: 420
        anchors.left: parent.left
        anchors.leftMargin: -60
        anchors.verticalCenter: parent.verticalCenter
        speedValue: root.speed
    }

    RpmGauge {
        id: rpmGauge
        width: 420; height: 420
        anchors.right: parent.right
        anchors.rightMargin: -60
        anchors.verticalCenter: parent.verticalCenter
        rpmValue: root.rpm
    }

    Item {
        id: centerDisplay
        width: 200; height: 200
        anchors.centerIn: parent

        Column {
            anchors.centerIn: parent
            spacing: -5

            Text {
                text: Math.round(root.speed)
                font.pixelSize: 90
                font.bold: true
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "KM/H"
                font.pixelSize: 16
                font.bold: true
                color: "#00cfff"
                font.letterSpacing: 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 20 }

            Rectangle {
                width: 50; height: 50
                color: "transparent"
                border.color: "#00cfff"
                border.width: 2
                radius: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: root.speed < 5 ? "N" : Math.min(Math.floor(root.speed / 30) + 1, 6)
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        color: "transparent"

        // Ligne de base néon
        Rectangle {
            width: parent.width * 0.8
            height: 2
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#00cfff" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 60

            Text {
                text: Qt.formatTime(new Date(), "HH:mm")
                color: "white"; font.pixelSize: 18; font.weight: Font.Light
            }

            Text {
                text: root.temprature + " °C"
                color: root.temprature > 95 ? "#ff4444" : "white"
                font.pixelSize: 18; font.bold: true
            }
        }

    }

    Component.onCompleted: console.log("Dashboard moderne chargé avec succès.")
}
