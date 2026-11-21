import QtQuick
import qs.Settings
import qs.Theme
import qs.Bar.Widgets

Row {
    id: root
    spacing: 2

    Text {
        text: "\ue312"
        font.pixelSize: Settings.px(Settings.iconSize)
        font.family: "Material Symbols Rounded"
        color: Theme.textPrimary
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.textPrimary
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        font.features: {
            "tnum": 1
        }
        text: KeyboardLayoutText.layout
    }
}
