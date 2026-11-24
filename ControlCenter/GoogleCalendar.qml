import Quickshell
import Quickshell.Io
import QtQuick
import qs.Settings

Item {
    id: root

    required property bool active
    required property date focusDay
    readonly property int focusMonth: monthNumber(focusDay)
    readonly property bool busy: worker.running
    readonly property bool connecting: busy && worker.action === "connect"
    readonly property bool hasEventsForMonth: cache[focusMonth] !== undefined
    property var cache: ({})
    property bool configured: false
    property var accounts: []
    readonly property bool connected: accounts.length > 0
    property string error: ""

    function monthNumber(day: date): int {
        return day.getFullYear() * 12 + day.getMonth();
    }

    function monthDate(number: int): date {
        return new Date(Math.floor(number / 12), number % 12, 1);
    }

    function offsetDay(day: date, offset: int): date {
        return new Date(day.getFullYear(), day.getMonth(), day.getDate() + offset);
    }

    function run(action: string, account: string): void {
        const first = monthNumber(offsetDay(focusDay, -30));
        const last = monthNumber(offsetDay(focusDay, 90));
        request(action, account, first, last - first + 1);
    }

    function request(action: string, account: string, first: int, months: int): void {
        if (busy || !active)
            return;
        error = "";
        worker.requestFocus = focusMonth;
        worker.action = action;
        const start = Qt.formatDate(monthDate(first), "yyyy-MM-dd");
        const command = ["python3", Quickshell.shellDir + "/scripts/google-calendar.py",
            action, start, "--months=" + months];
        if (action === "disconnect")
            command.push("--account=" + account);
        worker.exec(command);
    }

    function eventsOn(day: date): list<var> {
        const key = Qt.formatDate(day, "yyyy-MM-dd");
        const start = +offsetDay(day, 0);
        const end = +offsetDay(day, 1);
        const events = cache[monthNumber(day)] ?? cache[focusMonth] ?? [];
        return events.filter(event => event.allDay ? event.start <= key && event.end > key
            : event.start < end && (event.end > start || (event.start === event.end && event.start >= start)));
    }

    onActiveChanged: if (active) Qt.callLater(refresh)
    onFocusMonthChanged: if (active) refreshDelay.restart()

    function refresh(): void {
        run("list", "");
    }

    function loadMonth(): void {
        if (!hasEventsForMonth)
            refresh();
    }

    Timer {
        id: refreshDelay
        interval: 180
        onTriggered: root.loadMonth()
    }

    Timer {
        interval: Settings.googleCalendarRefreshIntervalMs
        running: root.active && root.connected
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: worker
        property int requestFocus
        property string action

        stdout: StdioCollector { id: output }
        onExited: (code, status) => {
            try {
                if (code !== 0 || status !== 0)
                    throw new Error();
                const response = JSON.parse(output.text);
                root.configured = response.configured;
                const accountsChanged = JSON.stringify(response.accounts) !== JSON.stringify(root.accounts);
                if (accountsChanged)
                    root.accounts = response.accounts;
                root.error = response.error || response.warning || "";
                if (accountsChanged || (!response.error && root.connected)) {
                    const cache = accountsChanged ? {} : Object.assign({}, root.cache);
                    if (!response.error && root.connected) {
                        for (const month of response.months) {
                            const [year, number] = month.split("-");
                            cache[Number(year) * 12 + Number(number) - 1] = response.events;
                        }
                    }
                    root.cache = cache;
                }
            } catch (_) {
                root.error = "Could not run the Google Calendar helper. Check that Python 3 is installed.";
            }
            if (root.active && requestFocus !== root.focusMonth)
                Qt.callLater(root.loadMonth);
        }
    }
}
