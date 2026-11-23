import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.Settings
import qs.Theme

QtObject {
    component Surface: Rectangle {
        id: surface
        default property alias content: body.data
        color: Theme.surface
        radius: Settings.px(8)
        implicitHeight: body.implicitHeight + Settings.px(16)
        ColumnLayout {
            id: body
            width: Math.max(0, surface.width - Settings.px(20))
            x: Settings.px(10)
            y: Settings.px(8)
            spacing: Settings.px(6)
        }
    }

    component Label: Text {
        color: Theme.textMuted
        textFormat: Text.PlainText
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(12)
        wrapMode: Text.Wrap
    }

    component Title: Label {
        color: Theme.textPrimary
        font.pixelSize: Settings.px(14)
        font.bold: true
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }

    component Heading: Title {
        Layout.fillWidth: true
        font.pixelSize: Settings.px(17)
    }

    component StatusIcon: Rectangle {
        id: tile
        property alias text: glyph.text
        property bool highlighted: false
        implicitWidth: Settings.px(30)
        implicitHeight: implicitWidth
        radius: Settings.px(7)
        color: highlighted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : Theme.background

        Text {
            id: glyph
            anchors.centerIn: parent
            font.family: "Material Symbols Rounded"
            font.pixelSize: Settings.px(18)
            color: tile.highlighted ? Theme.accent : Theme.textMuted
        }
    }

    component Action: Basic.Button {
        id: button
        property bool quiet: false
        implicitHeight: Settings.px(27)
        leftPadding: Settings.px(8)
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(12)
        contentItem: Text {
            text: button.text
            font: button.font
            color: button.quiet ? Theme.textMuted : Theme.textPrimary
            opacity: button.enabled ? 1 : 0.5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: Settings.px(6)
            color: button.hovered || button.down || button.visualFocus ? Theme.surfaceHover : button.quiet ? "transparent" : Theme.background
            border.color: button.visualFocus ? Theme.accent : Theme.barOutline
            border.width: button.quiet && !button.visualFocus ? 0 : 1
        }
    }
}
