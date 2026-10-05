pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var profiles: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]
    readonly property string profileName: PowerProfiles.profile === PowerProfile.PowerSaver ? "Saver"
                                        : PowerProfiles.profile === PowerProfile.Performance ? "Fast" : "Balanced"
    readonly property string profileIcon: PowerProfiles.profile === PowerProfile.PowerSaver ? "energy_savings_leaf"
                                        : PowerProfiles.profile === PowerProfile.Performance ? "bolt" : "balance"

    function lock()     { Quickshell.execDetached(["loginctl", "lock-session"]); }
    function suspend()  { Quickshell.execDetached(["systemctl", "suspend"]); }
    function logout()   { Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.exit()"]); }
    function reboot()   { Quickshell.execDetached(["systemctl", "reboot"]); }
    function shutdown() { Quickshell.execDetached(["systemctl", "poweroff"]); }

    function cycleProfile() {
        const i = profiles.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = profiles[(i + 1) % profiles.length];
    }
}
