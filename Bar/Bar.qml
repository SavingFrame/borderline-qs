import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Bar.Widgets
import qs.Settings

Scope {
    id: root

    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            color: "transparent"
            required property var modelData
            screen: modelData
            anchors.top: true
            margins.top: 10

            implicitWidth: Math.round(modelData.width * Settings.barWidthRatio)
            implicitHeight: Settings.barHeight

            Rectangle {
                anchors.fill: parent

                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.12)
                color: Theme.background

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Workspace {
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        ClockWidget {
                            Layout.fillWidth: true
                            // Layout.fillHeight: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        ClockWidget {
                            Layout.fillWidth: true
                            // Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }
}
