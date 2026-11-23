import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.ControlCenter.Widgets.Sound
import qs.Settings

RowLayout {
    id: root

    required property MprisPlayer player

    spacing: Settings.px(5)
    visible: root.player !== null

    SoundButton {
        actionName: "Previous track"
        glyph: "\uE045"
        enabled: root.player?.canGoPrevious ?? false
        onClicked: root.player?.previous()
    }

    SoundButton {
        actionName: root.player?.isPlaying ? "Pause" : "Play"
        glyph: root.player?.isPlaying ? "\uE034" : "\uE037"
        emphasized: true
        enabled: root.player?.canTogglePlaying ?? false
        onClicked: root.player?.togglePlaying()
    }

    SoundButton {
        actionName: "Next track"
        glyph: "\uE044"
        enabled: root.player?.canGoNext ?? false
        onClicked: root.player?.next()
    }
}
