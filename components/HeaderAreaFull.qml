import QtQuick 2.0
import Ubuntu.Components 1.1

MouseArea {
    id: headerMouseArea
    anchors.fill: parent
    z: -1
    property bool pressed: false
    property string title: bigTitle
    property string subTitle: littleTitle

    Rectangle {
        id: headerRect
        anchors.fill: parent
        z: -1
        color: "#eb3f54"

        property real contentHeight: units.gu(7.5)
        property int fontWeight: Font.Light
        property string fontSize: "x-large"
        property string subFontSize: "large"
        property color textColor: "#ffffff"
        property real textLeftMargin: units.gu(2)

        property string title: headerMouseArea.title
        property string subTitle: headerMouseArea.subTitle
        property bool linkState: linkOpen

        Item {
            id: headerContents
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: headerRect.contentHeight

            Label {
                id: headerLabel
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: headerRect.textLeftMargin
                }
                text: headerRect.title
                font.weight: headerRect.fontWeight
                fontSize: headerRect.fontSize
                color: headerRect.textColor
            }
        }
    }

    onPressed: pressed = true
    onReleased: pressed = false
}
