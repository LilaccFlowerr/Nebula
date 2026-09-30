import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

RowLayout {
    readonly property alias artSlot: artSlot

    spacing: Theme.spacing.sm

    Item {
        id: artSlot
        visible: Media.active
        implicitWidth: Theme.bar.eventArtSize
        implicitHeight: Theme.bar.eventArtSize
    }

    Text {
        text: Audio.icon
        font.family: Theme.font.icons
        font.pixelSize: Theme.button.iconSize
        color: Colors.textOnSurface
    }

    Slider {
        implicitWidth: 140
        value: Audio.volume
        onMoved: Audio.setVolume(value)
    }

    Text {
        Layout.preferredWidth: 32
        horizontalAlignment: Text.AlignRight
        text: Audio.percent + "%"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        color: Colors.textOnSurface
    }
}
