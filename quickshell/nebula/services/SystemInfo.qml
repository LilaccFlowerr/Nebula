pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string user: Quickshell.env("USER")
    readonly property string host: hostFile.text().trim().split(".")[0]

    readonly property string avatarPath: Quickshell.env("HOME") + "/.face"
    property int avatarVersion: 0
    property bool hasAvatar: false
    readonly property string avatar: hasAvatar ? "file://" + avatarPath + "?v=" + avatarVersion : ""

    function pickAvatar() {
        picker.running = true;
    }

    function setAvatar(file) {
        copier.command = ["cp", file, avatarPath];
        copier.running = true;
    }

    property real uptimeSeconds: parseFloat(uptimeFile.text().split(" ")[0]) || 0
    readonly property string uptime: {
        const m = Math.floor(uptimeSeconds / 60);
        const h = Math.floor(m / 60);
        return h > 0 ? "up " + h + "h " + (m % 60) + "m" : "up " + m + "m";
    }

    readonly property string osId: {
        const match = osRelease.text().match(/^ID="?([^"\n]+)"?$/m);
        return match ? match[1] : "linux";
    }

    readonly property var logoPresets: [
        { key: "fedora", name: "Fedora", glyph: "" },
        { key: "arch", name: "Arch", glyph: "" },
        { key: "endeavouros", name: "EndeavourOS", glyph: "\uf322" },
        { key: "ubuntu", name: "Ubuntu", glyph: "" },
        { key: "debian", name: "Debian", glyph: "" },
        { key: "nixos", name: "NixOS", glyph: "" },
        { key: "opensuse-tumbleweed", name: "openSUSE", glyph: "" },
        { key: "linuxmint", name: "Mint", glyph: "" },
        { key: "pop", name: "Pop!_OS", glyph: "" },
        { key: "gentoo", name: "Gentoo", glyph: "\uf30d" },
        { key: "void", name: "Void", glyph: "\uf32e" },
        { key: "alpine", name: "Alpine", glyph: "\uf300" },
        { key: "manjaro", name: "Manjaro", glyph: "\uf312" },
        { key: "garuda", name: "Garuda", glyph: "\uf337" },
        { key: "artix", name: "Artix", glyph: "\uf31f" },
        { key: "centos", name: "CentOS", glyph: "\uf304" },
        { key: "rhel", name: "Red Hat", glyph: "\uf316" },
        { key: "rocky", name: "Rocky", glyph: "\uf32b" },
        { key: "almalinux", name: "AlmaLinux", glyph: "\uf31d" },
        { key: "kali", name: "Kali", glyph: "\uf327" },
        { key: "elementary", name: "elementary", glyph: "\uf309" },
        { key: "zorin", name: "Zorin", glyph: "\uf32f" },
        { key: "mx", name: "MX", glyph: "\uf33f" },
        { key: "neon", name: "KDE neon", glyph: "\uf331" },
        { key: "solus", name: "Solus", glyph: "\uf32d" },
        { key: "deepin", name: "Deepin", glyph: "\uf321" },
        { key: "mageia", name: "Mageia", glyph: "\uf310" },
        { key: "slackware", name: "Slackware", glyph: "\uf319" },
        { key: "freebsd", name: "FreeBSD", glyph: "\uf30c" },
        { key: "linux", name: "Tux", glyph: "\uf31a" }
    ]

    function glyphFor(key) {
        return logoPresets.find(p => p.key === key)?.glyph ?? "";
    }

    readonly property string osLogo: glyphFor(osId)
    readonly property string logo: Settings.bar.logoMode === "preset" ? glyphFor(Settings.bar.logoPreset)
        : Settings.bar.logoMode === "text" ? Settings.bar.logoText
        : osLogo

    FileView {
        id: osRelease
        path: "/etc/os-release"
        blockLoading: true
    }

    FileView {
        id: hostFile
        path: "/proc/sys/kernel/hostname"
        blockLoading: true
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        blockLoading: true
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeFile.reload()
    }

    Process {
        id: picker
        command: ["zenity", "--file-selection", "--title=Choose a profile picture",
                  "--file-filter=Images | *.png *.jpg *.jpeg *.webp"]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() !== "") root.setAvatar(text.trim())
        }
    }

    Process {
        id: copier
        onExited: {
            root.avatarVersion++;
            avatarCheck.running = true;
        }
    }

    Process {
        id: avatarCheck
        running: true
        command: ["test", "-f", root.avatarPath]
        onExited: code => root.hasAvatar = code === 0
    }
}
