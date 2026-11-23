import Quickshell
import QtQuick
import qs.Settings
import qs.Theme
import QtQuick.Layouts

PopupWindow {
    id: root
    color: "transparent"

    property bool opened: false
    property real reveal: opened ? 1 : 0
    visible: opened || reveal > 0

    Rectangle {
        anchors.fill: parent
        bottomLeftRadius: 12
        bottomRightRadius: 12
        color: Qt.tint(Theme.background, Theme.barOutline)

        opacity: root.reveal
        enabled: root.opened
        transform: Translate {
            y: -12 * (1 - root.reveal)
        }

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
            color: Theme.background
            bottomLeftRadius: 11
            bottomRightRadius: 11

            RowLayout {
                anchors.top: parent.top

                Rectangle {
                    border.width: 1
                    border.color: Theme.barOutline
                    color: Theme.surface
                    Row {
                        Text {

                            font.pixelSize: Settings.px(Settings.iconSize)
                            font.family: "Material Symbols Rounded"
                            color: Theme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\uE050"
                        }
                        Text {
                            text: "Sound"
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.textPrimary
                            font.pixelSize: Settings.px(16)
                            font.family: Settings.fontFamily
                            font.features: {
                                "tnum": 1
                            }
                        }
                    }
                }
            }
        }
    }

    Behavior on reveal {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }
}
