import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string defaultSound: "--file=" + Quickshell.shellDir + "/Notifications/chime.wav"
    property var pending: []
    property bool testing: false

    function localPath(value): string {
        if (typeof value !== "string")
            return "";
        if (value.startsWith("file:///")) {
            try {
                value = decodeURIComponent(value.slice(7));
            } catch (_) {
                return "";
            }
        }
        return value.startsWith("/") && !value.startsWith("//") && !value.includes("\u0000") ? value : "";
    }

    function play(hints, test): void {
        const suppress = hints?.["suppress-sound"];
        if (player.running || pending.length || (!test && (cooldown.running || suppress === true || suppress === 1)))
            return;

        const options = [];
        const path = localPath(hints?.["sound-file"]);
        const name = hints?.["sound-name"];
        if (path)
            options.push("--file=" + path);
        if (typeof name === "string" && /^[a-zA-Z0-9_-]{1,128}$/.test(name))
            options.push("--id=" + name);
        options.push(defaultSound);
        testing = test;
        if (!test)
            cooldown.restart();
        pending = options;
        playNext();
    }

    function playNext(): void {
        if (!pending.length)
            return;
        const option = pending[0];
        pending = pending.slice(1);
        player.exec(["timeout", "--kill-after=1s", "8s", "canberra-gtk-play", option]);
    }

    function cancelAutomatic(): void {
        if (testing)
            return;
        pending = [];
        if (player.running)
            player.running = false;
    }

    Timer { id: cooldown; interval: 400 }

    Process {
        id: player
        onExited: (code, status) => {
            if (code === 0 && status === 0 || code === 127)
                root.pending = [];
            else if (root.pending.length)
                Qt.callLater(root.playNext);
        }
    }
}
