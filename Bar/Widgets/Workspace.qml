import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Theme
import qs.Settings

Repeater {
    id: root
    model: Hyprland.workspaces
    Rectangle {
        required property var modelData

        Text {
            text: modelData.id
            anchors.centerIn: parent
            color: Theme.textPrimary
            font.pixelSize: Settings.px(14)
        }

        height: Settings.px(24)
        radius: Settings.px(8)
        width: Settings.px(22)
        border {
            width: modelData.id == Hyprland.focusedWorkspace.id ? 1 : 0
            color: Qt.rgba(0.58, 0.77, 0.99, 0.35)
        }
        // width: 10
        // height: 15
        color: "transparent"
    }
}
