import QtQuick

Item {
    id: root
    width: 40
    height: 40

    property bool isActive: false
    property color activeColor: "#00ff88"
    property string direction: "left"

    opacity: root.isActive ? 1.0 : 0.1

    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    Text {
        anchors.centerIn: parent
        text: root.direction === "left" ? "◄" : "►"
        color: root.activeColor
        font.pixelSize: Math.min(parent.width, parent.height) * 0.8
    }
}
