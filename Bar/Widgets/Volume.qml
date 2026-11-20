import Quickshell
import QtQuick
import Quickshell.Services.Pipewire
import qs.Settings
import qs.Theme

Item {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
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
        font.pixelSize: Settings.px(16)
        font.family: "Material Symbols Rounded"
        color: Theme.textPrimary
    }
}
