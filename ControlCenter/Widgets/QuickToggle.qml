import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.Settings
import qs.Theme

Basic.Button {
    id: root

    required property string glyph
    property string unavailableHint: "Unavailable"

    implicitHeight: Settings.px(52)
    padding: Settings.px(5)
    hoverEnabled: true
    Accessible.name: text
    Accessible.description: enabled ? "" : unavailableHint

    Basic.ToolTip.visible: hover.hovered && !root.enabled
    Basic.ToolTip.text: unavailableHint
    Basic.ToolTip.delay: 450

    HoverHandler {
        id: hover
    }

    background: Rectangle {
        radius: Settings.px(12)
        color: root.highlighted && root.enabled ? (root.down || root.hovered ? Theme.textPrimary : Theme.accent)
            : (root.down || root.hovered ? Theme.surfaceHover : Theme.surface)
        border.width: 1
        border.color: root.visualFocus ? Theme.textPrimary : Theme.barOutline
    }

    contentItem: ColumnLayout {
        spacing: Settings.px(2)

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.glyph
            font.family: "Material Symbols Rounded"
            font.pixelSize: Settings.px(18)
            color: root.highlighted && root.enabled ? Theme.background : Theme.textPrimary
            opacity: root.enabled ? 1 : 0.45
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.text
            font.family: Settings.fontFamily
            font.pixelSize: Settings.px(11)
            color: root.highlighted && root.enabled ? Theme.background : Theme.textPrimary
            opacity: root.enabled ? 1 : 0.45
        }
    }
}
