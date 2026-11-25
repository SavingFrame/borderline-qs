pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // General
    readonly property string fontFamily: "Adwaita Sans"
    readonly property real uiScale: 1.25

    // Bar
    readonly property int barSpacing: 6
    readonly property int barHeight: 45
    readonly property real barWidthRatio: 0.4
    readonly property int barTopMargin: 10 // Pixels, not scaled by uiScale.
    readonly property int barCornerRadius: 12 // Pixels, shared with the Control Center.
    readonly property string barDateFormat: "ddd d"
    readonly property string clockFormat: "HH:mm:ss"
    readonly property int iconSize: 18
    readonly property bool barVisualizerEnabled: true
    readonly property list<string> hiddenTrayItemIds: ["blueman"]

    // Notifications
    readonly property int notificationToastTimeoutMs: 7000 // Used when the app requests no positive timeout.
    readonly property int notificationMaxToasts: 3 // Set to 0 to disable popups.
    readonly property int notificationToastWidth: 340 // Before UI scaling.
    readonly property string notificationFallbackSound: "Notifications/chime.wav" // Absolute or config-relative path.
    readonly property real notificationVolumeDb: -10

    // On-screen display
    readonly property int osdTimeoutMs: 1200
    readonly property list<string> mediaOsdIgnoredPlayers: ["org.mpris.MediaPlayer2.TelegramDesktop"]

    // Hardware
    readonly property string brightnessMonitorSerial: "" // Empty selects DDC display 1 unless overridden by DDC_MONITOR_SERIAL.
    readonly property real brightnessStepPercent: 5
    readonly property int nightLightTemperatureK: 4000

    // Control Center (before UI scaling)
    readonly property int controlCenterContentMaxWidth: 1040
    readonly property int controlCenterDefaultHeight: 380
    readonly property int controlCenterHomeHeight: 460
    readonly property int controlCenterCalendarHeight: 576
    readonly property int controlCenterNotificationsHeight: 576

    // Calendar
    readonly property int googleCalendarRefreshIntervalMs: 300000

    function px(base: real): int {
        return Math.round(base * uiScale);
    }

    function human_layout(layout: string): string {
        return {
            "English (US)": "US",
            "Ukrainian": "UA"
        }[layout] ?? layout;
    }
}
