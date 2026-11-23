import QtQuick
import qs.Settings
import qs.Theme

Rectangle {
    id: root
    color: selected ? Theme.surfaceHover : "transparent"

    implicitWidth: content.implicitWidth + Settings.px(24)
    implicitHeight: Math.max(Settings.px(32), content.implicitHeight + Settings.px(8))

    property bool selected: false
    signal clicked

    required property string icon
    required property string text

    TapHandler {
        onTapped: root.clicked()
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Settings.px(6)

        Text {

            font.pixelSize: Settings.px(Settings.iconSize)
            font.family: "Material Symbols Rounded"
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
        }
        Text {
            text: root.text
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            font.pixelSize: Settings.px(16)
            font.family: Settings.fontFamily
            font.features: {
                "tnum": 1
            }
        }
    }
}
