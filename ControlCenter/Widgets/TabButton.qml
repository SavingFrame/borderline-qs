import QtQuick
import qs.Settings
import qs.Theme

Rectangle {
    id: root
    radius: height / 2
    color: selected || hover.hovered ? Theme.surfaceHover : "transparent"

    implicitWidth: content.implicitWidth + Settings.px(22)
    implicitHeight: Math.max(Settings.px(28), content.implicitHeight + Settings.px(8))

    property bool selected: false
    property bool showLabel: true
    readonly property real labeledWidth: glyph.implicitWidth + content.spacing + label.implicitWidth + Settings.px(22)
    signal clicked

    Accessible.role: Accessible.PageTab
    Accessible.name: root.text
    Accessible.selected: root.selected
    Accessible.onPressAction: root.clicked()

    required property string icon
    required property string text

    HoverHandler { id: hover }

    TapHandler {
        onTapped: root.clicked()
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Settings.px(6)

        Text {
            id: glyph
            font.pixelSize: Settings.px(Settings.iconSize)
            font.family: "Material Symbols Rounded"
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
        }
        Text {
            id: label
            visible: root.showLabel
            text: root.text
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            font.pixelSize: Settings.px(14)
            font.family: Settings.fontFamily
            font.features: {
                "tnum": 1
            }
        }
    }
}
