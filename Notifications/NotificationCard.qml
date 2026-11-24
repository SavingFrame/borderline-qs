import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Settings
import qs.Theme

Rectangle {
    id: root

    required property var notification
    property bool compact: false
    property bool groupExpanded: false
    property int olderCount: 0
    signal dismissRequested()
    signal toggleGroupRequested()

    readonly property string appIcon: notification?.appIcon ?? ""
    readonly property string appIconSource: appIcon.startsWith("/") ? "file://" + appIcon
        : appIcon.startsWith("file:") ? appIcon : appIcon ? Quickshell.iconPath(appIcon, true) : ""
    readonly property string attachment: notification?.image?.toString() ?? ""
    readonly property string attachmentSource: attachment !== appIconSource
        && (attachment.startsWith("image://") || attachment.startsWith("file:")) ? attachment : ""
    readonly property var progress: notification?.hints?.value
    implicitHeight: content.implicitHeight + 2 * Settings.px(12)
    radius: Settings.px(10)
    color: Theme.surface
    border.width: 1
    border.color: Theme.barOutline

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Settings.px(12)
        spacing: Settings.px(5)

        RowLayout {
            Layout.fillWidth: true

            Image {
                id: icon
                visible: status === Image.Ready
                Layout.preferredWidth: Settings.px(18)
                Layout.preferredHeight: Settings.px(18)
                source: root.appIconSource
                fillMode: Image.PreserveAspectFit
            }

            Text {
                visible: !icon.visible
                text: "\uE7F4"
                color: Theme.textMuted
                font.family: "Material Symbols Rounded"
                font.pixelSize: Settings.px(18)
            }

            CardText {
                Layout.fillWidth: true
                text: root.notification?.appName || "Notification"
                color: Theme.textMuted
                font.pixelSize: Settings.px(12)
                maximumLineCount: 1
            }

            NotificationButton {
                visible: root.olderCount > 0
                text: root.groupExpanded ? "Show less ▴" : "Show " + root.olderCount + " more ▾"
                Accessible.description: root.groupExpanded ? "Collapse notification group" : "Expand notification group"
                onClicked: root.toggleGroupRequested()
            }

            NotificationButton {
                text: "\uE5CD"
                font.family: "Material Symbols Rounded"
                Accessible.name: "Dismiss notification"
                onClicked: root.dismissRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Settings.px(10)

            TapHandler {
                enabled: root.olderCount > 0
                onTapped: root.toggleGroupRequested()
            }

            HoverHandler {
                enabled: root.olderCount > 0
                cursorShape: Qt.PointingHandCursor
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Settings.px(4)

                CardText {
                    visible: text.length > 0
                    text: root.notification?.summary ?? ""
                    font.bold: true
                    maximumLineCount: root.compact ? 2 : 4
                }

                CardText {
                    visible: text.length > 0
                    text: root.notification?.body ?? ""
                    maximumLineCount: root.compact ? 3 : 6
                }
            }

            Image {
                readonly property int size: Settings.px(root.compact ? 52 : 72)
                visible: status === Image.Ready
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: size
                Layout.preferredHeight: size
                sourceSize.width: size
                sourceSize.height: size
                source: root.attachmentSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
        }

        Rectangle {
            visible: typeof root.progress === "number"
            Layout.fillWidth: true
            implicitHeight: Settings.px(4)
            radius: height / 2
            color: Theme.surfaceHover

            Rectangle {
                width: parent.width * Math.min(1, Math.max(0, Number(root.progress ?? 0) / 100))
                height: parent.height
                radius: parent.radius
                color: Theme.accent
            }
        }

        Flow {
            Layout.fillWidth: true
            visible: actions.count > 0
            spacing: Settings.px(5)

            Repeater {
                id: actions
                model: root.notification?.actions ?? []

                NotificationButton {
                    required property var modelData
                    width: Math.min(implicitWidth, content.width)
                    text: modelData.text || (modelData.identifier === "default" ? "Open" : "Action")
                    onClicked: modelData.invoke()
                }
            }
        }
    }

    component CardText: Text {
        Layout.fillWidth: true
        textFormat: Text.PlainText
        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(14)
        color: Theme.textPrimary
        wrapMode: Text.Wrap
        elide: Text.ElideRight
    }
}
