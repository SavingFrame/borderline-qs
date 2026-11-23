import QtQuick
import Quickshell.Services.Pipewire

VolumeControl {
    id: root

    readonly property list<PwNode> devices: Pipewire.nodes.values.filter(node => node.type === (root.microphone ? PwNodeType.AudioSource : PwNodeType.AudioSink) || node.type === PwNodeType.AudioDuplex)

    title: microphone ? "Input" : "Output"
    node: (microphone ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink) ?? null

    titleControl: SoundSelector {
        caption: root.title
        model: root.devices.map(node => node.description || node.nickname || node.name)
        currentIndex: root.devices.indexOf(root.node)
        displayText: currentIndex >= 0 ? currentText : (root.node?.description || root.node?.name || "No device")
        enabled: count > 0
        Accessible.name: root.title + " device"
        onActivated: index => {
            const node = root.devices[index];
            if (!node)
                return;

            if (root.microphone)
                Pipewire.preferredDefaultAudioSource = node;
            else
                Pipewire.preferredDefaultAudioSink = node;
        }
    }
}
