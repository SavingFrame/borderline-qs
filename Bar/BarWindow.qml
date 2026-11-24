import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Bar.Widgets
import qs.Settings
import qs.BarOsd
import qs.ControlCenter
import qs.Media
import qs.Notifications

PanelWindow {
    id: root
    color: "transparent"
    required property var modelData
    screen: modelData
    anchors.top: true
    margins.top: 10

    implicitWidth: Math.round(modelData.width * Settings.barWidthRatio)
    implicitHeight: Settings.px(Settings.barHeight)

    property bool controlCenterOpened: false
    required property BarOsdController osdController
    required property NotificationService notificationService
    readonly property real barRoundness: 1 - controlCenter.reveal

    IdleInhibitor {
        window: root
        enabled: QuickSettings.caffeine
    }

    Rectangle {
        anchors.fill: parent
        topLeftRadius: 12
        topRightRadius: 12
        bottomLeftRadius: 12 * root.barRoundness
        bottomRightRadius: 12 * root.barRoundness
        color: Qt.tint(Theme.background, Theme.barOutline)

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: Theme.background
            radius: 11
            bottomLeftRadius: 11 * root.barRoundness
            bottomRightRadius: 11 * root.barRoundness
            anchors.bottomMargin: root.barRoundness

            Item {
                opacity: root.osdController.osd_active ? 0 : 1
                enabled: !root.osdController.osd_active
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    Workspace {
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    ClockWidget {
                        onDateTapped: root.toggleControlCenter(ControlCenter.Calendar)
                        onTimeTapped: root.toggleControlCenter(ControlCenter.Home)
                    }
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    MediaVisualizer {
                        player: root.osdController.player
                    }
                    KeyboardLayout {}
                    SystemTray {}
                    Network {
                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.toggleControlCenter(ControlCenter.Network)
                        }
                    }
                    Bluetooth {
                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.toggleControlCenter(ControlCenter.Bluetooth)
                        }
                    }
                    Volume {
                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.toggleControlCenter(ControlCenter.Sound)
                        }
                    }
                    Row {
                        spacing: 2
                        Accessible.role: Accessible.Button
                        Accessible.name: "Notifications (" + root.notificationService.count + ")"
                        Accessible.onPressAction: root.toggleControlCenter(ControlCenter.Notifications)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.notificationService.dnd ? "\uE7F6" : "\uE7F4"
                            color: Theme.textPrimary
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: Settings.px(Settings.iconSize)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.notificationService.count > 0
                            text: root.notificationService.count > 99 ? "99+" : String(root.notificationService.count)
                            color: Theme.textPrimary
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.px(14)
                            font.features: { "tnum": 1 }
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.toggleControlCenter(ControlCenter.Notifications)
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 170
                        easing.type: Easing.OutCubic
                    }
                }
            }

            BarOsd {
                id: osdBar

                trackWidth: parent.width * 0.4
                opacity: root.osdController.osd_active ? 1 : 0
                enabled: root.osdController.osd_active
                anchors.centerIn: parent
                value: root.osdController.osdPercent
                icon: root.osdController.osdIcon
                osdMode: root.osdController.osdMode
                player: root.osdController.player

                Behavior on opacity {
                    NumberAnimation {
                        duration: 170
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    ControlCenter {
        id: controlCenter
        // anchor.window: root
        implicitWidth: root.implicitWidth
        anchor.window: root
        anchor.rect.x: 0
        anchor.rect.y: root.height
        opened: root.controlCenterOpened
        brightness: root.osdController.brightness
        notificationService: root.notificationService
        onDismissRequested: root.controlCenterOpened = false
    }

    function toggleControlCenter(tab: int): void {
        if (root.controlCenterOpened && controlCenter.activeTab === tab) {
            root.controlCenterOpened = false;
        } else {
            controlCenter.activeTab = tab;
            root.controlCenterOpened = true;
        }
    }
}
