import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Theme

StackLayout {
    Text {
        text: "Sound controls"
        color: Theme.textPrimary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(16)
    }

    Text {
        text: "Network controls"
        color: Theme.textPrimary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(16)
    }
}
