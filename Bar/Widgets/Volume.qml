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

        font.pixelSize: Settings.px(Settings.iconSize)
        font.family: "Material Symbols Rounded"
        color: Theme.textPrimary
        anchors.verticalCenter: parent.verticalCenter
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
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.textPrimary
        font.pixelSize: Settings.px(14)
        font.family: Settings.fontFamily
        font.features: {
            "tnum": 1
        }
        text: {
            const sink = Pipewire.defaultAudioSink;
            return sink ? `${Math.round(sink.audio.volume * 100)}%` : "";
        }
    }
}
