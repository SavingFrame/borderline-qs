import QtQuick
import QtQuick.Layouts
import qs.ControlCenter.Widgets
import qs.Theme

Rectangle {
    id: root

    required property int activeTab
    signal tabRequested(int index)

    color: Theme.surface
    border.width: 1
    border.color: Theme.barOutline
    implicitWidth: tabs.implicitWidth + 2
    implicitHeight: tabs.implicitHeight + 2

    RowLayout {
        id: tabs
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        TabButton {
            Layout.fillHeight: true
            icon: "\uE050"
            text: "Sound"
            selected: root.activeTab === 0
            onClicked: root.tabRequested(0)
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Theme.barOutline
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
