import QtQuick
import Quickshell.Services.Mpris
import qs.Settings
import qs.Theme

Row {
    id: progressRow
    visible: root.osdMode === "progress"
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
