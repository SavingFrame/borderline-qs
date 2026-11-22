import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Bar.Widgets
import qs.Settings
import qs.BarOsd

Scope {
    id: root

    property bool osd_active: false
    property string osdIcon: ""
    property int osdPercent: 0
    property string osdMode: "progress"
    property MprisPlayer player

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            color: "transparent"
            required property var modelData
            screen: modelData
            anchors.top: true
            margins.top: 10

            implicitWidth: Math.round(modelData.width * Settings.barWidthRatio)
            implicitHeight: Settings.px(Settings.barHeight)

            Rectangle {

                anchors.fill: parent
                radius: 12
                border.width: 1
                border.color: Theme.barOutline
                color: Theme.background

                Item {
                    opacity: root.osd_active ? 0 : 1
                    enabled: !root.osd_active
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    RowLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        Workspace {
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        ClockWidget {
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        KeyboardLayout {}
                        SystemTray {}
                        Network {}
                        Bluetooth {}
                        Volume {}
                        ClockWidget {}
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 170
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                BarOsd {
                    id: osdBar

                    trackWidth: parent.width * 0.4
                    opacity: root.osd_active ? 1 : 0
                    enabled: root.osd_active
                    anchors.centerIn: parent
                    value: root.osdPercent
                    icon: root.osdIcon
                    osdMode: root.osdMode
                    player: root.player

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 170
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: {
            const sink = Pipewire.defaultAudioSink;
            return sink?.ready ? sink.audio : null;
        }

        function onVolumeChanged() {
            if (target.muted) {
                root.showProgressOverlay("\uE04F", target.volume);
            } else if (target.volume >= 0.5) {
                root.showProgressOverlay("\uE050", target.volume);
            } else if (target.volume < 0.5 && target.volume > 0) {
                root.showProgressOverlay("\uE04D", target.volume);
            } else if (target.volume == 0) {
                root.showProgressOverlay("\uE04E", target.volume);
            }
        }

        function onMutedChanged() {
            if (target.muted) {
                root.showProgressOverlay("\uE04F", target.volume);
            } else if (target.volume >= 0.5) {
                root.showProgressOverlay("\uE050", target.volume);
            } else if (target.volume < 0.5 && target.volume > 0) {
                root.showProgressOverlay("\uE04D", target.volume);
            } else if (target.volume == 0) {
                root.showProgressOverlay("\uE04E", target.volume);
            }
        }
    }

    Variants {
        model: Mpris.players.values

        Scope {
            id: mediaSession
            required property MprisPlayer modelData

            Connections {
                target: mediaSession.modelData?.dbusName === "org.mpris.MediaPlayer2.TelegramDesktop" ? null : mediaSession.modelData

                function onPostTrackChanged() {
                    if (target?.isPlaying)
                        root.showMediaOverlay(target);
                }

                function onPlaybackStateChanged() {
                    if (target && target.playbackState !== MprisPlaybackState.Stopped)
                        root.showMediaOverlay(target);
                }
            }
        }
    }

    MonitorBrightness {
        id: monitorBrightness
        onPreview: level => root.showProgressOverlay("\uE1AC", level)
    }

    IpcHandler {
        target: "barOsd"

        function brightnessUp() {
            monitorBrightness.adjust(1);
        }
        function brightnessDown() {
            monitorBrightness.adjust(-1);
        }
        function brightnessShow() {
            monitorBrightness.show();
        }
    }

    function showProgressOverlay(icon: string, level: real) {
        root.osdIcon = icon;
        root.osdPercent = Math.round(level * 100);
        root.osd_active = true;
        root.osdMode = "progress";
        osdTimer.restart();
    }

    function showMediaOverlay(player: MprisPlayer) {
        root.player = player;
        root.osdMode = "media";
        root.osd_active = true;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1200
        repeat: false
        onTriggered: root.osd_active = false
    }
}
