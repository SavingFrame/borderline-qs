import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

    IpcHandler {
        target: "controlCenter"

        function toggleNotifications(): void {
            const screenName = Hyprland.focusedMonitor?.name;
            const bars = barWindows.instances;
            const bar = bars.find(window => window.screen?.name === screenName) ?? bars[0];
            bar?.toggleNotifications();
        }
    }

    Variants {
        id: barWindows
        model: Quickshell.screens
        BarWindow {
            osdController: barOsdController
            notificationService: root.notificationService
        }
    }
}
