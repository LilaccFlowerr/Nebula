// Battery via UPower. On a machine without a battery `available` is false,
// so widgets can simply hide the battery ring.
// Usage: import qs.services  →  Battery.available, Battery.level (0–1), Battery.charging

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice

    readonly property bool available: device !== null && device.isLaptopBattery && device.isPresent
    readonly property real level: available ? device.percentage : 0   // 0.0 – 1.0
    readonly property int percent: Math.round(level * 100)

    readonly property bool charging: available && device.state === UPowerDeviceState.Charging
    readonly property bool pluggedIn: available && !UPower.onBattery   // follows the charger right away, faster than `charging`
    readonly property bool full: available && device.state === UPowerDeviceState.FullyCharged
    readonly property bool low: available && !pluggedIn && level < 0.2

    // Seconds, 0 when unknown
    readonly property real timeToEmpty: available ? device.timeToEmpty : 0
    readonly property real timeToFull: available ? device.timeToFull : 0
}
