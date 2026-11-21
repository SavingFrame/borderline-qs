import QtQuick
import Quickshell.Services.Pipewire
import qs.Settings
import qs.Theme

Row {
    id: root
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    spacing: 2

    Text {

        text: {
            const sink = Pipewire.defaultAudioSink;
            if (!sink) {
                return "";
            } else if (sink.audio.muted) {
                return "\uE04F";
            } else if (sink.audio.volume >= 0.5) {
                return "\uE050";
            } else if (sink.audio.volume < 0.5 && sink.audio.volume > 0) {
                return "\uE04D";
            } else if (sink.audio.volume == 0) {
                return "\uE04E";
            }
            return sink.audio.volume;
        }
        font.pixelSize: Settings.px(Settings.iconSize)
        font.family: "Material Symbols Rounded"
        color: Theme.textPrimary
    }

    Text {
        text: {
            const sink = Pipewire.defaultAudioSink;
            return sink ? `${Math.round(sink.audio.volume * 100)}%` : "";
        }
        color: Theme.textPrimary
        font.pixelSize: Settings.px(14)
    }
}
