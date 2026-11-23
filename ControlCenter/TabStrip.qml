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

        TabButton {
            Layout.fillHeight: true
            icon: "\uE88A"
            text: "Home"
            selected: root.activeTab === ControlCenter.Home
            onClicked: root.tabRequested(ControlCenter.Home)
        }

        TabButton {
            Layout.fillHeight: true
            icon: "\uE050"
            text: "Sound"
            selected: root.activeTab === ControlCenter.Sound
            onClicked: root.tabRequested(ControlCenter.Sound)
        }

        TabButton {
            Layout.fillHeight: true
            icon: "\uE1BA"
            text: "Network"
            selected: root.activeTab === ControlCenter.Network
            onClicked: root.tabRequested(ControlCenter.Network)
        }
    }
}
