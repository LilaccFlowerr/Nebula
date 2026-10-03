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
            }
        }
    }
}
