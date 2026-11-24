import QtQuick
import Quickshell
import qs.Theme
import qs.Settings

Row {
    id: root

    property bool showDate: false
    spacing: Settings.px(Settings.barSpacing)

    Text {
        visible: root.showDate
        text: Qt.locale().toString(clock.date, "ddd d")
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        color: Theme.textMuted
    }

    Text {
        text: Qt.formatDateTime(clock.date, Settings.clockFormat)
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        font.features: {
            "tnum": 1
        }
        color: Theme.textPrimary
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
