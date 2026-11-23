pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Settings
import qs.Theme

Rectangle {
    id: root

    required property string interfaceName
    required property bool active
    readonly property bool ready: active && interfaceName !== ""
    property var fields: null

    visible: ready
    color: Qt.tint(Theme.background, Qt.rgba(1, 1, 1, 0.025))
    radius: Settings.px(6)
    implicitHeight: body.implicitHeight + Settings.px(16)

    onReadyChanged: {
        if (!ready) {
            fetch.running = false;
            fields = null;
        }
    }
    onInterfaceNameChanged: {
        fields = null;
        if (ready) {
            fetch.running = false;
            refresh.restart();
        }
    }

    ColumnLayout {
        id: body
        x: Settings.px(10)
        y: Settings.px(8)
        width: Math.max(0, root.width - Settings.px(20))
        spacing: Settings.px(4)

        DetailText {
            Layout.fillWidth: true
            visible: !root.fields || Object.keys(root.fields).length === 0
            text: root.fields ? "No IP details available" : "Loading IP details…"
        }

        Repeater {
            model: root.fields && Object.keys(root.fields).length ? [
                { key: "ADDRESS", label: "IP address" },
                { key: "GATEWAY", label: "Gateway" },
                { key: "DNS", label: "DNS" }
            ] : []

            RowLayout {
                id: field
                required property var modelData
                readonly property var values: root.fields?.[modelData.key]
                Layout.fillWidth: true
                spacing: Settings.px(12)

                DetailText {
                    Layout.preferredWidth: Settings.px(62)
                    Layout.alignment: Qt.AlignTop
                    text: field.modelData.label
                }

                DetailText {
                    Layout.fillWidth: true
                    text: field.values?.join(", ") ?? "Not set"
                    color: field.values ? Theme.textPrimary : Theme.textMuted
                    font.features: ({ "tnum": 1 })
                }
            }
        }
    }

    Timer {
        id: refresh
        interval: 10000
        repeat: true
        triggeredOnStart: true
        running: root.ready
        onTriggered: {
            if (!fetch.running) {
                fetch.requestedInterface = root.interfaceName;
                fetch.running = true;
            }
        }
    }

    Process {
        id: fetch
        property string requestedInterface: ""
        command: ["nmcli", "--wait", "3", "--terse", "--escape", "no", "--fields",
            "IP4.ADDRESS,IP6.ADDRESS,IP4.GATEWAY,IP6.GATEWAY,IP4.DNS,IP6.DNS",
            "device", "show", fetch.requestedInterface]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.ready || root.interfaceName !== fetch.requestedInterface)
                    return;

                const fields = {};
                for (const line of text.split("\n")) {
                    const match = /^IP[46]\.(ADDRESS|GATEWAY|DNS)(?:\[\d+\])?:(.+)$/.exec(line);
                    if (match && match[2] !== "--") {
                        const key = match[1];
                        if (!fields[key])
                            fields[key] = [];
                        fields[key].push(match[2]);
                    }
                }
                root.fields = fields;
            }
        }
    }

    component DetailText: Text {
        color: Theme.textMuted
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(12)
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
    }
}
