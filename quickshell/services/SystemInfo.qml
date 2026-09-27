// Info about this machine: OS (for the logo), user and host.
// Usage: import qs.services  →  SystemInfo.osLogo, SystemInfo.user, SystemInfo.host

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string user: Quickshell.env("USER")
    readonly property string host: hostFile.text().trim().split(".")[0]   // "laptop.home.lan" → "laptop"

    // ID= from /etc/os-release, e.g. "fedora"
    readonly property string osId: {
        const match = osRelease.text().match(/^ID="?([^"\n]+)"?$/m);
        return match ? match[1] : "linux";
    }

    // Nerd Font glyph for the OS (Theme.font.logos)
    readonly property string osLogo: ({
        "fedora": "",
        "arch": "",
        "ubuntu": "",
        "debian": "",
        "nixos": "",
        "opensuse-tumbleweed": "",
        "linuxmint": "",
        "pop": "",
    })[osId] ?? ""   // Tux as fallback

    FileView {
        id: osRelease
        path: "/etc/os-release"
        blockLoading: true   // tiny file, read it right away
    }

    FileView {
        id: hostFile
        path: "/proc/sys/kernel/hostname"   // /etc/hostname can be empty (hostname from DHCP)
        blockLoading: true
    }
}
