pragma Singleton

import Quickshell
import QtQuick

// In another QML file, add `import qs.Theme`, then use a binding
// like `color: Theme.surface` on the bar's Rectangle.
Singleton {
    // Colors: pick a name based on what the element does.
    readonly property color background: "#111827" // Behind panels or popups. Keep PanelWindow transparent if the bar has rounded corners.
    readonly property color surface: "#1F2937" // Fill for the bar, menus, and cards.
    readonly property color surfaceHover: "#374151" // Fill for a hovered button or menu item.
    readonly property color border: "#4B5563" // Optional outlines and dividers.
    readonly property color textPrimary: "#F9FAFB" // Clock, titles, and icons users should notice first.
    readonly property color textMuted: "#CBD5E1" // Secondary labels and inactive icons.
    readonly property color accent: "#93C5FD" // Focus rings, selected items, or the active workspace.
    readonly property color danger: "#FCA5A5" // Errors and warnings like critically low battery.

}
