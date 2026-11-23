import QtQuick
import QtQuick.Controls.Basic
import qs.Settings
import qs.Theme

ComboBox {
    id: root

    property string caption: ""
    readonly property bool quiet: caption.length > 0

    hoverEnabled: true
    implicitHeight: Settings.px(quiet ? 36 : 27)
    leftPadding: quiet ? 0 : Settings.px(9)
    rightPadding: Settings.px(19)
    topPadding: 0
    bottomPadding: 0
    font.family: Settings.fontFamily
    font.pixelSize: Settings.px(13)
    palette.button: Theme.surfaceHover
    palette.buttonText: Theme.textPrimary
    palette.window: Theme.surface
    palette.base: Theme.surface
    palette.text: Theme.textPrimary
    palette.highlight: Theme.workspaceOutline
    palette.highlightedText: Theme.textPrimary
    popup.width: Math.max(width, Settings.px(quiet ? 260 : 112))

    background: Rectangle {
        radius: height / 2
        color: root.down || root.hovered ? Theme.surfaceHover : root.quiet ? "transparent" : Theme.surface
        border.width: !root.quiet || root.activeFocus ? 1 : 0
        border.color: root.activeFocus ? Theme.accent : Theme.barOutline
    }

    contentItem: Item {
        implicitWidth: selection.implicitWidth
        implicitHeight: labels.implicitHeight

        Column {
            id: labels
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                visible: root.quiet
                text: root.caption
                font.family: Settings.fontFamily
                font.pixelSize: Settings.px(10)
                color: Theme.textMuted
            }

            Text {
                id: selection
                width: parent.width
                text: root.displayText
                font: root.font
                elide: Text.ElideRight
                color: Theme.textPrimary
            }
        }
    }

    indicator: Text {
        x: root.width - width - Settings.px(5)
        y: (root.height - height) / 2
        text: "\uE5CF"
        font.family: "Material Symbols Rounded"
        font.pixelSize: Settings.px(14)
        color: root.enabled ? Theme.textMuted : Theme.barOutline
    }
}
