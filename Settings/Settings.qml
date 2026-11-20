pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property int barSpacing: 6
    readonly property int barHeight: 35
    readonly property real barWidthRatio: 0.4
    readonly property string clockFormat: "HH:mm:ss"

    readonly property real uiScale: 1.25

    function px(base: real): int {
        return Math.round(base * uiScale);
    }
}
