import QtQuick
import Quickshell.Services.Mpris
import qs.Settings
import qs.BarOsd

Item {
    id: root
    anchors.leftMargin: 10
    anchors.rightMargin: 10
    implicitWidth: progressOsd.implicitWidth
    implicitHeight: progressOsd.implicitHeight

    property string osdMode: "progress"

    property int value: 0
    property string icon
    property real trackWidth: Settings.px(112)
    property MprisPlayer player

    readonly property int percent: Math.max(0, Math.min(100, value))
    // Progress row
    ProgressOsd {
        id: progressOsd
    }
    // Row {
    //     id: progressRow
    //     visible: root.osdMode === "progress"
    //     spacing: Settings.px(10)
    //     Text {
    //         font.pixelSize: Settings.px(Settings.iconSize)
    //         font.family: "Material Symbols Rounded"
    //         color: Theme.textPrimary
    //         anchors.verticalCenter: parent.verticalCenter
    //         text: root.icon
    //     }
    //     Rectangle {
    //         id: track
    //         anchors.verticalCenter: parent.verticalCenter
    //         width: root.trackWidth
    //         height: Settings.px(5)
    //         radius: height / 2
    //         color: Theme.surfaceHover
    //
    //         Rectangle {
    //             width: track.width * root.percent / 100
    //             height: track.height
    //             radius: Math.min(width, height) / 2
    //             color: Theme.accent
    //
    //             Behavior on width {
    //                 NumberAnimation {
    //                     duration: 120
    //                     easing.type: Easing.OutCubic
    //                 }
    //             }
    //         }
    //     }
    //     Text {
    //         anchors.verticalCenter: parent.verticalCenter
    //         width: Settings.px(36)
    //         horizontalAlignment: Text.AlignRight
    //         font.pixelSize: Settings.px(12)
    //         color: Theme.textPrimary
    //         text: root.percent + "%"
    //     }
    // }

    // Media row
    MediaOsd {
        id: mediaRow
    }
    // Row {
    //     id: mediaRow
    //     visible: root.osdMode === "media"
    //     spacing: Settings.px(10)
    //
    //     anchors.centerIn: parent
    //
    //     Image {
    //         id: mediaIcon
    //
    //         width: Settings.px(19)
    //         height: width
    //         visible: status == Image.Ready
    //         source: root.player?.trackArtUrl ?? ""
    //         fillMode: Image.PreserveAspectFit
    //         smooth: true
    //     }
    //
    //     Text {
    //         color: Theme.textPrimary
    //         font.pixelSize: Settings.px(14)
    //         font.family: Settings.fontFamily
    //         font.features: {
    //             "tnum": 1
    //         }
    //         text: root.player?.trackTitle ?? ""
    //     }
    //
    //     Text {
    //
    //         anchors.verticalCenter: parent.verticalCenter
    //         color: Theme.textPrimary
    //         font.pixelSize: Settings.px(18)
    //         font.family: "Material Symbols Rounded"
    //         text: {
    //             if (root.player?.isPlaying) {
    //                 return "\ue037";
    //             } else {
    //                 return "\ue034";
    //             }
    //         }
    //     }
    // }
}
