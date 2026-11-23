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
            icon: "\uE050"
            text: "Sound"
            selected: root.activeTab === 0
            onClicked: root.tabRequested(0)
        }

        TabButton {
            Layout.fillHeight: true
            icon: "\uE1BA"
            text: "Network"
            selected: root.activeTab === 1
            onClicked: root.tabRequested(1)
        }
    }
}
