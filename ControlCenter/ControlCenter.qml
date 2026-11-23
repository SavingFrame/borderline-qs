import Quickshell
import QtQuick
import qs.Settings
import qs.Theme
import QtQuick.Layouts

PopupWindow {
    id: root
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        bottomLeftRadius: 12
        bottomRightRadius: 12
        color: Qt.tint(Theme.background, Theme.barOutline)

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
}
