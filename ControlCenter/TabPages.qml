import QtQuick
import QtQuick.Layouts

StackLayout {
    id: root

    required property bool opened
    readonly property alias networkPage: networkPage

    SoundPage {}

    NetworkPage {
        id: networkPage
        active: root.opened && root.currentIndex === 1
    }
}
