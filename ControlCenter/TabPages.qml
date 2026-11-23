import QtQuick
import QtQuick.Layouts
import qs.Bar

StackLayout {
    id: root

    required property bool opened
    required property MonitorBrightness brightness

    property string selectedPlayerName: ""

    HomePage {
        active: root.opened && root.currentIndex === ControlCenter.Home
        brightness: root.brightness
        selectedPlayerName: root.selectedPlayerName
        onPlayerRequested: name => root.selectedPlayerName = name
    }

    SoundPage {
        selectedPlayerName: root.selectedPlayerName
        onPlayerRequested: name => root.selectedPlayerName = name
    }

    NetworkPage {
        active: root.opened && root.currentIndex === ControlCenter.Network
    }
}
