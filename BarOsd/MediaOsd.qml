import QtQuick
import Quickshell.Services.Mpris
import qs.Settings
import qs.Theme
import qs.BarOsd

    Row {
        id: mediaRow
        visible: root.osdMode === "media"
        spacing: Settings.px(10)

        anchors.centerIn: parent

        Image {
            id: mediaIcon

            width: Settings.px(19)
            height: width
            visible: status == Image.Ready
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            color: Theme.textPrimary
            font.pixelSize: Settings.px(14)
            font.family: Settings.fontFamily
            font.features: {
                "tnum": 1
            }
            text: root.player?.trackTitle ?? ""
        }

        Text {

            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textPrimary
            font.pixelSize: Settings.px(18)
            font.family: "Material Symbols Rounded"
            text: {
                if (root.player?.isPlaying) {
                    return "\ue037";
                } else {
                    return "\ue034";
                }
            }
        }
    }
