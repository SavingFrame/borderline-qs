import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Bar
import qs.Settings
import qs.Theme
import qs.Notifications

PopupWindow {
    id: root
    color: "transparent"
    implicitHeight: Settings.px(activeTab === ControlCenter.Calendar ? Settings.controlCenterCalendarHeight
        : activeTab === ControlCenter.Home ? Settings.controlCenterHomeHeight
        : activeTab === ControlCenter.Notifications ? Settings.controlCenterNotificationsHeight
        : Settings.controlCenterDefaultHeight)
    required property MonitorBrightness brightness
    required property NotificationService notificationService

    property bool opened: false
    property real reveal: opened ? 1 : 0
    visible: opened || reveal > 0
    enum Tab { Home, Sound, Network, Bluetooth, Calendar, Notifications }
    property int activeTab: ControlCenter.Home
    signal dismissRequested()

    HyprlandFocusGrab {
        windows: [root]
        active: root.opened
        onCleared: {
            if (root.opened)
                root.dismissRequested();
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.opened
        onActivated: root.dismissRequested()
    }

    Rectangle {
        anchors.fill: parent
        bottomLeftRadius: Settings.barCornerRadius
        bottomRightRadius: Settings.barCornerRadius
        color: Qt.tint(Theme.background, Theme.barOutline)

        opacity: root.reveal
        enabled: root.opened
        transform: Translate {
            y: -12 * (1 - root.reveal)
        }

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
            color: Theme.background
            bottomLeftRadius: Math.max(0, Settings.barCornerRadius - 1)
            bottomRightRadius: bottomLeftRadius

            Item {
                width: Math.min(Settings.px(Settings.controlCenterContentMaxWidth), Math.max(0, parent.width - Settings.px(24)))
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: Settings.px(10)
                anchors.bottomMargin: Settings.px(12)

                TabStrip {
                    id: tabStrip
                    anchors.top: parent.top
                    anchors.left: parent.left
                    activeTab: root.activeTab
                    onTabRequested: index => root.activeTab = index
                }

                TabPages {
                    id: pages
                    opened: root.opened
                    brightness: root.brightness
                    notificationService: root.notificationService
                    anchors.top: tabStrip.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.topMargin: Settings.px(12)
                    currentIndex: root.activeTab
                    onDismissRequested: root.dismissRequested()
                }
            }
        }
    }

    Behavior on reveal {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }
}
