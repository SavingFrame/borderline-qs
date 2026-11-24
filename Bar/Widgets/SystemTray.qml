import QtQuick
import Quickshell.Services.SystemTray
import Quickshell

import Quickshell.Widgets
import qs.Settings
import qs.Theme

Repeater {
    id: root
    model: SystemTray.items

    MouseArea {
        id: trayItem
        required property SystemTrayItem modelData

        implicitWidth: trayIcon.implicitWidth
        implicitHeight: trayIcon.implicitHeight

        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                modelData.activate();
            } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                trayMenu.visible = !trayMenu.visible;
            }
        }

        IconImage {
            id: trayIcon
            anchors.centerIn: parent
            source: trayItem.modelData.icon
            implicitSize: 20
        }

        TrayMenu {
            id: trayMenu
            sourceItem: trayItem.modelData

            anchor.item: trayItem
            anchor.edges: Edges.Bottom
            anchor.gravity: Edges.Bottom
            anchor.adjustment: PopupAdjustment.Flip
        }

        // QsMenuAnchor {
        //     id: anchor
        //     menu: trayItem.modelData.menu
        //     // anchor.onAnchoring: {
        //     //     const window = trayItem.QsWindow.window;
        //     //     const widgetRect = window.contentItem.mapFromItem(trayItem, 0, trayItem.height, trayItem.width, trayItem.height);
        //     //     menuAnchor.anchor.rect = widgetRect;
        //     // }
        // }
    }
}
