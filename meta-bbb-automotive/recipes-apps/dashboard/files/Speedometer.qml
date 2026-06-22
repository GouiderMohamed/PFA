import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root
    width: 400
    height: 400

    // Propriétés liées au Backend C++
    property int speedValue:backend.vitesse
    property int maxSpeed: 240

    readonly property real startAngle: -220
    readonly property real totalArc: 260

    // OPTIMISATION YOCTO : Utiliser layer.enabled sur les Shapes complexes
    // pour que le GPU mette en cache le dessin et ne le recalcule pas à chaque frame.

    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
        radius: width / 2
        layer.enabled: true // Cache matériel
    }

    // Arc de fond fixe (ne change jamais)
    Shape {
        id: backgroundArc
        anchors.fill: parent
        layer.enabled: true // Très important : cet arc est statique
        layer.samples: 4          // Antialiasing matériel

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
    }

    // Arc de progression (Dynamique)
    Shape {
        anchors.fill: parent
        // Pas de layer.enabled ici car il change tout le temps
        layer.samples: 4

        ShapePath {
            id: speedArc
            strokeWidth: 14
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            // Optimisation de la logique de couleur (plus rapide que des if ratio)
            strokeColor: root.speedValue < 96  ? "#00cfff" : // < 40%
                         root.speedValue < 156 ? "#00e676" : // < 65%
                         root.speedValue < 204 ? "#ff9100" : // < 85%
                                                 "#ff1744"   // Danger

            PathAngleArc {
                centerX: 200; centerY: 200
                radiusX: 158; radiusY: 158
                startAngle: root.startAngle
                // Calcul direct pour éviter les propriétés intermédiaires
                sweepAngle: (root.speedValue / root.maxSpeed) * root.totalArc

                Behavior on sweepAngle {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // Graduations : Utilisation de 'Text' pour les chiffres si besoin
    Repeater {
        model: 25
        delegate: Rectangle {
            readonly property real angle: (root.startAngle + (index / 24.0) * root.totalArc) * Math.PI / 180
            width: (index % 4 === 0) ? 2 : 1
            height: (index % 4 === 0) ? 12 : 6
            color: (index % 4 === 0) ? "#666666" : "#333333"
            x: 200 + 142 * Math.cos(angle) - width / 2
            y: 200 + 142 * Math.sin(angle) - height / 2
            rotation: root.startAngle + (index / 24.0) * root.totalArc + 90
            antialiasing: false // Gain de performance sur les petits éléments
        }
    }

    // Affichage Numérique
    Text {
        id: speedLabel
        text: root.speedValue
        anchors.centerIn: parent
        color: speedArc.strokeColor
        font.pixelSize: 48
        font.bold: true
        font.family: "Monospace"
    }

    // Aiguille
    Rectangle {
        id: needle
        width: 3
        height: 125
        color: "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        antialiasing: true

        rotation: root.startAngle + 90 + (root.speedValue / root.maxSpeed) * root.totalArc

        Behavior on rotation {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
}
