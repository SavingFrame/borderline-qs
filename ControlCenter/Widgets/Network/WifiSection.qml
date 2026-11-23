pragma ComponentBehavior: Bound

import Quickshell.Networking
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.Settings
import qs.Theme

QtObject {
    id: root

    required property bool active
    readonly property list<WifiDevice> wifiDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wifi && device.nmManaged)
    readonly property WifiDevice wifiDevice: wifiDevices.find(device => device.connected) ?? wifiDevices[0] ?? null
    readonly property bool wifiOn: wifiDevice !== null && Networking.wifiHardwareEnabled && Networking.wifiEnabled
    readonly property list<WifiNetwork> wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
    readonly property WifiNetwork currentNetwork: wifiNetworks.find(network => network.connected) ?? null
    readonly property list<WifiNetwork> nearbyNetworks: Array.from(wifiNetworks)
        .filter(network => !network.connected && network.name !== "")
        .sort((a, b) => a.name.localeCompare(b.name))

    property WifiNetwork passwordNetwork: null
    property string passwordDraft: ""
    readonly property bool editingPassword: active && wifiOn && passwordNetwork !== null
    property WifiNetwork optionsNetwork: null

    signal actionRequested()
    signal connectionFailed(string name, int reason)
    signal revealItem(Item item)

    // These two views share state but live in different page columns.
    readonly property Component connectionCard: Component {
        NetworkUi.Surface {
            RowLayout {
                Layout.fillWidth: true
                NetworkUi.StatusIcon {
                    text: root.wifiOn ? "\uE63E" : "\uE648"
                    highlighted: root.wifiOn
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Settings.px(2)
                    NetworkUi.Title { Layout.fillWidth: true; text: "Wi-Fi" }
                    NetworkUi.Label {
                        Layout.fillWidth: true
                        visible: !root.wifiOn || !root.currentNetwork
                        text: !root.wifiDevice ? "No Wi-Fi adapter" : !Networking.wifiHardwareEnabled ? "Blocked by hardware switch"
                            : root.wifiOn ? "Not connected" : "Off"
                    }
                }
                Basic.Switch {
                    id: radio
                    Accessible.name: "Wi-Fi"
                    visible: root.wifiDevice !== null
                    enabled: Networking.wifiHardwareEnabled
                    checked: Networking.wifiEnabled
                    padding: Settings.px(3)
                    indicator: Rectangle {
                        x: radio.leftPadding
                        y: (radio.height - height) / 2
                        implicitWidth: Settings.px(40)
                        implicitHeight: Settings.px(22)
                        radius: height / 2
                        color: radio.checked ? Theme.accent : Theme.background
                        opacity: radio.enabled ? 1 : 0.5
                        border.color: radio.visualFocus ? Theme.textPrimary : Theme.barOutline
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: radio.checked ? parent.width - width - Settings.px(3) : Settings.px(3)
                            width: Settings.px(16)
                            height: width
                            radius: width / 2
                            color: radio.checked ? Theme.background : Theme.textMuted
                        }
                    }
                    onClicked: {
                        root.actionRequested();
                        Networking.wifiEnabled = checked;
                        checked = Qt.binding(() => Networking.wifiEnabled);
                    }
                }
            }

            Loader {
                Layout.fillWidth: true
                active: root.wifiOn && root.currentNetwork !== null
                visible: active
                sourceComponent: WifiNetworkRow {
                    section: root
                    network: root.currentNetwork
                }
            }
        }
    }

    readonly property Component nearbyList: Component {
        ColumnLayout {
            spacing: Settings.px(8)

            NetworkUi.Heading { text: "Nearby Wi-Fi" }

            NetworkUi.Surface {
                Layout.fillWidth: true
                visible: !root.wifiOn || root.nearbyNetworks.length === 0

                NetworkUi.Label {
                    Layout.fillWidth: true
                    text: {
                        if (!root.wifiDevice) return "No Wi-Fi adapter available.";
                        if (!Networking.wifiHardwareEnabled) return "Wi-Fi is blocked by the hardware switch.";
                        if (!root.wifiOn) return "Turn on Wi-Fi to find nearby networks.";
                        return root.currentNetwork ? "No other networks found yet." : "Looking for networks…";
                    }
                }
            }

            NetworkUi.Surface {
                Layout.fillWidth: true
                visible: root.wifiOn && root.nearbyNetworks.length > 0

                Repeater {
                    model: root.wifiOn ? root.nearbyNetworks : []

                    WifiNetworkRow {
                        required property WifiNetwork modelData
                        section: root
                        Layout.fillWidth: true
                        network: modelData
                    }
                }
            }
        }
    }

    onActiveChanged: {
        if (!active) {
            cancelPassword();
            optionsNetwork = null;
        }
    }
    onWifiDeviceChanged: cancelPassword()
    onWifiOnChanged: {
        if (!wifiOn) {
            cancelPassword();
            optionsNetwork = null;
        }
    }
    onEditingPasswordChanged: if (!editingPassword) passwordDraft = ""

    function cancelPassword(): void {
        passwordNetwork = null;
        passwordDraft = "";
    }

    function needsPassword(network: WifiNetwork): bool {
        return network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae;
    }

    function openNetwork(network: WifiNetwork): bool {
        return network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe;
    }

    function join(network: WifiNetwork): void {
        actionRequested();
        cancelPassword();
        if (network.known || openNetwork(network))
            network.connect();
        else if (needsPassword(network))
            passwordNetwork = network;
    }

    function submitPassword(): void {
        if (!editingPassword || !passwordDraft.length)
            return;
        passwordNetwork.connectWithPsk(passwordDraft);
        cancelPassword();
    }

    function busy(device: NetworkDevice): bool {
        return device?.state === ConnectionState.Connecting || device?.state === ConnectionState.Disconnecting;
    }

    readonly property Binding scanner: Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: true
        when: root.active && root.wifiOn
    }
}
