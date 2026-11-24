import QtQuick
import Quickshell
import qs.Theme
import qs.Settings

Row {
    id: root

    signal dateTapped()
    signal timeTapped()
    spacing: Settings.px(Settings.barSpacing)

    Text {
        text: Qt.locale().toString(clock.date, "ddd d")
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        color: Theme.textMuted

        Accessible.role: Accessible.Button
        Accessible.name: "Calendar"
        Accessible.onPressAction: root.dateTapped()

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: root.dateTapped()
        }
    }

    Text {
        text: Qt.formatDateTime(clock.date, Settings.clockFormat)
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        font.features: {
            "tnum": 1
        }
        color: Theme.textPrimary

        Accessible.role: Accessible.Button
        Accessible.name: "Home"
        Accessible.onPressAction: root.timeTapped()

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: root.timeTapped()
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
