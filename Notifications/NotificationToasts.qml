import QtQuick
import Quickshell
import qs.Settings

PanelWindow {
    id: root

    required property NotificationService service

    readonly property int toastWidth: Math.max(1, Math.min(Settings.px(Settings.notificationToastWidth),
        (service.toastScreen?.width ?? Infinity) - Settings.px(24)))

    screen: service.toastScreen
    visible: service.toastScreen !== null && service.toasts.length > 0
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: Settings.px(12)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    focusable: false
    implicitWidth: toastWidth + Settings.px(12)
    implicitHeight: Math.max(1, stack.implicitHeight)
    mask: Region { item: stack }

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
                onDismissRequested: slideOut(true)

                property bool leaving: false
                property bool dismissAfterSlide: false

                function slideOut(dismiss): void {
                    if (leaving)
                        return;
                    leaving = true;
                    dismissAfterSlide = dismiss;
                    timer.stop();
                    snapBack.stop();
                    slide.start();
                }

                transform: Translate { id: offset }

                NumberAnimation {
                    id: slide
                    target: offset
                    property: "x"
                    to: root.implicitWidth
                    duration: 200
                    easing.type: Easing.InCubic
                    onFinished: {
                        if (toast.dismissAfterSlide)
                            root.service.dismiss(toast.notification);
                        else
                            root.service.hideToast(toast.notification);
                    }
                }

                NumberAnimation {
                    id: snapBack
                    target: offset
                    property: "x"
                    to: 0
                    duration: 160
                    easing.type: Easing.OutCubic
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: toast.slideOut(false)
                }

                DragHandler {
                    id: drag
                    target: null
                    enabled: !toast.leaving
                    acceptedButtons: Qt.LeftButton
                    yAxis.enabled: false
                    onTranslationChanged: {
                        if (active)
                            offset.x = Math.max(0, activeTranslation.x);
                    }
                    onActiveChanged: {
                        if (active) {
                            snapBack.stop();
                            toast.pauseCountdown();
                        } else if (!toast.leaving) {
                            if (offset.x >= Settings.px(48)) {
                                toast.slideOut(false);
                            } else {
                                snapBack.restart();
                                if (!pointer.hovered)
                                    toast.resumeCountdown();
                            }
                        }
                    }
                }

                // Quickshell 0.3.2 exposes the raw D-Bus milliseconds despite the QML docstring.
                property int remaining: modelData?.expireTimeout > 0 ? modelData.expireTimeout : Settings.notificationToastTimeoutMs
                property double deadline: 0

                function resumeCountdown(): void {
                    deadline = Date.now() + remaining;
                    timer.start();
                }

                function pauseCountdown(): void {
                    if (!timer.running)
                        return;
                    timer.stop();
                    remaining = Math.max(1, deadline - Date.now());
                }

                Component.onCompleted: {
                    if (!pointer.hovered)
                        resumeCountdown();
                }

                Timer {
                    id: timer
                    interval: toast.remaining
                    onTriggered: toast.slideOut(false)
                }

                HoverHandler {
                    id: pointer
                    onHoveredChanged: {
                        if (toast.leaving || drag.active)
                            return;
                        if (hovered)
                            toast.pauseCountdown();
                        else if (!timer.running)
                            toast.resumeCountdown();
                    }
                }
            }
        }
    }
}
