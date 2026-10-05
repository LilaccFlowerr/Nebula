pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    property bool launcherOpen: false
    property bool powerMenuOpen: false
    property bool quickSettingsOpen: false
    property bool mediaExpanded: false
    property bool settingsOpen: false
    property bool settingsFromQuick: false
    property string settingsPage: ""
    property string settingsTab: ""
    property string screen: ""
    property bool capturing: false

    function isOn(screenName) {
        return screen === screenName;
    }

    function focusedScreen() {
        return Hyprland.focusedMonitor?.name ?? "";
    }

    function toggleLauncher(screenName = focusedScreen()) {
        if (launcherOpen && screen === screenName) {
            launcherOpen = false;
        } else {
            closeAll();
            screen = screenName;
            launcherOpen = true;
        }
    }

    function togglePowerMenu(screenName = focusedScreen()) {
        if (powerMenuOpen && screen === screenName) {
            powerMenuOpen = false;
        } else {
            closeAll();
            screen = screenName;
            powerMenuOpen = true;
        }
    }

    function toggleQuickSettings(screenName = focusedScreen()) {
        if (quickSettingsOpen && screen === screenName) {
            quickSettingsOpen = false;
        } else {
            closeAll();
            screen = screenName;
            quickSettingsOpen = true;
        }
    }

    function toggleMedia(screenName = focusedScreen()) {
        if (mediaExpanded && screen === screenName) {
            mediaExpanded = false;
        } else {
            closeAll();
            screen = screenName;
            mediaExpanded = true;
        }
    }

    function toggleSettings(screenName = focusedScreen(), fromQuick = false) {
        if (settingsOpen) {
            settingsOpen = false;
        } else {
            closeAll();
            screen = screenName;
            settingsFromQuick = fromQuick;
            settingsOpen = true;
        }
    }

    function openSettings(page, tab = "", fromQuick = false) {
        settingsPage = page;
        settingsTab = tab;
        if (!settingsOpen) toggleSettings(focusedScreen(), fromQuick);
    }

    function closeAll() {
        launcherOpen = false;
        powerMenuOpen = false;
        quickSettingsOpen = false;
        mediaExpanded = false;
        settingsOpen = false;
    }

    IpcHandler {
        target: "media"

        function toggle(): void { if (Media.active) root.toggleMedia(); }
    }

    IpcHandler {
        target: "quicksettings"

        function toggle(): void { root.toggleQuickSettings(); }
    }

    IpcHandler {
        target: "settings"

        function toggle(): void { root.toggleSettings(); }
        function open(page: string, tab: string): void { root.openSettings(page, tab); }
    }
}
