import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Settings
import qs.Theme

ColumnLayout {
    id: root

    required property NotificationService service
    property var expandedGroups: new Set()
    property bool settingsOpen: false
    spacing: Settings.px(8)

    Connections {
        target: root.service
        function onInboxGroupsChanged() {
            root.expandedGroups = new Set([...root.expandedGroups].filter(key =>
                (root.service.inboxGroups.get(key)?.length ?? 0) > 1));
        }
    }

    function toggleGroup(key): void {
        const expanded = new Set(expandedGroups);
        if (!expanded.delete(key))
            expanded.add(key);
        expandedGroups = expanded;
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            text: "Notifications (" + root.service.count + ")"
            color: Theme.textPrimary
            font.family: Settings.fontFamily
            font.pixelSize: Settings.px(15)
            font.bold: true
        }

        NotificationButton {
            visible: root.service.preview
            text: "Test toast"
            onClicked: root.service.previewToast()
        }

        NotificationButton {
            text: "\uE8B8"
            font.family: "Material Symbols Rounded"
            Accessible.name: "Notification settings"
            Accessible.description: root.settingsOpen ? "Hide sound controls" : "Show sound controls"
            onClicked: root.settingsOpen = !root.settingsOpen
        }

        NotificationButton {
            text: "Clear all"
            enabled: root.service.count > 0
            onClicked: root.service.clearAll()
        }
    }

    RowLayout {
        visible: root.settingsOpen
        Layout.fillWidth: true

        NotificationButton {
            text: root.service.soundEnabled ? "Sound: On" : "Sound: Off"
            Accessible.checkable: true
            Accessible.checked: root.service.soundEnabled
            onClicked: root.service.toggleSound()
        }

        NotificationButton {
            text: "Test sound"
            onClicked: root.service.testSound()
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Text {
            anchors.centerIn: parent
            visible: root.service.count === 0
            text: "No notifications"
            color: Theme.textMuted
            font.family: Settings.fontFamily
            font.pixelSize: Settings.px(14)
        }

        ListView {
            anchors.fill: parent
            clip: true
            spacing: Settings.px(6)
            boundsBehavior: Flickable.StopAtBounds
            model: ScriptModel { values: [...root.service.inboxGroups.keys()] }

            delegate: NotificationGroup {
                required property string modelData
                width: ListView.view.width
                notifications: root.service.inboxGroups.get(modelData) ?? []
                expanded: root.expandedGroups.has(modelData)
                onToggleRequested: root.toggleGroup(modelData)
                onClearRequested: root.service.clearGroup(modelData)
                onDismissRequested: notification => root.service.dismiss(notification)
            }
        }
    }
}
