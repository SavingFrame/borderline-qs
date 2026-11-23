import QtQuick
import QtQuick.Controls.Basic
import qs.Settings
import qs.Theme

Button {
    id: root
    required property string glyph
    required property string actionName
    property bool emphasized: false

    implicitWidth: Settings.px(emphasized ? 34 : 28)
    implicitHeight: implicitWidth
    padding: 0
    hoverEnabled: true
    Accessible.name: actionName

    background: Rectangle {
        radius: height / 2
        color: root.emphasized && root.enabled
            ? (root.down || root.hovered ? Theme.textPrimary : Theme.accent)
            : (root.down || root.hovered ? Theme.surfaceHover : Theme.surface)
        border.color: root.activeFocus ? Theme.textPrimary : Theme.barOutline
        border.width: root.activeFocus ? 1 : 0
    }

    contentItem: Text {
        text: root.glyph
        font.family: "Material Symbols Rounded"
        font.pixelSize: Settings.px(root.emphasized ? 19 : 16)
        color: root.emphasized && root.enabled ? Theme.background : Theme.textPrimary
        opacity: root.enabled ? 1 : 0.45
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
