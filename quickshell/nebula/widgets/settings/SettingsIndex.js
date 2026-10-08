.pragma library

var entries = [
    { title: "Wallpaper", page: "appearance", words: "background image picture change" },
    { title: "Wallpaper transition", page: "appearance", words: "animation reveal shape cookie fade" },
    { title: "Color style", page: "appearance", words: "scheme theme colors palette matugen" },
    { title: "Dark mode", page: "appearance", words: "light mode theme" },
    { title: "Animation speed", page: "appearance", words: "motion fast slow" },
    { title: "Reduce motion", page: "appearance", words: "animations off accessibility" },

    { title: "Now playing widget", page: "desktop", words: "music media spotify cookie" },
    { title: "Spin while playing", page: "desktop", words: "rotate now playing" },
    { title: "Widget position", page: "desktop", words: "now playing reset move" },

    { title: "Workspaces per group", page: "bar", tab: "left", words: "workspace count dots" },
    { title: "Workspace style", page: "bar", tab: "left", words: "numbers pills shapes" },
    { title: "Visualizer", page: "bar", tab: "middle", words: "cava bars music island" },
    { title: "Synced lyrics", page: "bar", tab: "middle", words: "music media card" },
    { title: "Volume and brightness popup", page: "bar", tab: "middle", words: "osd duration island" },
    { title: "Logo when idle", page: "bar", tab: "middle", words: "os logo fedora island" },
    { title: "Island popups", page: "bar", tab: "middle", words: "volume brightness charger low battery events" },
    { title: "24-hour clock", page: "bar", tab: "right", words: "time clock am pm" },
    { title: "Tray button", page: "bar", tab: "right", words: "system tray" },
    { title: "Battery ring", page: "bar", tab: "right", words: "power button" },
    { title: "Weather city", page: "bar", tab: "right", words: "weather location calendar" },
    { title: "Quick settings tiles", page: "bar", tab: "right", words: "tiles toggles quick settings" },

    { title: "Wifi", page: "connections", tab: "wifi", words: "wireless network internet password" },
    { title: "Ethernet", page: "connections", tab: "ethernet", words: "cable wired ip address mac" },
    { title: "Bluetooth", page: "connections", tab: "bluetooth", words: "devices headphones pair" },

    { title: "Use this display", page: "system", tab: "displays", words: "monitor screen enable disable" },
    { title: "Resolution", page: "system", tab: "displays", words: "refresh rate hz monitor" },
    { title: "Scale", page: "system", tab: "displays", words: "zoom size monitor" },
    { title: "Screen brightness", page: "system", tab: "displays", words: "backlight" },
    { title: "Power mode", page: "system", tab: "power", words: "profile saver balanced performance" },
    { title: "Low battery warning", page: "system", tab: "power", words: "battery percentage" },
    { title: "Keyboard layout", page: "system", tab: "input", words: "keyboard us qwerty language" },
    { title: "Repeat rate", page: "system", tab: "input", words: "keyboard key repeat" },
    { title: "Repeat delay", page: "system", tab: "input", words: "keyboard key" },
    { title: "Mouse speed", page: "system", tab: "input", words: "sensitivity pointer" },
    { title: "Flat acceleration", page: "system", tab: "input", words: "mouse accel" },
    { title: "Natural scrolling", page: "system", tab: "input", words: "touchpad scroll direction" },
    { title: "Tap to click", page: "system", tab: "input", words: "touchpad" },
    { title: "Ignore while typing", page: "system", tab: "input", words: "touchpad disable typing" },

    { title: "Default apps", page: "apps", words: "terminal browser files editor" },
    { title: "Recent apps", page: "apps", words: "launcher history clear" },

    { title: "Do not disturb", page: "notifications", words: "dnd silence" },
    { title: "Popup duration", page: "notifications", words: "timeout notification" },
    { title: "Urgent popup duration", page: "notifications", words: "critical timeout" },

    { title: "Record audio", page: "recorder", tab: "recording", words: "sound microphone recording" },
    { title: "Start with a region", page: "recorder", tab: "recording", words: "area recording" },
    { title: "Framerate", page: "recorder", tab: "recording", words: "fps recording" },
    { title: "Recordings folder", page: "recorder", tab: "recording", words: "videos files" },
    { title: "Copy screenshots to clipboard", page: "recorder", tab: "screenshots", words: "screenshot clipboard" },
    { title: "Screenshot notification", page: "recorder", tab: "screenshots", words: "screenshot notify" },
    { title: "Screenshots folder", page: "recorder", tab: "screenshots", words: "pictures files" },

    { title: "System info", page: "about", words: "os compositor shell version" },
    { title: "Reset all settings", page: "about", words: "defaults factory" }
];

function search(query, pages) {
    var q = query.trim().toLowerCase();
    if (q === "") return [];
    var scored = [];
    var all = entries.concat(pages.map(function (p) { return { title: p.title, page: p.key, words: p.subtitle, isPage: true }; }));
    for (var i = 0; i < all.length; i++) {
        var e = all[i];
        var title = e.title.toLowerCase();
        var score = title.indexOf(q) === 0 ? 4 : title.indexOf(q) > 0 ? 3 : (e.words || "").toLowerCase().indexOf(q) >= 0 ? 2 : 0;
        if (score > 0) scored.push({ entry: e, score: score + (e.isPage ? 0.5 : 0), index: i });
    }
    scored.sort(function (a, b) { return b.score - a.score || a.index - b.index; });
    return scored.slice(0, 8).map(function (s) { return s.entry; });
}
