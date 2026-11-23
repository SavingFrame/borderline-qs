import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.Bar
import qs.ControlCenter.Widgets
import qs.ControlCenter.Widgets.Media
import qs.ControlCenter.Widgets.Sound
import qs.Settings
import qs.Theme

Flickable {
    id: root

    required property bool active
    required property MonitorBrightness brightness
    required property string selectedPlayerName
    signal playerRequested(string name)

    readonly property string username: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "Unknown user"
    property string hostname: ""
    property string uptime: ""
    property string hyprlandVersion: ""
    readonly property bool wifiAvailable: Networking.backend === NetworkBackendType.NetworkManager
        && Networking.wifiHardwareEnabled
        && Networking.devices.values.some(device => device.type === DeviceType.Wifi && device.nmManaged)
    readonly property BluetoothAdapter bluetooth: Bluetooth.defaultAdapter

    onActiveChanged: {
        if (active)
            brightness.refresh();
    }

    Timer {
        running: root.active
        interval: 5000
        repeat: true
        triggeredOnStart: true
        onTriggered: QuickSettings.refresh()
    }

    clip: true
    contentWidth: width
    contentHeight: sections.implicitHeight
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Basic.ScrollBar.vertical: Basic.ScrollBar {}

    PwObjectTracker {
        objects: root.active && Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    SystemClock {
        id: clock
        enabled: root.active
        precision: SystemClock.Seconds
    }

    Process {
        command: ["uname", "-n"]
        running: root.active && !root.hostname
        stdout: StdioCollector {
            onStreamFinished: root.hostname = text.trim()
        }
    }

    Process {
        command: ["hyprctl", "-j", "version"]
        running: root.active && !root.hyprlandVersion
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const info = JSON.parse(text);
                    root.hyprlandVersion = info.version || info.tag || (info.commit || "").slice(0, 7);
                } catch (_) {
                    root.hyprlandVersion = "";
                }
            }
        }
    }

    Process {
        id: uptimeProcess
        command: ["uptime", "-p"]
        environment: ({ "LC_ALL": "C" })
        stdout: StdioCollector {
            onStreamFinished: root.uptime = text.trim().replace(/^up\s+/, "")
        }
    }

    Timer {
        running: root.active
        interval: 15000
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProcess.running = true
    }

    component Card: Rectangle {
        radius: Settings.px(16)
        color: Theme.surface
        border.width: 1
        border.color: Theme.barOutline
    }

    component Label: Text {
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(12)
        color: Theme.textMuted
        textFormat: Text.PlainText
        elide: Text.ElideRight
    }

    GridLayout {
        id: sections
        width: Math.max(0, root.width - Settings.px(8))
        columns: width >= Settings.px(650) ? 2 : 1
        columnSpacing: Settings.px(24)
        rowSpacing: Settings.px(12)

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(445)
            spacing: Settings.px(12)

            Card {
                Layout.fillWidth: true
                implicitHeight: overview.implicitHeight + Settings.px(28)
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.tint(Theme.surface, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)) }
                    GradientStop { position: 1; color: Theme.surface }
                }

                ColumnLayout {
                    id: overview
                    anchors.fill: parent
                    anchors.margins: Settings.px(14)
                    spacing: Settings.px(4)

                    Label {
                        Layout.fillWidth: true
                        text: "SYSTEM OVERVIEW"
                        font.pixelSize: Settings.px(10)
                        font.letterSpacing: Settings.px(1)
                        font.bold: true
                    }

                    Label {
                        Layout.topMargin: Settings.px(4)
                        Layout.fillWidth: true
                        text: root.username
                        color: Theme.textPrimary
                        font.pixelSize: Settings.px(22)
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "Hostname: " + (root.hostname || "Unavailable")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "Uptime: " + (root.uptime || "Unavailable")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: "Hyprland: " + (root.hyprlandVersion || "Version unavailable")
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                implicitHeight: dateTime.implicitHeight + Settings.px(28)

                ColumnLayout {
                    id: dateTime
                    anchors.fill: parent
                    anchors.margins: Settings.px(14)
                    spacing: Settings.px(3)

                    Label {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(clock.date, Settings.clockFormat)
                        color: Theme.accent
                        font.pixelSize: Settings.px(24)
                        font.bold: true
                        font.features: ({ "tnum": 1 })
                    }

                    Label {
                        Layout.fillWidth: true
                        text: Qt.locale().toString(clock.date, "dddd, MMMM d, yyyy")
                    }
                }
            }

            Card {
                Layout.fillWidth: true
                implicitHeight: sliders.implicitHeight + Settings.px(28)

                ColumnLayout {
                    id: sliders
                    anchors.fill: parent
                    anchors.margins: Settings.px(14)
                    spacing: Settings.px(6)

                    VolumeControl {
                        Layout.fillWidth: true
                        node: Pipewire.defaultAudioSink ?? null
                        title: "Volume"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Settings.px(8)

                        Label {
                            Layout.fillWidth: true
                            Layout.preferredWidth: Settings.px(224)
                            Layout.minimumWidth: 0
                            text: "Brightness"
                            color: Theme.textPrimary
                            font.pixelSize: Settings.px(14)
                        }

                        LevelSlider {
                            Layout.fillWidth: true
                            Layout.minimumWidth: Settings.px(32)
                            Layout.preferredWidth: Settings.px(168)
                            Layout.maximumWidth: Settings.px(180)
                            Accessible.name: "Monitor brightness"
                            enabled: root.brightness.available
                            value: root.brightness.level
                            onMoved: root.brightness.setLevel(value)
                        }

                        Label {
                            Layout.preferredWidth: Settings.px(42)
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Settings.px(13)
                            font.features: ({ "tnum": 1 })
                            text: root.brightness.available ? Math.round(root.brightness.level * 100) + "%" : "N/A"
                        }

                        Label {
                            Layout.preferredWidth: Settings.px(28)
                            horizontalAlignment: Text.AlignHCenter
                            text: "\uE1AC"
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: Settings.px(16)
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredWidth: Settings.px(560)
            spacing: Settings.px(12)

            NowPlaying {
                Layout.fillWidth: true
                selectedPlayerName: root.selectedPlayerName
                onPlayerRequested: name => root.playerRequested(name)
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                uniformCellWidths: true
                columnSpacing: Settings.px(8)
                rowSpacing: Settings.px(8)

                QuickToggle {
                    Layout.fillWidth: true
                    text: "Wi-Fi"
                    glyph: highlighted ? "\uE63E" : "\uE648"
                    enabled: root.wifiAvailable
                    highlighted: enabled && Networking.wifiEnabled
                    unavailableHint: "No unblocked NetworkManager Wi-Fi adapter"
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }

                QuickToggle {
                    Layout.fillWidth: true
                    text: "Bluetooth"
                    glyph: highlighted ? "\uE1A7" : "\uE1A9"
                    enabled: root.bluetooth !== null
                    highlighted: root.bluetooth?.enabled ?? false
                    unavailableHint: "No Bluetooth adapter"
                    onClicked: root.bluetooth.enabled = !root.bluetooth.enabled
                }

                QuickToggle {
                    Layout.fillWidth: true
                    text: "Caffeine"
                    glyph: "\uE541"
                    highlighted: QuickSettings.caffeine
                    onClicked: QuickSettings.caffeine = !QuickSettings.caffeine
                }

                QuickToggle {
                    Layout.fillWidth: true
                    text: "Night Light"
                    glyph: "\uF159"
                    enabled: QuickSettings.nightLight.available
                    highlighted: QuickSettings.nightLight.state === true
                    unavailableHint: "Start hyprsunset to use Night Light"
                    onClicked: QuickSettings.nightLight.toggle()
                }

                QuickToggle {
                    Layout.fillWidth: true
                    text: "DND"
                    glyph: highlighted ? "\uE7F6" : "\uE7F4"
                    enabled: QuickSettings.dnd.available
                    highlighted: QuickSettings.dnd.state === true
                    unavailableHint: "Requires Noctalia v5 notification IPC"
                    onClicked: QuickSettings.dnd.toggle()
                }

                QuickToggle {
                    Layout.fillWidth: true
                    text: !enabled ? "Power profile" : PowerProfiles.profile === PowerProfile.PowerSaver ? "Power saver"
                        : PowerProfiles.profile === PowerProfile.Performance ? "Performance" : "Balanced"
                    glyph: "\uEAF6"
                    enabled: QuickSettings.powerAvailable
                    highlighted: PowerProfiles.profile !== PowerProfile.Balanced
                    unavailableHint: "Requires power-profiles-daemon and powerprofilesctl"
                    onClicked: {
                        switch (PowerProfiles.profile) {
                        case PowerProfile.PowerSaver:
                            PowerProfiles.profile = PowerProfile.Balanced;
                            break;
                        case PowerProfile.Balanced:
                            PowerProfiles.profile = PowerProfiles.hasPerformanceProfile ? PowerProfile.Performance : PowerProfile.PowerSaver;
                            break;
                        default:
                            PowerProfiles.profile = PowerProfile.PowerSaver;
                            break;
                        }
                    }
                }
            }
        }
    }
}
