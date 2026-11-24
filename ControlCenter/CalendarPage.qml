import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Settings
import qs.Theme

Item {
    id: root

    required property bool active
    readonly property var calendarLocale: Qt.locale()
    readonly property date today: clock.date
    property bool followToday: true
    property date browsedMonth
    property date pickedDay
    property bool hasPickedDay: false
    readonly property date displayedMonth: followToday ? monthStart(today, 0) : browsedMonth
    readonly property date selectedDay: hasPickedDay ? pickedDay : today
    readonly property string selectedKey: Qt.formatDate(selectedDay, "yyyy-MM-dd")
    property bool agendaJumpPending: true
    property var agendaAnchor: null
    readonly property var agendaRows: {
        const rows = [];
        const range = google.agendaRange;
        if (!range)
            return rows;
        for (let day = range.first; day < range.end; day = google.offsetDay(day, 1)) {
            const events = google.eventsOn(day);
            if (!events.length)
                continue;
            const key = Qt.formatDate(day, "yyyy-MM-dd");
            const format = day.getFullYear() === today.getFullYear() ? "dddd, d MMMM" : "dddd, d MMMM yyyy";
            rows.push({ heading: true, key: key, title: calendarLocale.toString(day, format) });
            for (const event of events) {
                rows.push({ heading: false, key: key, title: event.title, calendar: event.calendar,
                    time: eventTime(event, key) });
            }
        }
        return rows;
    }

    function jumpToToday(): void {
        agendaJumpPending = true;
        followToday = true;
        hasPickedDay = false;
        Qt.callLater(positionAgenda);
    }

    function pickDay(day: date): void {
        agendaJumpPending = true;
        const month = monthStart(day, 0);
        if (+month !== +displayedMonth) {
            browsedMonth = month;
            followToday = false;
        }
        pickedDay = day;
        hasPickedDay = true;
        Qt.callLater(positionAgenda);
    }

    function rememberAgendaPosition(): void {
        if (agendaJumpPending || !agendaRows.length)
            return;
        // The top pixel can fall in the spacing between two rows.
        for (let offset = 0; offset <= agenda.spacing + 1; ++offset) {
            const index = agenda.indexAt(1, agenda.contentY + offset);
            if (index < 0)
                continue;
            const key = agendaRows[index].key;
            const first = agendaRows.findIndex(row => row.key === key);
            agendaAnchor = { key: key, row: index - first };
            break;
        }
    }

    function positionAgenda(): void {
        if (!active || !google.hasEventsForMonth || agenda.height <= 0)
            return;
        agenda.forceLayout();
        if (agendaJumpPending) {
            agendaJumpPending = false;
            const index = agendaRows.findIndex(row => row.heading && row.key >= selectedKey);
            if (index >= 0)
                agenda.positionViewAtIndex(index, ListView.Beginning);
            else if (agendaRows.length)
                agenda.positionViewAtEnd();
        } else if (agendaAnchor) {
            const anchor = agendaAnchor;
            const index = agendaRows.findIndex(row => row.key >= anchor.key);
            if (index >= 0) {
                const target = index + anchor.row;
                const sameDay = agendaRows[target]?.key === anchor.key;
                agenda.positionViewAtIndex(sameDay ? target : index, ListView.Beginning);
            }
        }
        agendaAnchor = null;
    }

    function monthStart(date: date, offset: int): date {
        return new Date(date.getFullYear(), date.getMonth() + offset, 1);
    }

    function stepMonth(offset: int): void {
        pickDay(monthStart(displayedMonth, offset));
    }

    function eventTime(event: var, dayKey: string): string {
        if (event.allDay)
            return "All day";
        const start = new Date(event.start);
        if (Qt.formatDate(start, "yyyy-MM-dd") !== dayKey)
            return "Continues";
        return start.toLocaleTimeString(calendarLocale, Locale.ShortFormat);
    }

    onActiveChanged: if (active) jumpToToday()
    onAgendaRowsChanged: Qt.callLater(positionAgenda)

    GoogleCalendar {
        id: google
        focusDay: root.selectedDay
        active: root.active
        onEventsAboutToChange: root.rememberAgendaPosition()
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
            color: Theme.textPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: Settings.px(6)
            color: button.down ? Theme.border : button.hovered ? Theme.surfaceHover : Theme.background
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

    GridLayout {
        id: panes

        readonly property bool sideBySide: width >= Settings.px(540)
        width: Math.min(parent.width, Settings.px(820))
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        columns: sideBySide ? 2 : 1
        columnSpacing: Settings.px(10)
        rowSpacing: Settings.px(8)

        Pane {
            Layout.preferredWidth: Settings.px(390)
            Layout.minimumHeight: Settings.px(240)
            Layout.preferredHeight: Settings.px(240)
            Layout.maximumHeight: panes.sideBySide ? Number.POSITIVE_INFINITY : Settings.px(240)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Settings.px(12)
                spacing: Settings.px(6)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.calendarLocale.toString(root.today, "dddd, d MMMM yyyy")
                        elide: Text.ElideRight
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(13)
                    }

                    CalendarButton {
                        text: "Today"
                        onClicked: root.jumpToToday()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    CalendarButton {
                        text: "‹"
                        Accessible.name: "Previous month"
                        onClicked: root.stepMonth(-1)
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
                        onClicked: root.stepMonth(1)
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Settings.px(22)
                    locale: root.calendarLocale
                    padding: 0
                    spacing: 0

                    delegate: Text {
                        required property string shortName

                        text: shortName
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(12)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MonthGrid {
                    id: grid

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: Settings.px(panes.sideBySide ? 150 : 112)
                    locale: root.calendarLocale
                    month: root.displayedMonth.getMonth()
                    year: root.displayedMonth.getFullYear()
                    padding: 0
                    spacing: 0

                    delegate: AbstractButton {
                        id: cell

                        required property var model
                        readonly property date day: new Date(model.year, model.month, model.day)
                        readonly property string dayKey: Qt.formatDate(day, "yyyy-MM-dd")
                        readonly property bool isToday: dayKey === Qt.formatDate(root.today, "yyyy-MM-dd")
                        readonly property bool selected: dayKey === root.selectedKey
                        readonly property bool inMonth: model.month === grid.month
                        readonly property bool hasEvents: google.eventsOn(day).length > 0

                        Accessible.name: root.calendarLocale.toString(day, "dddd, d MMMM yyyy")
                            + (hasEvents ? ", has events" : "")
                        Accessible.selected: selected
                        onClicked: root.pickDay(day)

                        background: Rectangle {
                            id: dayBadge

                            anchors.centerIn: parent
                            width: Math.min(cell.width, cell.height, Settings.px(30))
                            height: width
                            radius: Settings.px(6)
                            color: cell.isToday ? Theme.accent : cell.hovered ? Theme.surfaceHover : "transparent"
                            border.width: !cell.isToday && (cell.selected || cell.visualFocus) ? 1 : 0
                            border.color: Theme.accent
                        }

                        contentItem: Text {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: cell.model.day
                            color: cell.isToday ? Theme.background : cell.inMonth ? Theme.textPrimary : Theme.textMuted
                            opacity: cell.inMonth || cell.isToday ? 1 : 0.55
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.px(13)
                            font.bold: cell.isToday
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: dayBadge.bottom
                            anchors.bottomMargin: Settings.px(2)
                            width: Settings.px(3)
                            height: width
                            radius: width / 2
                            color: cell.isToday ? Theme.background : Theme.accent
                            visible: cell.hasEvents
                        }
                    }
                }
            }
        }

        Pane {
            Layout.preferredWidth: Settings.px(340)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Settings.px(12)
                spacing: Settings.px(6)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Agenda"
                        elide: Text.ElideRight
                        color: Theme.textPrimary
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(13)
                        font.bold: true
                    }

                    CalendarButton {
                        visible: google.connected || google.configured
                        enabled: !google.busy
                        text: google.connected ? "Add account" : "Connect Google Calendar"
                        onClicked: google.run("connect", "")
                    }

                    CalendarButton {
                        visible: google.connected
                        enabled: !google.busy
                        text: "↻"
                        Accessible.name: "Refresh Google Calendar"
                        onClicked: google.refresh()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: google.connected

                    ComboBox {
                        id: accountPicker
                        Layout.fillWidth: true
                        Layout.preferredHeight: Settings.px(28)
                        model: google.accounts
                        textRole: "label"
                        valueRole: "id"
                        enabled: !google.busy
                        Accessible.name: "Connected Google accounts"
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(12)
                        palette.button: Theme.background
                        palette.buttonText: Theme.textPrimary
                        palette.base: Theme.surface
                        palette.text: Theme.textPrimary
                        palette.highlight: Theme.surfaceHover
                        palette.highlightedText: Theme.textPrimary
                    }

                    CalendarButton {
                        text: "Disconnect"
                        enabled: !google.busy && accountPicker.currentIndex >= 0
                        Accessible.name: "Disconnect selected Google account"
                        onClicked: google.run("disconnect", accountPicker.currentValue)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    textFormat: Text.PlainText
                    text: google.error || (google.connecting ? "Finish signing in with Google in your browser…" :
                        google.busy && !google.hasEventsForMonth ?
                        (google.connected ? "Loading events…" : "Checking Google Calendar…") :
                        google.connected ? (root.agendaRows.length ? "" : "No events in the loaded dates.") :
                        google.configured ? "Connect Google Calendar to see events." :
                        "To connect Google Calendar, add an OAuth client (see README).")
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    color: google.error ? Theme.danger : Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.px(12)
                }

                ListView {
                    id: agenda

                    property real movementStartY: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.agendaRows
                    spacing: Settings.px(4)
                    boundsBehavior: Flickable.StopAtBounds
                    onHeightChanged: if (root.agendaJumpPending) Qt.callLater(root.positionAgenda)
                    onMovementStarted: movementStartY = contentY
                    onMovementEnded: {
                        const delta = contentY - movementStartY;
                        const threshold = Settings.px(48);
                        if (delta < 0 && contentY - originY <= threshold)
                            google.extend(-1);
                        else if (delta > 0 && originY + contentHeight - height - contentY <= threshold)
                            google.extend(1);
                    }
                    Accessible.name: "Calendar agenda"
                    ScrollBar.vertical: ScrollBar {}

                    delegate: ColumnLayout {
                        id: line

                        required property var modelData
                        width: Math.max(0, ListView.view.width - Settings.px(10))
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            Layout.topMargin: Settings.px(8)
                            visible: line.modelData.heading
                            text: line.modelData.title
                            elide: Text.ElideRight
                            color: line.modelData.key === root.selectedKey ? Theme.accent : Theme.textPrimary
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.px(13)
                            font.bold: true
                            Accessible.role: Accessible.Heading
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: !line.modelData.heading
                            spacing: Settings.px(8)

                            Text {
                                Layout.preferredWidth: Settings.px(64)
                                text: line.modelData.time ?? ""
                                color: Theme.textMuted
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.px(12)
                            }

                            Text {
                                Layout.fillWidth: true
                                text: line.modelData.title
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                color: Theme.textPrimary
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.px(12)
                            }

                            Text {
                                Layout.maximumWidth: Settings.px(100)
                                text: line.modelData.calendar ?? ""
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                color: Theme.textMuted
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.px(11)
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: google.connected && google.hasEventsForMonth

                    CalendarButton {
                        text: "Earlier"
                        enabled: !google.busy
                        Accessible.name: "Load earlier dates"
                        onClicked: google.extend(-1)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: google.busy && !google.connecting ? "Loading dates…" : !google.agendaRange ? ""
                            : root.calendarLocale.toString(google.agendaRange.first, "MMM yyyy") + " → "
                                + root.calendarLocale.toString(google.offsetDay(google.agendaRange.end, -1), "MMM yyyy")
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.px(11)
                    }

                    CalendarButton {
                        text: "Later"
                        enabled: !google.busy
                        Accessible.name: "Load later dates"
                        onClicked: google.extend(1)
                    }
                }
            }
        }
    }
}
