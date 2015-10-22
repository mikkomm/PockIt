import QtQuick 2.0
import Ubuntu.Components 1.1

MouseArea {
    id: headerMouseArea
    y: units.gu(6.1)
    width: parent.width
    height: units.gu(1.9)
    z: -1
    property bool pressed: false

    Rectangle {
        id: headerRect
        anchors.fill: parent
        z: -1
        color: "transparent"

        Image {
            width: parent.width
            height: parent.height
            source: "../img/pocketline.png"
        }
    }

    onPressed: pressed = true
    onReleased: pressed = false
}
