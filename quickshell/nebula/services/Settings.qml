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
    readonly property alias quickSettings: adapter.quickSettings
    readonly property alias screenshot: adapter.screenshot
    readonly property alias weather: adapter.weather
    readonly property alias settingsWindow: adapter.settingsWindow

    component ClockGroup: JsonObject {
        property bool use24h: false
    }

    component NotificationsGroup: JsonObject {
        property int normalTimeout: 3000
        property int urgentTimeout: 5000
        property bool doNotDisturb: false
    }

    component RecorderGroup: JsonObject {
        property bool sound: true
        property bool useRegion: false
        property int framerate: 60
    }

    component WallpaperGroup: JsonObject {
        property string path: ""
        property string directory: ""
        property string transition: "cookie9"
    }

    component NowPlayingGroup: JsonObject {
        property bool enabled: true
        property bool spin: true
        property real x: -1
        property real y: -1
    }

    component AppsGroup: JsonObject {
        property string terminal: "com.mitchellh.ghostty"
        property string browser: "org.mozilla.firefox"
        property string files: "org.gnome.Nautilus"
        property string editor: "com.microsoft.VSCode"
    }

    component InputGroup: JsonObject {
        property string layout: "us"
        property int repeatRate: 25
        property int repeatDelay: 600
        property real sensitivity: 0
        property bool flatAccel: false
        property bool naturalScroll: false
        property bool tapToClick: true
        property bool disableWhileTyping: true
    }

    component DisplaysGroup: JsonObject {
        property string monitors: "{}"
    }

    component PowerGroup: JsonObject {
        property int lowBattery: 20
    }

    component BarGroup: JsonObject {
        property int workspaces: 5
        property string workspaceStyle: "numbers"
        property bool visualizer: true
        property bool lyrics: true
        property int osdDuration: 1500
        property bool osLogo: true
        property bool trayButton: true
        property bool batteryRing: true
        property bool eventVolume: true
        property bool eventBrightness: true
        property bool eventCharger: true
        property bool eventLowBattery: true
    }

    component QuickSettingsGroup: JsonObject {
        property string tiles: "wifi,bluetooth,dnd"
    }

    component ScreenshotGroup: JsonObject {
        property bool copy: true
        property bool notify: true
    }

    component WeatherGroup: JsonObject {
        property string city: ""
    }

    component SettingsWindowGroup: JsonObject {
        property bool railOpen: true
    }

    component ThemeGroup: JsonObject {
        property string scheme: "scheme-tonal-spot"
        property string mode: "dark"
        property real animSpeed: 1
        property bool reduceMotion: false
    }

    signal groupReset(string group)

    readonly property var resetSkip: ["wallpaper.path", "wallpaper.directory"]

    QtObject {
        id: defaults
        readonly property ClockGroup clock: ClockGroup {}
        readonly property NotificationsGroup notifications: NotificationsGroup {}
        readonly property RecorderGroup recorder: RecorderGroup {}
        readonly property WallpaperGroup wallpaper: WallpaperGroup {}
        readonly property NowPlayingGroup nowPlaying: NowPlayingGroup {}
        readonly property AppsGroup apps: AppsGroup {}
        readonly property InputGroup input: InputGroup {}
        readonly property DisplaysGroup displays: DisplaysGroup {}
        readonly property PowerGroup power: PowerGroup {}
        readonly property BarGroup bar: BarGroup {}
        readonly property ThemeGroup theme: ThemeGroup {}
        readonly property QuickSettingsGroup quickSettings: QuickSettingsGroup {}
        readonly property ScreenshotGroup screenshot: ScreenshotGroup {}
        readonly property WeatherGroup weather: WeatherGroup {}
        readonly property SettingsWindowGroup settingsWindow: SettingsWindowGroup {}
    }

    function keys(group) {
        const d = defaults[group];
        const out = [];
        for (const k in d) if (typeof d[k] !== "function" && k !== "objectName") out.push(k);
        return out;
    }

    function reset(targets) {
        const touched = [];
        for (const target of targets) {
            const [group, key] = target.split(".");
            const live = adapter[group];
            if (!live) continue;
            for (const k of key ? [key] : keys(group)) {
                if (resetSkip.includes(group + "." + k)) continue;
                live[k] = defaults[group][k];
            }
            if (!touched.includes(group)) touched.push(group);
        }
        touched.forEach(g => groupReset(g));
    }

    function resetAll() {
        reset(["clock", "notifications", "recorder", "wallpaper", "nowPlaying", "apps", "input", "power", "bar", "theme", "quickSettings", "screenshot"]);
    }

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

            property ClockGroup clock: ClockGroup {}
            property NotificationsGroup notifications: NotificationsGroup {}
            property RecorderGroup recorder: RecorderGroup {}
            property WallpaperGroup wallpaper: WallpaperGroup {}
            property NowPlayingGroup nowPlaying: NowPlayingGroup {}
            property AppsGroup apps: AppsGroup {}
            property InputGroup input: InputGroup {}
            property DisplaysGroup displays: DisplaysGroup {}
            property PowerGroup power: PowerGroup {}
            property BarGroup bar: BarGroup {}
            property ThemeGroup theme: ThemeGroup {}
            property QuickSettingsGroup quickSettings: QuickSettingsGroup {}
            property ScreenshotGroup screenshot: ScreenshotGroup {}
            property WeatherGroup weather: WeatherGroup {}
            property SettingsWindowGroup settingsWindow: SettingsWindowGroup {}
        }
    }
}
