import QtQuick
import Quickshell.Networking
import qs.Settings
import qs.Theme

Text {
    id: root

    readonly property var devices: Networking.devices
    readonly property var wifi_device: {
        const all = Networking.devices.values;
        return all.find(d => d.type == DeviceType.Wifi && d.connected) ?? all.find(d => d.type == DeviceType.Wifi) ?? null;
    }
    readonly property var eth_device: {
        const all = Networking.devices.values;
        return all.find(d => d.type == DeviceType.Wired && d.connected) ?? all.find(d => d.type == DeviceType.Wired) ?? null;
    }

    readonly property bool processing: wifi_device?.state == ConnectionState.Connecting || wifi_device?.state == ConnectionState.Disconnecting || eth_device?.state == ConnectionState.Connecting || eth_device?.state == ConnectionState.Disconnecting
    // readonly property bool processing: true

    Component.onCompleted: console.log("Wi-Fi devices:", wifi_device, "eth device", eth_device)

    text: {
        if (processing) {
            return "\uE9D0";
        } else if (eth_device?.connected) {
            return "\ueb2f";
        } else if (wifi_device?.connected) {
            const network = wifi_device.networks.values.find(n => n.connected);
            if (!network) {
                return "\uE63E"; // wifi, strength unknown
            } else if (network.signalStrength >= 0.67) {
                return "\uE63E"; // wifi, strong
            } else if (network.signalStrength >= 0.34) {
                return "\uE4D9"; // wifi_2_bar
            } else {
                return "\uE4CA"; // wifi_1_bar
            }
        } else {
            return wifi_device ? "\uE648" : "\uE16F"; // wifi_off or link_off
        }
    }

    // Animate processing icon
    NumberAnimation on rotation {
        from: 0
        to: 360
        duration: 900
        loops: Animation.Infinite
        running: root.processing
        onRunningChanged: if (!running)
            root.rotation = 0
    }

    font.pixelSize: Settings.px(Settings.iconSize)
    font.family: "Material Symbols Rounded"
    color: Theme.textPrimary
}
