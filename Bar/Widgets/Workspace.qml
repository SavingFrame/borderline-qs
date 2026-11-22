import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Theme
import qs.Settings

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
            color: Theme.workspaceOutline
        }
        color: workspaceMouse.containsMouse ? Theme.surface : "transparent"
        Row {
            id: workspaceContent
            anchors.centerIn: parent
            spacing: Settings.px(8)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: workspace.modelData.id
                color: Theme.textPrimary
                font.pixelSize: Settings.px(13)

                font.family: Settings.fontFamily
                font.features: {
                    "tnum": 1
                }
            }
            Connections {
                target: Hyprland

                function onRawEvent(event) {
                    if (event.name === "movewindowv2" || event.name === "activewindowv2")
                        Hyprland.refreshToplevels();
                }
            }
            Repeater {
                id: windowIcons
                model: {
                    const items = Array.from(workspace.modelData.toplevels.values);
                    return items.sort((a, b) => {
                        const [ax, ay] = a.lastIpcObject.at ?? [Infinity, Infinity];
                        const [bx, by] = b.lastIpcObject.at ?? [Infinity, Infinity];
                        if (ax !== bx)
                            return ax - bx;
                        if (ay !== by)
                            return ay - by;
                        return 0;
                    });
                }
                Item {
                    id: item

                    width: Settings.px(19)
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    visible: modelData.lastIpcObject?.floating !== true
                    required property var modelData

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        visible: status == Image.Ready
                        source: {
                            const appId = item.modelData.wayland?.appId || item.modelData.lastIpcObject?.class || "";
                            if (!appId || DesktopEntries.applications.values.length === 0) {
                                return "";
                            }
                            const entry = DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
                            return Quickshell.iconPath(entry?.icon || appId, true);
                        }
                        sourceSize: Qt.size(32, 32)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Rectangle {
                        visible: appIcon.status !== Image.Ready
                        // anchors.centerIn: parent
                        anchors.fill: parent
                        // implicitWidth: item.implicitWidth
                        // implicitHeight: item.implicitHeight
                        color: Theme.surface
                        radius: Settings.px(4)
                        // color: "white"
                        Text {
                            anchors.centerIn: parent
                            text: "?"
                            color: Theme.textMuted
                        }
                    }
                }
            }
        }

        MouseArea {
            id: workspaceMouse
            anchors.fill: parent
            onClicked: workspace.modelData.activate()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
