pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property bool isDark: adapter.isDark
    readonly property color primary: adapter.primary
    readonly property color textOnPrimary: adapter.textOnPrimary
    readonly property color primaryContainer: adapter.primaryContainer
    readonly property color textOnPrimaryContainer: adapter.textOnPrimaryContainer
    readonly property color secondary: adapter.secondary
    readonly property color textOnSecondary: adapter.textOnSecondary
    readonly property color secondaryContainer: adapter.secondaryContainer
    readonly property color textOnSecondaryContainer: adapter.textOnSecondaryContainer
    readonly property color tertiary: adapter.tertiary
    readonly property color textOnTertiary: adapter.textOnTertiary
    readonly property color tertiaryContainer: adapter.tertiaryContainer
    readonly property color textOnTertiaryContainer: adapter.textOnTertiaryContainer
    readonly property color errorColor: adapter.errorColor
    readonly property color textOnError: adapter.textOnError
    readonly property color errorContainer: adapter.errorContainer
    readonly property color textOnErrorContainer: adapter.textOnErrorContainer
    readonly property color surface: adapter.surface
    readonly property color surfaceContainerLowest: adapter.surfaceContainerLowest
    readonly property color surfaceContainerLow: adapter.surfaceContainerLow
    readonly property color surfaceContainer: adapter.surfaceContainer
    readonly property color surfaceContainerHigh: adapter.surfaceContainerHigh
    readonly property color surfaceContainerHighest: adapter.surfaceContainerHighest
    readonly property color textOnSurface: adapter.textOnSurface
    readonly property color textOnSurfaceVariant: adapter.textOnSurfaceVariant
    readonly property color outline: adapter.outline
    readonly property color outlineVariant: adapter.outlineVariant
    readonly property color shadow: adapter.shadow
    readonly property color scrim: adapter.scrim
    readonly property color inverseSurface: adapter.inverseSurface
    readonly property color inverseOnSurface: adapter.inverseOnSurface
    readonly property color inversePrimary: adapter.inversePrimary

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/nebula/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property bool isDark: true
            property string primary: "#91cef5"
            property string textOnPrimary: "#00344b"
            property string primaryContainer: "#004c6b"
            property string textOnPrimaryContainer: "#c6e7ff"
            property string secondary: "#b6c9d8"
            property string textOnSecondary: "#21333e"
            property string secondaryContainer: "#374955"
            property string textOnSecondaryContainer: "#d2e5f4"
            property string tertiary: "#ccc1e9"
            property string textOnTertiary: "#332c4b"
            property string tertiaryContainer: "#4a4263"
            property string textOnTertiaryContainer: "#e8deff"
            property string errorColor: "#ffb4ab"
            property string textOnError: "#690005"
            property string errorContainer: "#93000a"
            property string textOnErrorContainer: "#ffdad6"
            property string surface: "#0f1417"
            property string surfaceContainerLowest: "#0a0f12"
            property string surfaceContainerLow: "#181c1f"
            property string surfaceContainer: "#1c2024"
            property string surfaceContainerHigh: "#262b2e"
            property string surfaceContainerHighest: "#313539"
            property string textOnSurface: "#dfe3e7"
            property string textOnSurfaceVariant: "#c1c7ce"
            property string outline: "#8b9198"
            property string outlineVariant: "#41484d"
            property string shadow: "#000000"
            property string scrim: "#000000"
            property string inverseSurface: "#dfe3e7"
            property string inverseOnSurface: "#2c3135"
            property string inversePrimary: "#206487"
        }
    }
}
