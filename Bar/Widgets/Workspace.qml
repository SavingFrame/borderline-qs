import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Theme
import qs.Settings
import Quickshell.Widgets

Repeater {
    id: root
    model: Hyprland.workspaces
    Rectangle {
        id: workspace
        required property var modelData
        height: Settings.px(24)
        radius: Settings.px(8)
        implicitHeight: Settings.px(26)
        implicitWidth: Math.max(Settings.px(22), workspaceContent.implicitWidth + Settings.px(14))

        border {
            width: modelData.id == Hyprland.focusedWorkspace.id ? 1 : 0
            color: Qt.rgba(0.58, 0.77, 0.99, 0.35)
        }
        color: "transparent"
        Row {
            id: workspaceContent
            anchors.centerIn: parent
            spacing: Settings.px(8)

            Text {
                // text: modelData.id
                // anchors.centerIn: parent
                anchors.verticalCenter: parent.verticalCenter
                text: workspace.modelData.id
                color: Theme.textPrimary
                font.pixelSize: Settings.px(13)
            }
            Repeater {
                id: windowIcons
                model: workspace.modelData.toplevels
                Image {
                    required property var modelData
                    width: Settings.px(19)
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    visible: status == Image.Ready
                    source: {
                        const appId = modelData.wayland?.appId || modelData.lastIpcObject?.class || "";
                        if (!appId) {
                            return "";
                        }
                        const entry = DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
                        return Quickshell.iconPath(entry?.icon || appId, "application-x-executable");
                    }
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }
    }
}
