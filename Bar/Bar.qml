import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import qs.BarOsd

Scope {
    id: root

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
