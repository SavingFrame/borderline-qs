pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.ControlCenter.Widgets.Network
import qs.Settings

Flickable {
    id: root

    required property bool active
    signal dismissRequested()

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.state === BluetoothAdapterState.Enabled
    readonly property bool canToggle: powered || adapter?.state === BluetoothAdapterState.Disabled
    readonly property list<BluetoothDevice> pairedDevices: adapter?.devices.values.filter(device => device.paired) ?? []
    property bool managerMissing: false

    clip: true
    contentWidth: width
    contentHeight: sections.implicitHeight
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Basic.ScrollBar.vertical: Basic.ScrollBar { policy: Basic.ScrollBar.AsNeeded }

    onActiveChanged: if (!active) {
        managerMissing = false;
        contentY = 0;
    }

    Process {
        id: checkManager
        command: ["/bin/sh", "-c", "command -v blueman-manager >/dev/null 2>&1"]
        onExited: (exitCode, exitStatus) => {
            if (!root.active)
                return;
            root.managerMissing = exitCode !== 0;
            if (!root.managerMissing) {
                root.dismissRequested();
                Quickshell.execDetached(["blueman-manager"]);
            }
        }
    }

    GridLayout {
        id: sections
        width: Math.max(0, root.width - Settings.px(8))
        columns: width >= Settings.px(650) ? 2 : 1
        columnSpacing: Settings.px(24)
        rowSpacing: Settings.px(20)

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Settings.px(445)
            spacing: Settings.px(8)

            NetworkUi.Heading { text: "Adapter" }

            NetworkUi.Surface {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true

                    NetworkUi.StatusIcon {
                        text: root.powered ? "\uE1A7" : "\uE1A9"
                        highlighted: root.powered
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Settings.px(2)

                        NetworkUi.Title { Layout.fillWidth: true; text: "Bluetooth" }
                        NetworkUi.Label {
                            Layout.fillWidth: true
                            text: {
                                switch (root.adapter?.state) {
                                case BluetoothAdapterState.Enabled: return "On";
                                case BluetoothAdapterState.Disabled: return "Off";
                                case BluetoothAdapterState.Enabling: return "Turning on…";
                                case BluetoothAdapterState.Disabling: return "Turning off…";
                                case BluetoothAdapterState.Blocked: return "Bluetooth is blocked.";
                                default: return "No Bluetooth adapter available.";
                                }
                            }
                        }
                    }

                    NetworkUi.Action {
                        visible: root.adapter !== null
                        enabled: root.canToggle
                        text: root.adapter?.enabled ? "Turn off" : "Turn on"
                        onClicked: root.adapter.enabled = !root.powered
                    }
                }

                NetworkUi.Action {
                    text: "Pair new device…"
                    enabled: !checkManager.running
                    onClicked: checkManager.running = true
                }
                NetworkUi.Label {
                    Layout.fillWidth: true
                    visible: root.managerMissing
                    text: "Blueman is not installed. On Arch, run: sudo pacman -S blueman"
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: Settings.px(560)
            spacing: Settings.px(8)
            visible: root.adapter !== null

            NetworkUi.Heading { text: "Paired devices" }

            NetworkUi.Surface {
                Layout.fillWidth: true

                NetworkUi.Label {
                    Layout.fillWidth: true
                    visible: root.pairedDevices.length === 0
                    text: root.powered ? "No paired devices." : "Turn on Bluetooth to view paired devices."
                }

                Repeater {
                    model: root.pairedDevices

                    RowLayout {
                        id: deviceRow
                        required property BluetoothDevice modelData
                        readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
                            || modelData.state === BluetoothDeviceState.Disconnecting
                        Layout.fillWidth: true

                        NetworkUi.StatusIcon {
                            text: deviceRow.modelData.connected ? "\uE1A8" : "\uE1A7"
                            highlighted: deviceRow.modelData.connected
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Settings.px(2)

                            NetworkUi.Title {
                                Layout.fillWidth: true
                                text: deviceRow.modelData.name || deviceRow.modelData.address || "Unknown device"
                            }
                            NetworkUi.Label {
                                Layout.fillWidth: true
                                text: {
                                    const device = deviceRow.modelData;
                                    if (device.state === BluetoothDeviceState.Connecting) return "Connecting…";
                                    if (device.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…";
                                    if (device.connected) return "Connected";
                                    return device.blocked ? "Blocked" : "Disconnected";
                                }
                            }
                        }

                        NetworkUi.Action {
                            text: deviceRow.modelData.connected ? "Disconnect" : "Connect"
                            enabled: root.powered && !deviceRow.busy
                                && (deviceRow.modelData.connected || !deviceRow.modelData.blocked)
                            onClicked: deviceRow.modelData.connected = !deviceRow.modelData.connected
                        }
                    }
                }
            }
        }
    }
}
