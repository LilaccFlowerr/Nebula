pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool use24h: false

    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(clock.date, use24h ? "HH:mm" : "h:mm AP")
    readonly property string date: clock.date.toLocaleString(Qt.locale("en_US"), "ddd, MMM d")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
