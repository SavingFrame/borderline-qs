import QtQuick
import Quickshell
import qs.Theme
import qs.Settings

Text {
    text: Qt.formatDateTime(clock.date, Settings.clockFormat)
    font.pixelSize: Settings.px(14)
    font.family: Settings.fontFamily
    font.features: {
        "tnum": 1
    }

    // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy");
    color: Theme.textPrimary

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
