import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

RowLayout {
    id: root

    property string kind: "volume"
    readonly property bool brightness: kind === "brightness"
    readonly property alias artSlot: artSlot

    spacing: Theme.spacing.sm

    Item {
        id: artSlot
        visible: Media.active
        implicitWidth: Theme.bar.eventArtSize
        implicitHeight: Theme.bar.eventArtSize
    }

    Text {
        text: !root.brightness ? Audio.icon
            : Brightness.level < 0.34 ? "brightness_low"
            : Brightness.level < 0.67 ? "brightness_medium"
            : "brightness_high"
        font.family: Theme.font.icons
        font.pixelSize: Theme.button.iconSize
        color: Colors.textOnSurface
    }

    Slider {
        implicitWidth: 140
        value: root.brightness ? Brightness.level : Audio.volume
        onMoved: root.brightness ? Brightness.setBrightness(value) : Audio.setVolume(value)
    }

    Text {
        Layout.preferredWidth: 32
        horizontalAlignment: Text.AlignRight
        text: (root.brightness ? Brightness.percent : Audio.percent) + "%"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        color: Colors.textOnSurface
    }
}
