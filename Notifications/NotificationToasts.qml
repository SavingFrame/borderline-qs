import QtQuick
import Quickshell
import qs.Settings

PanelWindow {
    id: root

    required property NotificationService service

    readonly property int toastWidth: Math.max(1, Math.min(Settings.px(340),
        (service.toastScreen?.width ?? Settings.px(364)) - Settings.px(24)))

    screen: service.toastScreen
    visible: service.toastScreen !== null && service.toasts.length > 0
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: Settings.px(12)
    margins.right: Settings.px(12)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: false
    implicitWidth: toastWidth
    implicitHeight: Math.max(1, stack.implicitHeight)

    Column {
        id: stack
        width: root.toastWidth
        spacing: Settings.px(8)

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150; easing.type: Easing.OutCubic }
        }
        move: Transition {
            NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: ScriptModel { values: root.service.toasts }

            delegate: NotificationCard {
                id: toast
                required property var modelData
                width: stack.width
                notification: modelData
                compact: true
                onDismissRequested: root.service.dismiss(notification)

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: root.service.hideToast(toast.notification)
                }

                // Quickshell 0.3.2 exposes the raw D-Bus milliseconds despite the QML docstring.
                property int remaining: modelData?.expireTimeout > 0 ? modelData.expireTimeout : 7000
                property double deadline: 0

                function resumeCountdown(): void {
                    deadline = Date.now() + remaining;
                    timer.start();
                }

                Component.onCompleted: {
                    if (!pointer.hovered)
                        resumeCountdown();
                }

                Timer {
                    id: timer
                    interval: toast.remaining
                    onTriggered: root.service.hideToast(toast.notification)
                }

                HoverHandler {
                    id: pointer
                    onHoveredChanged: {
                        if (hovered && timer.running) {
                            timer.stop();
                            toast.remaining = Math.max(1, toast.deadline - Date.now());
                        } else if (!hovered && !timer.running) {
                            toast.resumeCountdown();
                        }
                    }
                }
            }
        }
    }
}
