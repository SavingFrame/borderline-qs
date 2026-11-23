import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick
import qs.Bar

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property bool osd_active: false
    property string osdIcon: ""
    property int osdPercent: 0
    property string osdMode: "progress"
    property MprisPlayer player
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
                    if (!acceptMediaPlayer(target)) {
                        return;
                    }
                    if (target?.isPlaying)
                        root.showMediaOverlay(target);
                }

                function onPlaybackStateChanged() {
                    if (!acceptMediaPlayer(target)) {
                        return;
                    }
                    if (target && target.playbackState !== MprisPlaybackState.Stopped)
                        root.showMediaOverlay(target);
                }

                function acceptMediaPlayer(player: MprisPlayer): bool {
                    const players = Mpris.players.values;
                    if (player.dbusName.startsWith("org.mpris.MediaPlayer2.chromium.instance")) {
                        const realSpotify = players.find(p => p.dbusName === "org.mpris.MediaPlayer2.spotify");
                        if (realSpotify && realSpotify.metadata["mpris::length"] === player.metadata["mpris::length"] && (player.trackTitle.startsWith(realSpotify.trackTitle) || player.trackTitle.startsWith("Spotify - Web Player:"))) {
                            return false;
                        }
                    }
                    return true;
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
