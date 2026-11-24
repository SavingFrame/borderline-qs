pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.ControlCenter.Widgets
import qs.Settings
import qs.Theme

Item {
    id: root

    required property bool active
    readonly property var calendarLocale: Qt.locale()
    readonly property date today: clock.date
    property date pickedDay
    property bool followToday: true
    property bool showAccounts: false
    readonly property date selectedDay: followToday ? today : pickedDay
    readonly property date displayedMonth: monthStart(selectedDay, 0)
    readonly property string selectedKey: Qt.formatDate(selectedDay, "yyyy-MM-dd")
    readonly property string todayKey: Qt.formatDate(today, "yyyy-MM-dd")
    readonly property var selectedEvents: google.hasEventsForMonth ? google.eventsOn(selectedDay) : []

    function jumpToToday(): void {
        followToday = true;
    }

    function pickDay(day: date): void {
        pickedDay = day;
        followToday = false;
    }

    function monthStart(day: date, offset: int): date {
        return new Date(day.getFullYear(), day.getMonth() + offset, 1);
    }

    function eventTime(event: var): string {
        if (event.allDay)
            return "All day";
        const start = new Date(event.start);
        if (Qt.formatDate(start, "yyyy-MM-dd") !== selectedKey)
            return "Continues";
        return start.toLocaleTimeString(calendarLocale, Locale.ShortFormat);
    }

    onActiveChanged: if (active) jumpToToday()
    onSelectedKeyChanged: agenda.positionViewAtBeginning()

    GoogleCalendar {
        id: google
        focusDay: root.selectedDay
        active: root.active
    }

    SystemClock {
        id: clock
        enabled: root.active
        precision: SystemClock.Minutes
    }

    component CalendarButton: Button {
        id: button

        font.family: Settings.fontFamily
        font.pixelSize: Settings.px(13)
        implicitWidth: Math.max(Settings.px(30), implicitContentWidth + Settings.px(16))
        implicitHeight: Settings.px(28)
        padding: 0

        contentItem: Text {
            text: button.text
            font: button.font
            color: button.enabled ? Theme.textPrimary : Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: Settings.px(6)
            color: button.down || button.checked ? Theme.border : button.hovered ? Theme.surfaceHover : Theme.background
            border.width: button.visualFocus ? 1 : 0
            border.color: Theme.accent
        }
    }

    component Pane: Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.surface
        radius: Settings.px(10)
        border.width: 1
        border.color: Theme.barOutline
    }

    component EventBlock: Rectangle {
        property color stripe: Theme.accent

        radius: Settings.px(3)
        color: Qt.tint(Theme.surface, Qt.rgba(stripe.r, stripe.g, stripe.b, 0.19))

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: Math.max(0, parent.height - Settings.px(4))
            width: Settings.px(2)
            radius: width / 2
            color: parent.stripe
        }
    }

    function eventColor(event: var): color {
        const color = event.color;
        return color && /^#[0-9a-f]{6}$/i.test(color) ? color : Theme.accent;
    }

    GridLayout {
        id: panes

        readonly property bool sideBySide: width >= Settings.px(570)
        width: Math.min(parent.width, Settings.px(1040))
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        columns: sideBySide ? 2 : 1
        columnSpacing: Settings.px(10)
        rowSpacing: Settings.px(8)

        Pane {
            Layout.preferredWidth: Settings.px(730)
            Layout.minimumWidth: 0
            Layout.preferredHeight: Settings.px(310)
            Layout.minimumHeight: Settings.px(240)
            Layout.maximumHeight: panes.sideBySide ? Number.POSITIVE_INFINITY : Settings.px(330)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Settings.px(10)
                spacing: Settings.px(5)

                RowLayout {
                    Layout.fillWidth: true

                    CalendarButton {
                        text: "‹"
                        Accessible.name: "Previous month"
                        onClicked: root.pickDay(root.monthStart(root.displayedMonth, -1))
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.calendarLocale.toString(root.displayedMonth, "MMMM yyyy")
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: Theme.textPrimary
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(18)
                        font.bold: true
                    }

                    CalendarButton {
                        text: "›"
                        Accessible.name: "Next month"
                        onClicked: root.pickDay(root.monthStart(root.displayedMonth, 1))
                    }

                    CalendarButton {
                        text: "Today"
                        onClicked: root.jumpToToday()
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Settings.px(20)
                    locale: root.calendarLocale
                    padding: 0
                    spacing: grid.spacing

                    delegate: Text {
                        required property string shortName

                        text: shortName
                        elide: Text.ElideRight
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(11)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MonthGrid {
                    id: grid

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    locale: root.calendarLocale
                    month: root.displayedMonth.getMonth()
                    year: root.displayedMonth.getFullYear()
                    padding: 0
                    spacing: Settings.px(3)

                    delegate: AbstractButton {
                        id: cell

                        required property var model
                        readonly property date day: new Date(model.year, model.month, model.day)
                        readonly property string dayKey: Qt.formatDate(day, "yyyy-MM-dd")
                        readonly property bool isToday: dayKey === root.todayKey
                        readonly property bool selected: dayKey === root.selectedKey
                        readonly property bool inMonth: model.month === grid.month
                        readonly property var events: google.hasEventsForMonth ? google.eventsOn(day) : []
                        // Reserve a line for overflow only when not all events fit.
                        readonly property real lineHeight: Settings.px(15)
                        readonly property int slots: Math.max(0, Math.floor((height - Settings.px(23)) / lineHeight))
                        readonly property int shown: width < Settings.px(44) ? 0
                            : events.length <= slots ? events.length : Math.max(0, slots - 1)

                        padding: 0
                        hoverEnabled: true
                        Accessible.name: root.calendarLocale.toString(day, "dddd, d MMMM yyyy")
                            + (events.length ? ", " + events.length + (events.length === 1 ? " event" : " events") : "")
                        Accessible.selected: selected
                        onClicked: root.pickDay(day)

                        background: Rectangle {
                            radius: Settings.px(4)
                            color: cell.selected ? Qt.tint(Theme.surface, Theme.workspaceOutline)
                                : cell.hovered ? Theme.surfaceHover : Theme.background
                            border.width: cell.selected || cell.visualFocus ? 1 : 0
                            border.color: Theme.accent
                        }

                        contentItem: Item {
                            clip: true

                            Rectangle {
                                x: Settings.px(4)
                                y: Settings.px(3)
                                width: Settings.px(17)
                                height: width
                                radius: width / 2
                                color: cell.isToday ? Theme.accent : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: cell.model.day
                                    color: cell.isToday ? Theme.background : cell.inMonth ? Theme.textPrimary : Theme.textMuted
                                    opacity: cell.inMonth || cell.selected || cell.isToday ? 1 : 0.65
                                    font.family: Settings.fontFamily
                                    font.pixelSize: Settings.px(11)
                                    font.bold: cell.isToday || cell.selected
                                }
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Settings.px(3)
                                visible: cell.slots === 0 && cell.events.length > 0
                                text: "•"
                                color: Theme.accent
                                font.pixelSize: Settings.px(11)
                            }

                            Column {
                                x: Settings.px(4)
                                y: Settings.px(22)
                                width: Math.max(0, parent.width - 2 * x)

                                Repeater {
                                    model: cell.events.slice(0, cell.shown)

                                    delegate: Item {
                                        id: preview

                                        required property var modelData
                                        width: parent.width
                                        height: cell.lineHeight

                                        EventBlock {
                                            anchors.fill: parent
                                            anchors.bottomMargin: 1
                                            stripe: root.eventColor(preview.modelData)

                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: Settings.px(5)
                                                anchors.rightMargin: Settings.px(2)
                                                verticalAlignment: Text.AlignVCenter
                                                text: preview.modelData.title
                                                textFormat: Text.PlainText
                                                elide: Text.ElideRight
                                                color: Theme.textPrimary
                                                font.family: Settings.fontFamily
                                                font.pixelSize: Settings.px(10)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    height: cell.lineHeight
                                    visible: cell.slots > 0 && cell.events.length > cell.shown
                                    text: "+" + (cell.events.length - cell.shown) + (cell.width >= Settings.px(55) ? " more" : "")
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                    color: Theme.textMuted
                                    font.family: Settings.fontFamily
                                    font.pixelSize: Settings.px(10)
                                }
                            }
                        }
                    }
                }
            }
        }

        Pane {
            Layout.preferredWidth: Settings.px(300)
            Layout.minimumWidth: 0
            Layout.minimumHeight: Settings.px(105)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Settings.px(10)
                spacing: Settings.px(6)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.calendarLocale.toString(root.selectedDay,
                            root.selectedDay.getFullYear() === root.today.getFullYear() ? "dddd, d MMMM" : "dddd, d MMMM yyyy")
                        elide: Text.ElideRight
                        color: Theme.textPrimary
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(14)
                        font.bold: true
                        Accessible.role: Accessible.Heading
                    }

                    CalendarButton {
                        visible: google.connected
                        enabled: !google.busy
                        text: "↻"
                        Accessible.name: "Refresh Google Calendar"
                        onClicked: google.refresh()
                    }

                    CalendarButton {
                        visible: google.connected
                        text: "⚙"
                        checkable: true
                        checked: root.showAccounts
                        Accessible.name: "Manage Google Calendar accounts"
                        onClicked: root.showAccounts = checked
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    visible: google.connected ? root.showAccounts : google.configured
                    spacing: Settings.px(5)

                    CalendarButton {
                        visible: google.connected
                        text: "Disconnect"
                        enabled: !google.busy && accountPicker.currentIndex >= 0
                        Accessible.name: "Disconnect selected Google account"
                        onClicked: google.run("disconnect", accountPicker.currentValue)
                    }

                    CalendarButton {
                        enabled: !google.busy
                        text: google.connected ? "Add account" : "Connect Google Calendar"
                        onClicked: google.run("connect", "")
                    }
                }

                ThemedComboBox {
                    id: accountPicker

                    Layout.fillWidth: true
                    Layout.preferredHeight: Settings.px(28)
                    visible: google.connected && root.showAccounts
                    model: google.accounts
                    textRole: "label"
                    valueRole: "id"
                    enabled: !google.busy
                    Accessible.name: "Connected Google accounts"
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.px(12)
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    textFormat: Text.PlainText
                    text: google.error || (google.connecting ? "Finish signing in with Google in your browser…" :
                        !google.hasEventsForMonth && (google.busy || google.connected) ?
                        (google.connected ? "Loading events…" : "Checking Google Calendar…") :
                        google.connected ? (root.selectedEvents.length ? "" : "No events on this day.") :
                        !google.configured ? "To connect Google Calendar, add an OAuth client (see README)." : "")
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    color: google.error ? Theme.danger : Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.px(12)
                }

                ListView {
                    id: agenda

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 0
                    clip: true
                    model: root.selectedEvents
                    spacing: Settings.px(5)
                    boundsBehavior: Flickable.StopAtBounds
                    Accessible.name: "Selected day events"
                    ScrollBar.vertical: ScrollBar {}

                    delegate: EventBlock {
                        id: entry

                        required property var modelData
                        readonly property string time: root.eventTime(modelData)
                        width: Math.max(0, ListView.view.width - Settings.px(8))
                        height: eventDetails.implicitHeight + Settings.px(12)
                        stripe: root.eventColor(modelData)
                        ToolTip.visible: hover.hovered && ToolTip.text.length > 0
                        ToolTip.text: modelData.calendar ?? ""
                        ToolTip.delay: 500

                        HoverHandler {
                            id: hover
                        }

                        RowLayout {
                            id: eventDetails

                            anchors.fill: parent
                            anchors.leftMargin: Settings.px(9)
                            anchors.rightMargin: Settings.px(6)
                            anchors.topMargin: Settings.px(6)
                            anchors.bottomMargin: Settings.px(6)
                            spacing: Settings.px(8)

                            Text {
                                Layout.preferredWidth: Settings.px(60)
                                Layout.alignment: Qt.AlignTop
                                text: entry.time
                                color: Theme.textMuted
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.px(11)
                            }

                            Text {
                                Layout.fillWidth: true
                                text: entry.modelData.title
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                                color: Theme.textPrimary
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.px(12)
                            }
                        }
                    }
                }
            }
        }
    }
}
