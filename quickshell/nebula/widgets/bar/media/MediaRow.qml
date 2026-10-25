import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

RowLayout {
    id: root

    property int maxTextWidth: 220
    property int waveWidth: 200
    property string trackTitle: ""
    property string trackArtist: ""
    property real slide: 0
    property real fade: 1
    readonly property alias artSlot: artSlot
    readonly property bool resizing: textWidthAnim.running

    spacing: Theme.spacing.sm

    property real textWidth: Media.playing ? maxTextWidth
        : Math.min(maxTextWidth, Math.max(title.implicitWidth, artist.implicitWidth))

    Behavior on textWidth {
        NumberAnimation {
            id: textWidthAnim
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    Item {
        id: artSlot
        implicitWidth: 28
        implicitHeight: 28
    }

    ColumnLayout {
        Layout.preferredWidth: root.textWidth
        spacing: 0
        opacity: root.fade
        transform: Translate { x: root.slide }

        Text {
            id: title
            Layout.maximumWidth: root.textWidth
            elide: Text.ElideRight
            text: root.trackTitle
            color: Colors.textOnSurface
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
        }

        Text {
            id: artist
            Layout.maximumWidth: root.textWidth
            elide: Text.ElideRight
            text: root.trackArtist
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    WavyProgress {
        implicitWidth: root.waveWidth
        progress: Media.progress
        animated: Media.playing
    }
}
