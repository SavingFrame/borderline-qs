import Quickshell
import QtQuick
import qs.Settings
import qs.Theme

PopupWindow {
    id: root
    color: "transparent"
    implicitHeight: Settings.px(160)

    property bool opened: false
    property real reveal: opened ? 1 : 0
    visible: opened || reveal > 0
    property int activeTab: 0

    Rectangle {
        anchors.fill: parent
        bottomLeftRadius: 12
        bottomRightRadius: 12
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
            bottomLeftRadius: 11
            bottomRightRadius: 11

            TabStrip {
                id: tabStrip
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: Settings.px(8)
                anchors.leftMargin: Settings.px(10)
                activeTab: root.activeTab
                onTabRequested: index => root.activeTab = index
            }

            TabPages {
                anchors.top: tabStrip.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Settings.px(10)
                currentIndex: root.activeTab
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
