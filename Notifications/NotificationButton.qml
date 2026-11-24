import QtQuick
import QtQuick.Controls.Basic as Basic
import qs.Settings
import qs.Theme

Basic.Button {
    id: root

    hoverEnabled: true
    padding: Settings.px(6)
    leftPadding: Settings.px(10)
    rightPadding: Settings.px(10)

    contentItem: Text {
        text: root.text
        textFormat: Text.PlainText
        color: Theme.textPrimary
        opacity: root.enabled ? 1 : 0.45
        font: root.font
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    font.family: Settings.fontFamily
    font.pixelSize: Settings.px(12)

    background: Rectangle {
        radius: Settings.px(7)
        color: root.hovered || root.down ? Theme.surfaceHover : Theme.surface
        border.width: 1
        border.color: root.visualFocus ? Theme.accent : Theme.barOutline
    }
}
