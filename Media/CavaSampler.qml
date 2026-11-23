pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int consumerCount: 0
    property var levels: []

    Process {
        command: ["cava", "-p", Quickshell.shellPath("extra/cava.ini")]
        running: root.consumerCount > 0
        onExited: root.levels = []

        stdout: SplitParser {
            onRead: line => {
                if (root.consumerCount > 0)
                    root.levels = line.trim().split(";").filter(value => value !== "").map(value => Math.min(1, Math.max(0, Number(value) / 100 || 0)));
            }
        }
    }
}
