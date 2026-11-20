import Quickshell
import QtQuick
import Quickshell.Bluetooth
import qs.Settings
import qs.Theme

Text {
    id: root
    visible: adapter != null

    font.pixelSize: Settings.px(16)
    font.family: "Material Symbols Rounded"
    color: Theme.textPrimary

    readonly property var adapter: Bluetooth.defaultAdapter

    text: {
        const enabled = adapter.enabled;
        if (enabled) {
            return "\uE1A7";
        } else {
            return "\uE1A9";
        }
    }
}
