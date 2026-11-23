import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Settings
import qs.Theme

ColumnLayout {
    id: root

    readonly property list<PwNode> playbackStreams: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioOutStream)

    PwObjectTracker {
        objects: root.visible ? [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, ...root.playbackStreams].filter(node => node != null) : []
    }

    spacing: Settings.px(8)

    Heading { text: "Audio Devices" }

    AudioDeviceControl {
        Layout.fillWidth: true
        microphone: false
    }

    AudioDeviceControl {
        Layout.fillWidth: true
        microphone: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.topMargin: Settings.px(6)
        Layout.bottomMargin: Settings.px(6)
        color: Theme.barOutline
    }

    Heading { text: "Application Volumes" }

    Text {
        Layout.fillWidth: true
        visible: root.playbackStreams.length === 0
        text: "No active playback streams"
        color: Theme.textMuted
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(13)
        elide: Text.ElideRight
    }

    Repeater {
        model: root.playbackStreams

        VolumeControl {
            required property PwNode modelData
            Layout.fillWidth: true
            node: modelData
            title: node.properties["application.name"] || node.description || node.name || "Playback stream"
        }
    }

    component Heading: Text {
        Layout.fillWidth: true
        color: Theme.textPrimary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(17)
        font.bold: true
        elide: Text.ElideRight
    }
}
