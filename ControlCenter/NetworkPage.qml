pragma ComponentBehavior: Bound

import Quickshell.Networking
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.ControlCenter.Widgets.Network
import qs.Settings
import qs.Theme

Flickable {
    id: root

    required property bool active
    readonly property bool available: Networking.backend === NetworkBackendType.NetworkManager
    readonly property list<WiredDevice> ethernetDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wired)
    property string errorMessage: ""

    clip: true
    contentWidth: width
    contentHeight: sections.implicitHeight
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Basic.ScrollBar.vertical: Basic.ScrollBar { policy: Basic.ScrollBar.AsNeeded }

    onActiveChanged: {
        if (!active) {
            errorMessage = "";
            contentY = 0;
        }
    }

    function revealItem(item: Item): void {
        const y = item.mapToItem(contentItem, 0, 0).y;
        if (y < contentY)
            contentY = y;
        else if (y + item.height > contentY + height)
            contentY = Math.min(Math.max(0, contentHeight - height), y + item.height - height);
    }

    function showConnectionError(name: string, reason: int): void {
        if (active) {
            errorMessage = "Could not connect to " + name + ": " + ConnectionFailReason.toString(reason);
            contentY = 0;
        }
    }

    WifiSection {
        id: wifi
        active: root.active
        onActionRequested: root.errorMessage = ""
        onConnectionFailed: (name, reason) => root.showConnectionError(name, reason)
        onRevealItem: item => root.revealItem(item)
    }

    GridLayout {
        id: sections
        width: Math.max(0, root.width - Settings.px(8))
        columns: width >= Settings.px(650) ? 2 : 1
        columnSpacing: Settings.px(24)
        rowSpacing: Settings.px(20)

        NetworkUi.Label {
            Layout.fillWidth: true
            Layout.columnSpan: sections.columns
            visible: !root.available || root.errorMessage !== ""
            text: root.available ? root.errorMessage : "NetworkManager is not available."
            color: Theme.danger
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(445)
            spacing: Settings.px(8)
            visible: root.available

            NetworkUi.Heading { text: "Connections" }

            Repeater {
                model: root.available ? root.ethernetDevices : []

                EthernetCard {
                    required property WiredDevice modelData
                    Layout.fillWidth: true
                    active: root.active
                    device: modelData
                    showInterfaceName: root.ethernetDevices.length > 1
                    onActionRequested: root.errorMessage = ""
                    onConnectionFailed: (name, reason) => root.showConnectionError(name, reason)
                }
            }

            Loader {
                Layout.fillWidth: true
                active: root.available
                sourceComponent: wifi.connectionCard
            }
        }

        Loader {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(560)
            active: root.available
            visible: active
            sourceComponent: wifi.nearbyList
        }
    }
}
