import QtQuick
import Quickshell.Services.SystemTray
import Quickshell

import Quickshell.Widgets
import qs.Settings
import qs.Theme

PopupWindow {
    id: customTrayMenu
    required property SystemTrayItem sourceItem
    color: "transparent"
    grabFocus: true

    visible: false
    implicitWidth: 220
    implicitHeight: menuColumn.implicitHeight + 16

    QsMenuOpener {
        id: menuOpener
        menu: customTrayMenu.sourceItem.menu
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 6
        // color: "transparent"

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: menuOpener.children

                delegate: Item {
                    id: row
                    required property QsMenuEntry modelData

                    width: menuColumn.width
                    height: modelData.isSeparator ? 9 : 28

                    Rectangle {
                        visible: row.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: 1
                        color: Theme.surfaceHover
                    }

                    Rectangle {
                        visible: !row.modelData.isSeparator
                        anchors.fill: parent
                        radius: 4
                        color: {
                            if (row.modelData.enabled && hoverArea.containsMouse) {
                                return Theme.surfaceHover;
                            } else {
                                return "transparent";
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 8
                            Image {
                                visible: row.modelData.icon !== ""
                                source: row.modelData.icon
                                width: Settings.px(12)
                                height: Settings.px(12)
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize: Qt.size(16, 16)
                            }

                            Text {
                                text: row.modelData.text
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                color: row.modelData.enabled ? Theme.textPrimary : Theme.textMuted
                                font.pixelSize: Settings.px(12)
                                font.family: Settings.fontFamily
                                font.features: {
                                    "tnum": 1
                                }
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: row.modelData.enabled

                            onClicked: {
                                if (row.modelData.hasChildren) {
                                    menuOpener.menu = row.modelData;
                                } else {
                                    row.modelData.triggered();
                                    customTrayMenu.visible = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
