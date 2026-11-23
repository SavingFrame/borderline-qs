pragma ComponentBehavior: Bound

import Quickshell.Networking
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Layouts
import qs.Settings
import qs.Theme

ColumnLayout {
    id: wifiRow
    required property WifiSection section
    required property WifiNetwork network
    readonly property bool expanded: wifiRow.section.optionsNetwork === network
    readonly property bool editing: wifiRow.section.editingPassword && wifiRow.section.passwordNetwork === network
    readonly property bool canJoin: network.known || wifiRow.section.openNetwork(network) || wifiRow.section.needsPassword(network)
    readonly property bool changing: network.stateChanging || wifiRow.section.busy(network.device)
    spacing: Settings.px(4)

    RowLayout {
        Layout.fillWidth: true
        NetworkUi.StatusIcon {
            text: wifiRow.network.signalStrength >= 0.67 ? "\uE63E"
                : wifiRow.network.signalStrength >= 0.34 ? "\uE4D9" : "\uE4CA"
            highlighted: wifiRow.network.connected
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Settings.px(2)
            NetworkUi.Title { Layout.fillWidth: true; text: wifiRow.network.name || "Hidden network" }
            NetworkUi.Label {
                Layout.fillWidth: true
                text: {
                    const network = wifiRow.network;
                    if (network.stateChanging) return ConnectionState.toString(network.state);
                    if (network.connected) return "Connected";
                    if (network.known) return network.signalStrength > 0 ? "Saved" : "Saved · Out of range";
                    if (!wifiRow.canJoin) return "Setup required";
                    return wifiRow.section.openNetwork(network) ? "Open network" : "Password required";
                }
            }
        }
        NetworkUi.Action {
            visible: wifiRow.network.known && !wifiRow.network.connected
            text: "⋯"
            Accessible.name: "Options for " + wifiRow.network.name
            quiet: true
            onClicked: {
                wifiRow.section.optionsNetwork = wifiRow.expanded ? null : wifiRow.network;
                if (wifiRow.expanded)
                    Qt.callLater(wifiRow.revealRow);
            }
        }
        NetworkUi.Action {
            visible: !wifiRow.editing && (wifiRow.network.connected || wifiRow.canJoin)
            enabled: !wifiRow.changing && !wifiRow.section.editingPassword && (wifiRow.network.connected || wifiRow.network.signalStrength > 0)
            text: wifiRow.network.connected ? "Disconnect" : "Join"
            onClicked: {
                if (wifiRow.network.connected) {
                    wifiRow.section.actionRequested();
                    wifiRow.network.disconnect();
                } else {
                    wifiRow.section.join(wifiRow.network);
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Settings.px(36)
        visible: wifiRow.editing
        onVisibleChanged: if (visible) Qt.callLater(wifiRow.focusPassword)
        Component.onCompleted: if (visible) Qt.callLater(wifiRow.focusPassword)

        Basic.TextField {
            id: password
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Accessible.name: "Password for " + wifiRow.network.name
            placeholderText: "Password"
            text: wifiRow.editing ? wifiRow.section.passwordDraft : ""
            onTextEdited: wifiRow.section.passwordDraft = text
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            font.family: Settings.fontFamily
            font.pixelSize: Settings.px(13)
            color: Theme.textPrimary
            placeholderTextColor: Theme.textMuted
            background: Rectangle {
                radius: Settings.px(6)
                color: Theme.background
                border.color: password.activeFocus ? Theme.accent : Theme.barOutline
            }
            onAccepted: wifiRow.section.submitPassword()
        }
        NetworkUi.Action { text: "Cancel"; quiet: true; onClicked: wifiRow.section.cancelPassword() }
        NetworkUi.Action { text: "Join"; enabled: wifiRow.section.passwordDraft.length > 0; onClicked: wifiRow.section.submitPassword() }
    }

    NetworkDetails {
        Layout.fillWidth: true
        Layout.topMargin: Settings.px(4)
        interfaceName: wifiRow.network.device?.name ?? ""
        active: wifiRow.section.active && wifiRow.network.connected
    }

    NetworkUi.Action {
        Layout.alignment: Qt.AlignRight
        visible: wifiRow.expanded && wifiRow.network.known && !wifiRow.network.connected
        enabled: !wifiRow.changing && !wifiRow.section.editingPassword
        quiet: true
        text: "Forget network"
        onClicked: {
            wifiRow.section.optionsNetwork = null;
            wifiRow.network.forget();
        }
    }

    Connections {
        target: wifiRow.network
        function onConnectionFailed(reason) { wifiRow.section.connectionFailed(wifiRow.network.name, reason); }
    }

    function revealRow(): void {
        wifiRow.section.revealItem(wifiRow);
    }

    function focusPassword(): void {
        if (editing) {
            revealRow();
            password.forceActiveFocus();
        }
    }
}
