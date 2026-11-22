import QtQuick
import qs.Settings
import qs.Theme

Item {
    id: root
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    property int value: 0
    property string icon
    property real trackWidth: Settings.px(112)

    readonly property int percent: Math.max(0, Math.min(100, value))
    Row {
        id: content
        spacing: Settings.px(10)
        Text {
            font.pixelSize: Settings.px(Settings.iconSize)
            font.family: "Material Symbols Rounded"
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
        }
        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            // width: Settings.px(112)
            // width: Settings.px(224)
            width: root.trackWidth
            height: Settings.px(5)
            radius: height / 2
            color: Theme.surfaceHover

            Rectangle {
                width: track.width * root.percent / 100
                height: track.height
                radius: Math.min(width, height) / 2
                color: Theme.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: Settings.px(36)
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Settings.px(12)
            color: Theme.textPrimary
            text: root.percent + "%"
        }
    }
}
