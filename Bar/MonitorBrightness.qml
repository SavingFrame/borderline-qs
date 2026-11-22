import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string monitorSerial: Quickshell.env("DDC_MONITOR_SERIAL") ?? ""
    signal preview(real level)

    property int maximum: 0
    property int desired: 0
    property int pendingSteps: 0
    property bool needsWrite: false
    property bool showRequested: false

    function adjust(steps: int) {
        if (maximum === 0) {
            pendingSteps += steps;
        } else {
            const step = Math.max(1, Math.round(maximum * 0.05));
            desired = Math.max(0, Math.min(maximum, desired + steps * step));
            needsWrite = true;
            preview(desired / maximum);
        }
        Qt.callLater(pump);
    }

    function show() {
        showRequested = true;
        pump();
    }

    function pump() {
        if (ddc.running)
            return;

        const target = monitorSerial ? ["--sn", monitorSerial] : ["--display", "1"];
        const command = ["timeout", "-k", "1s", "5s", "ddcutil", ...target];
        if (needsWrite) {
            needsWrite = false;
            ddc.sent = desired;
            ddc.exec([...command, "--noverify", "setvcp", "10", String(desired)]);
        } else if (maximum === 0 || showRequested) {
            ddc.sent = -1;
            ddc.exec([...command, "--terse", "getvcp", "10"]);
        }
    }

    Component.onCompleted: pump()

    Process {
        id: ddc
        property int sent: -1 // A negative value means this command is a read.
        environment: ({
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            id: output
        }

        onExited: function (exitCode, exitStatus) {
            const ok = exitCode === 0 && exitStatus === 0;
            if (ddc.sent >= 0) {
                // Keep only the latest target. Don't retry failed writes on a loop.
                if (root.desired === ddc.sent)
                    root.needsWrite = false;
                if (!ok)
                    console.warn("Brightness write failed (exit", exitCode + ")");
                Qt.callLater(root.pump);
                return;
            }

            const showLevel = root.showRequested;
            root.showRequested = false;
            const steps = root.pendingSteps;
            root.pendingSteps = 0;
            const reading = ok && /^VCP\s+10\s+C\s+(\d+)\s+(\d+)\s*$/.exec(output.text);
            if (!reading || Number(reading[2]) === 0) {
                console.warn("Could not read monitor brightness (exit", exitCode + ")");
                return;
            }

            root.maximum = Number(reading[2]);
            // An adjustment made during a read takes priority over the readback.
            if (root.needsWrite) {
                root.desired = Math.min(root.desired, root.maximum);
                Qt.callLater(root.pump);
                return;
            }

            root.desired = Math.min(Number(reading[1]), root.maximum);
            if (steps !== 0)
                root.adjust(steps);
            else if (showLevel)
                root.preview(root.desired / root.maximum);
        }
    }
}
