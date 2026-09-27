// Current time and date, formatted for the bar.
// Usage: import qs.services  →  text: Time.time

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Clock format. AM/PM for now; later this becomes a user setting.
    property bool use24h: false

    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, use24h ? "HH:mm" : "h:mm AP")
    readonly property string date: Qt.formatDateTime(clock.date, "ddd d MMM")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
