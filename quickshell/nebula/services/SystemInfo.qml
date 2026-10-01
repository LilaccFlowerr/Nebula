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

    readonly property string osLogo: ({
        "fedora": "",
        "arch": "",
        "ubuntu": "",
        "debian": "",
        "nixos": "",
        "opensuse-tumbleweed": "",
        "linuxmint": "",
        "pop": "",
    })[osId] ?? ""

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
