import QtQuick
import QtQuick.Layouts
import qs.ControlCenter.Widgets
import qs.Settings
import qs.Theme

Rectangle {
    id: root

    required property int activeTab
    signal tabRequested(int index)

    readonly property int inset: Settings.px(3)
    readonly property real labeledWidth: home.labeledWidth + sound.labeledWidth + network.labeledWidth
        + bluetooth.labeledWidth + calendar.labeledWidth + 4 * tabs.spacing + 2 * inset
    radius: height / 2
    color: Theme.background
    border.width: 1
    border.color: Theme.barOutline
    implicitWidth: tabs.implicitWidth + 2 * inset
    implicitHeight: tabs.implicitHeight + 2 * inset

    RowLayout {
        id: tabs
        anchors.fill: parent
        anchors.margins: root.inset
        spacing: Settings.px(2)

        component StripButton: TabButton {
            Layout.fillHeight: true
            showLabel: root.labeledWidth <= root.parent.width
        }

        StripButton {
            id: home
            icon: "\uE88A"
            text: "Home"
            selected: root.activeTab === ControlCenter.Home
            onClicked: root.tabRequested(ControlCenter.Home)
        }

        StripButton {
            id: sound
            icon: "\uE050"
            text: "Sound"
            selected: root.activeTab === ControlCenter.Sound
            onClicked: root.tabRequested(ControlCenter.Sound)
        }

        StripButton {
            id: network
            icon: "\uE1BA"
            text: "Network"
            selected: root.activeTab === ControlCenter.Network
            onClicked: root.tabRequested(ControlCenter.Network)
        }

        StripButton {
            id: bluetooth
            icon: "\uE1A7"
            text: "Bluetooth"
            selected: root.activeTab === ControlCenter.Bluetooth
            onClicked: root.tabRequested(ControlCenter.Bluetooth)
        }

        StripButton {
            id: calendar
            icon: "\uEBCC"
            text: "Calendar"
            selected: root.activeTab === ControlCenter.Calendar
            onClicked: root.tabRequested(ControlCenter.Calendar)
        }
    }
}
