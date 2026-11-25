import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Settings

Scope {
    id: root

    readonly property bool preview: Quickshell.env("BORDERLINE_NOTIFICATIONS_PREVIEW") === "1"
    readonly property url previewAttachment: Qt.resolvedUrl("preview-attachment.svg")
    readonly property var inbox: activeItems.filter(item => !item.transient)
    readonly property var inboxGroups: {
        const groups = new Map();
        for (const item of inbox) {
            const desktopEntry = (item.desktopEntry ?? "").trim().replace(/\.desktop$/i, "");
            const appName = (item.appName ?? "").trim();
            const title = (item.summary ?? "").trim();
            const appKey = desktopEntry ? "desktop:" + desktopEntry
                : appName ? "app:" + appName.toLowerCase() : "";
            // Untitled or unidentified notifications stay separate.
            const key = appKey && title ? JSON.stringify([appKey, title]) : "notification:" + item.id;
            if (!groups.has(key))
                groups.set(key, []);
            groups.get(key).push(item);
        }
        return groups;
    }
    readonly property var toasts: toastIds.map(id => activeItems.find(item => item.id === id)).filter(item => !!item)
    readonly property var toastScreen: Quickshell.screens.find(screen => screen.name === toastScreenName)
        ?? Quickshell.screens[0] ?? null
    readonly property int count: inbox.length

    property bool dnd: false
    property bool soundEnabled: false
    property var toastIds: []
    property string toastScreenName: ""
    property int nextPreviewId: 5

    readonly property var activeItems: {
        if (preview)
            return previewItems;
        const values = serverLoader.item?.trackedNotifications.values;
        const items = [];
        for (let i = (values?.length ?? 0) - 1; i >= 0; --i)
            items.push(values[i]);
        return items;
    }

    property var previewItems: [
        { id: 4, appName: "Files", appIcon: "system-file-manager", summary: "Copying photos",
          body: "18 of 30 files copied", image: previewAttachment,
          hints: { value: 60 }, actions: [] },
        { id: 3, appName: "Telegram", appIcon: "internet-chat", summary: "Alice",
          body: "Can you check if the train on Saturday still leaves at 10? We can meet by the station entrance and pick up coffee before we go.", actions: [] },
        { id: 2, appName: "Telegram", appIcon: "internet-chat", summary: "Bob",
          body: "Are you free on Sunday?", actions: [] },
        { id: 1, appName: "Telegram", appIcon: "internet-chat", summary: "Alice",
          body: "I sent you the itinerary.", actions: [] }
    ]

    Component.onCompleted: {
        if (!preview) {
            dnd = dndFile.text().trim() === "on";
            soundEnabled = soundFile.text().trim() === "on";
        }
    }

    function toggleDnd(): void {
        dnd = !dnd;
        if (!preview)
            dndFile.setText(dnd ? "on\n" : "off\n");
    }

    function toggleSound(): void {
        soundEnabled = !soundEnabled;
        if (!preview)
            soundFile.setText(soundEnabled ? "on\n" : "off\n");
    }

    function testSound(): void {
        sound.play(null, true);
    }

    onSoundEnabledChanged: {
        if (!soundEnabled)
            sound.cancelAutomatic();
    }

    onDndChanged: {
        if (!dnd)
            return;
        sound.cancelAutomatic();
        const visible = toasts;
        toastIds = [];
        for (const notification of visible) {
            if (notification.transient)
                notification.expire();
        }
    }

    function enqueueToast(notification): void {
        const ids = toasts.map(item => item.id);
        if (ids.includes(notification.id) || ids.length >= Settings.notificationMaxToasts || dnd)
            return;
        if (ids.length === 0)
            toastScreenName = Hyprland.focusedMonitor?.name ?? "";
        toastIds = [...ids, notification.id];
        if (soundEnabled && toastScreen)
            sound.play(notification.hints, false);
    }

    function hideToast(notification): void {
        if (!notification)
            return;
        toastIds = toastIds.filter(id => id !== notification.id);
        if (notification.transient)
            notification.expire();
    }

    function previewToast(): void {
        if (!preview)
            return;
        const notification = {
            id: nextPreviewId++, appName: "Borderline", summary: "Sample notification",
            body: "Hover to keep this popup open. It will stay in the inbox after the popup closes.",
            image: previewAttachment, actions: []
        };
        previewItems = [notification, ...previewItems];
        enqueueToast(notification);
    }

    function dismiss(notification): void {
        if (!notification)
            return;
        toastIds = toastIds.filter(id => id !== notification.id);
        if (preview)
            previewItems = previewItems.filter(item => item.id !== notification.id);
        else
            notification.dismiss();
    }

    function dismissItems(items): void {
        // Dismissal changes the inbox and can remove the group while iterating.
        for (const notification of items.slice())
            root.dismiss(notification);
    }

    function clearGroup(key): void {
        root.dismissItems(root.inboxGroups.get(key) ?? []);
    }

    function clearAll(): void {
        root.dismissItems(root.inbox);
    }

    FileView {
        id: dndFile
        path: root.preview ? "" : Quickshell.statePath("notification-dnd")
        preload: !root.preview
        blockLoading: true
        blockWrites: true
        printErrors: false
        onSaveFailed: error => console.warn("Could not save notification DND state:", error)
    }

    FileView {
        id: soundFile
        path: root.preview ? "" : Quickshell.statePath("notification-sound")
        preload: !root.preview
        blockLoading: true
        blockWrites: true
        printErrors: false
        onSaveFailed: error => console.warn("Could not save notification sound state:", error)
    }

    NotificationSound { id: sound }

    LazyLoader {
        id: serverLoader
        active: !root.preview

        NotificationServer {
            keepOnReload: true
            persistenceSupported: true
            actionsSupported: true
            imageSupported: true
            extraHints: ["value", "sound-file", "sound-name", "suppress-sound"]

            onNotification: notification => {
                const showToast = !root.dnd && !notification.lastGeneration && root.toasts.length < Settings.notificationMaxToasts;
                if (!notification.transient || showToast)
                    notification.tracked = true;
                if (showToast)
                    root.enqueueToast(notification);
            }
        }
    }

    IpcHandler {
        target: "notifications"

        function count(): int {
            return root.count;
        }

        function clearAll(): void {
            root.clearAll();
        }

        function toggleDnd(): void {
            root.toggleDnd();
        }

        function dndStatus(): bool {
            return root.dnd;
        }

        function toastCount(): int {
            return root.toasts.length;
        }

        function previewToast(): void {
            root.previewToast();
        }
    }
}
