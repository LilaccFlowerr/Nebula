pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/.config/nebula"
    readonly property alias clock: adapter.clock
    readonly property alias notifications: adapter.notifications
    readonly property alias recorder: adapter.recorder
    readonly property alias wallpaper: adapter.wallpaper
    readonly property alias nowPlaying: adapter.nowPlaying
    readonly property alias theme: adapter.theme
    readonly property alias bar: adapter.bar
    readonly property alias apps: adapter.apps
    readonly property alias input: adapter.input
    readonly property alias displays: adapter.displays
    readonly property alias power: adapter.power

    Process {
        running: true
        command: ["mkdir", "-p", root.directory]
    }

    FileView {
        id: file
        path: root.directory + "/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) writeAdapter();
        }
        onSaved: if (!loaded) reload()

        JsonAdapter {
            id: adapter

            property JsonObject clock: JsonObject {
                property bool use24h: false
            }

            property JsonObject notifications: JsonObject {
                property int normalTimeout: 3000
                property int urgentTimeout: 5000
                property bool doNotDisturb: false
            }

            property JsonObject recorder: JsonObject {
                property bool sound: true
                property bool useRegion: false
                property int framerate: 60
            }

            property JsonObject wallpaper: JsonObject {
                property string path: ""
                property string directory: ""
                property string transition: "cookie9"
            }

            property JsonObject nowPlaying: JsonObject {
                property bool enabled: true
                property bool spin: true
                property real x: -1
                property real y: -1
            }

            property JsonObject apps: JsonObject {
                property string terminal: "com.mitchellh.ghostty"
                property string browser: "org.mozilla.firefox"
                property string files: "org.gnome.Nautilus"
                property string editor: "com.microsoft.VSCode"
            }

            property JsonObject input: JsonObject {
                property string layout: "us"
                property int repeatRate: 25
                property int repeatDelay: 600
                property real sensitivity: 0
                property bool flatAccel: false
                property bool naturalScroll: false
                property bool tapToClick: true
                property bool disableWhileTyping: true
            }

            property JsonObject displays: JsonObject {
                property string monitors: "{}"
            }

            property JsonObject power: JsonObject {
                property int lowBattery: 20
            }

            property JsonObject bar: JsonObject {
                property int workspaces: 5
                property bool visualizer: true
                property bool lyrics: true
                property int osdDuration: 1500
                property bool osLogo: true
                property bool trayButton: true
                property bool batteryRing: true
            }

            property JsonObject theme: JsonObject {
                property string scheme: "scheme-tonal-spot"
                property string mode: "dark"
            }
        }
    }
}
