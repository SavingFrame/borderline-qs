import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Bar.Widgets
import qs.Settings
import qs.BarOsd
import qs.ControlCenter

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
    readonly property real barRoundness: 1 - controlCenter.reveal

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
                        Layout.fillWidth: true
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
                    Network {}
                    Bluetooth {}
                    Volume {
                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.toggleControlCenter()
                        }
                    }
                    ClockWidget {}
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
    }

    function toggleControlCenter() {
        root.controlCenterOpened = !root.controlCenterOpened;
    }
}
