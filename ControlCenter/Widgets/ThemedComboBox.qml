pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import qs.Settings
import qs.Theme

ComboBox {
    id: root

    hoverEnabled: true
    palette.buttonText: Theme.textPrimary
    palette.dark: Theme.textMuted
    palette.mid: Theme.border
    palette.highlight: Theme.accent

    background: Rectangle {
        radius: Settings.px(6)
        color: root.down ? Theme.border : root.hovered ? Theme.surfaceHover : Theme.background
        border.width: 1
        border.color: root.activeFocus ? Theme.accent : Theme.barOutline
    }

    popup.background: Rectangle {
        color: Theme.surface
    }

    delegate: ItemDelegate {
        id: row

        required property var model
        required property int index

        width: ListView.view.width
        text: model[root.textRole]
        highlighted: root.highlightedIndex === index
        hoverEnabled: root.hoverEnabled
        horizontalPadding: Settings.px(9)
        verticalPadding: Settings.px(6)
        font.family: root.font.family
        font.pixelSize: root.font.pixelSize
        font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
        palette.text: Theme.textPrimary
        palette.highlightedText: Theme.textPrimary

        background: Rectangle {
            implicitHeight: Settings.px(28)
            color: row.down ? Theme.border : row.highlighted || row.hovered ? Theme.surfaceHover : "transparent"
            border.width: row.highlighted ? 1 : 0
            border.color: Theme.accent
        }
    }
}
