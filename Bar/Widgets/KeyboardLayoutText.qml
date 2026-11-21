pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import qs.Settings

Singleton {
    id: root
    property string layout
    Process {
        id: readLayout

        running: true
        command: ["hyprctl", "-j", "devices"]

        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim();
                if (!text) {
                    return "";
                }
                const keyboard = JSON.parse(text).keyboards.find(v => v.main);
                root.layout = Settings.human_layout(keyboard?.active_keymap ?? "");
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "activelayout") {
                readLayout.running = true;
                root.layout = Settings.human_layout(event.data.split(",")[1]);
            }
        }
    }
}
