import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Theme

Repeater {
    id: root
    model: Hyprland.workspaces
    Rectangle {
        required property var modelData

        Text {
            text: modelData.id
            anchors.centerIn: parent
            color: Theme.textPrimary
            font.pixelSize: 15
        }

        height: 24
        radius: 8
        width: 24
        border {
            width: modelData.id == Hyprland.focusedWorkspace.id ? 1 : 0
            color: Qt.rgba(0.58, 0.77, 0.99, 0.35)
        }
        // width: 10
        // height: 15
        color: "transparent"
    }
}
