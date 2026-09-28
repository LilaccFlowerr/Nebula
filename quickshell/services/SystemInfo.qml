pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string user: Quickshell.env("USER")
    readonly property string host: hostFile.text().trim().split(".")[0]

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
}
