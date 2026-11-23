import QtQuick
import QtQuick.Controls.Basic
import qs.Settings
import qs.Theme

Slider {
    id: root

    property bool muted: false
    from: 0
    to: 1

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: Settings.px(4)
        radius: height / 2
        color: Theme.border

        Rectangle {
            width: parent.width * root.visualPosition
            height: parent.height
            radius: parent.radius
            color: root.enabled && !root.muted ? Theme.accent : Theme.textMuted
        }
    }

    handle: Rectangle {
        implicitWidth: Settings.px(9)
        implicitHeight: implicitWidth
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        radius: width / 2
        color: root.enabled && !root.muted ? Theme.accent : Theme.textMuted
        border.width: root.activeFocus ? 1 : 0
        border.color: Theme.textPrimary
    }
}
