pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property int barSpacing: 6
    readonly property int barHeight: 40
    readonly property real barWidthRatio: 0.6
    readonly property string clockFormat: "HH:mm:ss"
}
