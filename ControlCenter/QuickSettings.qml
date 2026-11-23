pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool caffeine: false
    readonly property alias nightLight: nightLight
    readonly property alias dnd: dnd
    readonly property bool powerAvailable: power.available

    function refresh() {
        nightLight.refresh();
        dnd.refresh();
        power.refresh();
    }

    component CommandSetting: Process {
        id: setting

        required property list<string> query
        required property var decode
        property var change: null
        property var state: null
        readonly property bool available: state !== null
        property bool changing: false

        function refresh() {
            if (!running) {
                changing = false;
                exec(["timeout", "2s", ...query]);
            }
        }

        function toggle() {
            if (running || changing || !available || !change)
                return;
            changing = true;
            exec(["timeout", "2s", ...change(!state)]);
        }

        stdout: StdioCollector {
            id: result
        }
        onExited: (code, status) => {
            if (changing)
                Qt.callLater(setting.refresh);
            else
                state = code === 0 && status === 0 ? decode(result.text.trim()) : null;
        }
    }

    CommandSetting {
        id: nightLight
        query: ["hyprctl", "hyprsunset", "temperature"]
        decode: value => /^\d+$/.test(value) ? Number(value) < 6500 : null
        change: enabled => enabled ? ["hyprctl", "hyprsunset", "temperature", "4000"] : ["hyprctl", "hyprsunset", "identity"]
    }

    CommandSetting {
        id: dnd
        query: ["noctalia", "msg", "notification-dnd-status"]
        decode: value => value === "on" ? true : value === "off" ? false : null
        change: enabled => ["noctalia", "msg", "notification-dnd-set", enabled ? "on" : "off"]
    }

    CommandSetting {
        id: power
        query: ["powerprofilesctl", "get"]
        decode: value => ["power-saver", "balanced", "performance"].includes(value) ? true : null
    }
}
