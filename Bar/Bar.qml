import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.BarOsd
import qs.Notifications

Scope {
    id: root

    required property NotificationService notificationService

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
            notificationService: root.notificationService
        }
    }
}
