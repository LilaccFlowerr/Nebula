import QtQuick
import QtQuick.Layouts
import qs.services
import qs.theme

RowLayout {
    id: root

    property string event: ""
    readonly property alias artSlot: artSlot
    readonly property color accent: event === "low" ? Colors.errorColor
                                  : event === "charging" ? Colors.primary
                                  : Colors.textOnSurface

    spacing: Theme.spacing.sm

    Item {
        id: artSlot
        visible: Media.active
        implicitWidth: Theme.bar.eventArtSize
        implicitHeight: Theme.bar.eventArtSize
    }

    Text {
        text: root.event === "charging" ? "bolt"
            : root.event === "low" ? "battery_alert"
            : "battery_full"
        font.family: Theme.font.icons
        font.pixelSize: Theme.button.iconSize
        color: root.accent
    }

    Text {
        text: root.event === "charging" ? "Charging"
            : root.event === "low" ? "Battery low"
            : "On battery"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        color: Colors.textOnSurface
    }

    Text {
        text: Battery.percent + "%"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        color: root.accent
    }
}
