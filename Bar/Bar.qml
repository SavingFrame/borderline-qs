import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.BarOsd

Scope {
    id: root

    function refreshWorkspaceWindows() {
        Hyprland.refreshToplevels();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "movewindowv2" || event.name === "activewindowv2")
                Qt.callLater(root.refreshWorkspaceWindows);
        }
    }

    BarOsdController {
        id: barOsdController
    }

    Variants {
        model: Quickshell.screens
        BarWindow {
            osdController: barOsdController
        }
    }
}
