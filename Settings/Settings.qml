pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property int barSpacing: 6
    readonly property int barHeight: 35
    readonly property real barWidthRatio: 0.4
    readonly property string clockFormat: "HH:mm:ss"
    readonly property int iconSize: 18
    readonly property string fontFamily: "Adwaita Sans"

    readonly property real uiScale: 1.25

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
