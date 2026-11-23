import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.ControlCenter.Widgets.Sound
import qs.Media
import qs.Settings
import qs.Theme

Rectangle {
    id: root

    property string selectedPlayerName: ""
    readonly property int inset: Settings.px(14)
    readonly property list<MprisPlayer> players: Mpris.players.values
    readonly property int selectedPlayerIndex: players.findIndex(player => player.dbusName === selectedPlayerName)
    readonly property MprisPlayer player: {
        if (selectedPlayerIndex >= 0)
            return players[selectedPlayerIndex];
        return players.find(player => player.isPlaying)
            ?? players.find(player => player.playbackState === MprisPlaybackState.Paused)
            ?? players[0] ?? null;
    }

    implicitWidth: Settings.px(290)
    implicitHeight: content.implicitHeight + 2 * inset
    radius: Settings.px(16)
    border.width: 1
    border.color: Theme.barOutline
    gradient: Gradient {
        GradientStop { position: 0; color: Qt.tint(Theme.surface, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)) }
        GradientStop { position: 1; color: Theme.surface }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: root.inset
        spacing: Settings.px(10)

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "NOW PLAYING"
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.px(10)
                font.letterSpacing: Settings.px(1)
                font.bold: true
                elide: Text.ElideRight
            }

            SoundSelector {
                Layout.preferredWidth: Settings.px(94)
                model: ["Auto", ...root.players.map(player => player.identity || player.dbusName)]
                currentIndex: root.selectedPlayerIndex + 1
                enabled: root.players.length > 0
                Accessible.name: "Media player"
                onActivated: index => root.selectedPlayerName = index > 0 ? root.players[index - 1]?.dbusName ?? "" : ""
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Settings.px(10)

            ClippingRectangle {
                Layout.preferredWidth: Settings.px(88)
                Layout.preferredHeight: Layout.preferredWidth
                color: Theme.background
                radius: Settings.px(10)

                Text {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    text: "\uE405"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: Settings.px(28)
                    color: Theme.textMuted
                }

                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Settings.px(3)

                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle || root.player?.identity || "No media player"
                    color: Theme.textPrimary
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.px(15)
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: [root.player?.trackArtist, root.player?.identity].filter(Boolean).join(" · ")
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.px(12)
                    elide: Text.ElideRight
                }
            }
        }

        PlaybackControls {
            Layout.fillWidth: true
            player: root.player
        }

        MediaVisualizer {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            player: root.player
            visible: player !== null
            showArtwork: false
            traceWidth: width
            traceHeight: Settings.px(23)
            traceColor: Theme.accent
        }
    }
}
