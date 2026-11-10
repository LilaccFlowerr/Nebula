import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Scope {
    WlSessionLock {
        locked: Lock.wanted

        LockSurface {}
    }
}
