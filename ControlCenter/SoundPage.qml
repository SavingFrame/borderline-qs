import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.ControlCenter.Widgets.Media
import qs.ControlCenter.Widgets.Sound
import qs.Settings

Flickable {
    id: root

    required property string selectedPlayerName
    signal playerRequested(string name)

    clip: true
    contentWidth: width
    contentHeight: sections.y + sections.implicitHeight
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds

    Basic.ScrollBar.vertical: Basic.ScrollBar {}

    GridLayout {
        id: sections
        width: Math.max(0, root.width - Settings.px(8))
        columns: width >= Settings.px(650) ? 2 : 1
        columnSpacing: Settings.px(24)
        rowSpacing: Settings.px(20)

        NowPlaying {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(445)
            selectedPlayerName: root.selectedPlayerName
            onPlayerRequested: name => root.playerRequested(name)
        }

        AudioMixer {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(560)
        }
    }
}
