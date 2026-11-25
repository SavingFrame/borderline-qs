import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Settings
import qs.Theme

ColumnLayout {
    id: root

    required property var notifications
    required property bool expanded
    signal toggleRequested()
    signal clearRequested()
    signal dismissRequested(var notification)

    readonly property int olderCount: Math.max(0, notifications.length - 1)
    spacing: Settings.px(5)

    Item {
        id: stack
        Layout.fillWidth: true
        visible: root.notifications.length > 0
        readonly property int depth: root.expanded ? 0 : Math.min(2, root.olderCount)
        readonly property int step: Settings.px(4)
        implicitHeight: latestCard.implicitHeight + depth * step

        Repeater {
            model: stack.depth

            Rectangle {
                required property int index
                readonly property int stackLevel: stack.depth - index
                anchors.horizontalCenter: parent.horizontalCenter
                y: stackLevel * stack.step
                width: Math.max(0, stack.width - stackLevel * Settings.px(16))
                height: latestCard.height
                radius: latestCard.radius
                color: Theme.surface
                border.width: 1
                border.color: Theme.barOutline
            }
        }

        NotificationCard {
            id: latestCard
            width: stack.width
            z: 1
            notification: root.notifications[0] ?? null
            olderCount: root.olderCount
            groupExpanded: root.expanded
            onToggleGroupRequested: root.toggleRequested()
            onDismissRequested: root.dismissRequested(notification)
        }
    }

    NotificationButton {
        Layout.alignment: Qt.AlignRight
        visible: root.expanded && root.olderCount > 0
        text: "Clear group"
        Accessible.description: "Dismiss all notifications in this group"
        onClicked: root.clearRequested()
    }

    Repeater {
        model: ScriptModel {
            values: root.expanded ? root.notifications.slice(1) : []
        }

        delegate: NotificationCard {
            required property var modelData
            Layout.fillWidth: true
            Layout.leftMargin: Settings.px(12)
            notification: modelData
            onDismissRequested: root.dismissRequested(modelData)
        }
    }
}
