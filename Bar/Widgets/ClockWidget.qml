import QtQuick
import Quickshell
import qs.Bar
import qs.Theme

Text {
    text: Qt.formatDateTime(clock.date, "HH:mm:ss ")

    // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy");
    color: Theme.textPrimary

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
