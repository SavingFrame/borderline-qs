pragma ComponentBehavior: Bound

import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.Settings

NetworkUi.Surface {
    id: adapter
    required property WiredDevice device
    required property bool active
    required property bool showInterfaceName
    readonly property bool busy: device.state === ConnectionState.Connecting || device.state === ConnectionState.Disconnecting

    signal actionRequested()
    signal connectionFailed(string name, int reason)

    RowLayout {
        Layout.fillWidth: true
        NetworkUi.StatusIcon {
            text: "\uEB2F"
            highlighted: adapter.device.connected
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Settings.px(2)
            NetworkUi.Title {
                Layout.fillWidth: true
                text: adapter.showInterfaceName ? "Ethernet · " + adapter.device.name : "Ethernet"
            }
            NetworkUi.Label {
                Layout.fillWidth: true
                text: {
                    const device = adapter.device;
                    if (!device.nmManaged) return "Not managed by NetworkManager";
                    if (adapter.busy) return ConnectionState.toString(device.state);
                    if (!device.hasLink) return "Cable unplugged";
                    if (!device.connected) return "Disconnected";
                    return device.linkSpeed > 0 ? "Connected · " + device.linkSpeed + " Mb/s" : "Connected";
                }
            }
        }
        NetworkUi.Action {
            visible: adapter.device.nmManaged && (adapter.device.hasLink || adapter.device.connected)
            enabled: !adapter.busy && (adapter.device.connected || adapter.device.network !== null)
            text: adapter.device.connected ? "Disconnect" : "Connect"
            onClicked: {
                adapter.actionRequested();
                if (adapter.device.connected)
                    adapter.device.disconnect();
                else
                    adapter.device.network.connect();
            }
        }
    }

    NetworkDetails {
        Layout.fillWidth: true
        Layout.topMargin: Settings.px(4)
        interfaceName: adapter.device.name
        active: adapter.active && adapter.device.connected
    }

    Connections {
        target: adapter.device.network
        function onConnectionFailed(reason) { adapter.connectionFailed(adapter.device.name, reason); }
    }
}
