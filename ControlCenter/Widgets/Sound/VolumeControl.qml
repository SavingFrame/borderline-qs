import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Settings
import qs.Theme

RowLayout {
    id: root

    required property PwNode node
    required property string title
    property Component titleControl
    property bool microphone: false
    readonly property PwNodeAudio audio: node?.ready ? node.audio : null
    readonly property int labelWidth: Settings.px(224)

    spacing: Settings.px(8)

    Loader {
        Layout.fillWidth: true
        Layout.preferredWidth: root.labelWidth
        Layout.minimumWidth: 0
        visible: sourceComponent !== null
        sourceComponent: root.titleControl ?? null
    }

    Text {
        Layout.fillWidth: true
        Layout.preferredWidth: root.labelWidth
        Layout.minimumWidth: 0
        visible: !root.titleControl
        text: root.title
        color: Theme.textPrimary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(14)
        elide: Text.ElideRight
    }

    LevelSlider {
        Layout.fillWidth: true
        Layout.minimumWidth: Settings.px(32)
        Layout.preferredWidth: Settings.px(168)
        Layout.maximumWidth: Settings.px(180)
        enabled: root.audio !== null
        muted: root.audio?.muted ?? false
        value: root.audio?.volume ?? 0
        onMoved: {
            if (root.audio)
                root.audio.volume = value;
        }
        Accessible.name: root.title + " volume"
    }

    Text {
        Layout.preferredWidth: Settings.px(42)
        horizontalAlignment: Text.AlignRight
        text: root.audio ? Math.round(root.audio.volume * 100) + "%" : "N/A"
        color: Theme.textMuted
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(13)
        font.features: { "tnum": 1 }
    }

    SoundButton {
        actionName: (root.audio?.muted ? "Unmute " : "Mute ") + root.title
        glyph: root.microphone ? (root.audio?.muted ? "\uE02B" : "\uE029") : (root.audio?.muted ? "\uE04F" : "\uE050")
        enabled: root.audio !== null
        onClicked: {
            if (root.audio)
                root.audio.muted = !root.audio.muted;
        }
    }
}
