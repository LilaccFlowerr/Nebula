import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property int textWidth: 220
    property int waveWidth: 200
    property real headerT: 0
    property real pop: 1

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool resizing: row.resizing
    readonly property alias row: row

    implicitWidth: row.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: Theme.button.size

    property bool holding: false
    property string heldTitle: ""
    property string heldArtist: ""
    property string heldArt: ""
    readonly property string shownTitle: Media.settling ? Media.lastTitle : holding ? heldTitle : Media.title
    readonly property string shownArtist: Media.settling ? Media.lastArtist : holding ? heldArtist : Media.artist
    readonly property string shownArt: Media.settling ? Media.lastArtUrl : holding ? heldArt : Media.artUrl

    property int skipDirection: 1
    property real skipSlide: 0
    property real skipFade: 1

    Connections {
        target: Media
        function onSkipped(direction) {
            root.heldTitle = Media.lastTitle;
            root.heldArtist = Media.lastArtist;
            root.heldArt = Media.lastArtUrl;
            root.holding = true;
            root.skipDirection = direction;
            skipAnim.restart();
        }
    }

    SequentialAnimation {
        id: skipAnim

        ParallelAnimation {
            NumberAnimation { target: root; property: "skipSlide"; to: -root.skipDirection * Theme.bar.skipSlide; duration: Theme.anim.fast; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "skipFade"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        }
        ScriptAction {
            script: {
                root.holding = false;
                root.skipSlide = root.skipDirection * Theme.bar.skipSlide;
            }
        }
        ParallelAnimation {
            NumberAnimation { target: root; property: "skipSlide"; to: 0; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            NumberAnimation { target: root; property: "skipFade"; to: 1; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
    }

    Image {
        visible: false
        source: Media.artUrl
        asynchronous: true
    }

    Visualizer {
        anchors.fill: parent
        anchors.leftMargin: parent.height / 2
        anchors.rightMargin: parent.height / 2
        opacity: Theme.visualizer.pillOpacity * (1 - root.headerT)
        barWidth: Theme.visualizer.barWidth
        count: Cava.bars
        values: Cava.values
    }

    MediaRow {
        extrasOpacity: 1 - root.headerT
        extrasScale: root.pop
        textOpacity: root.headerT > 0.001 ? 0 : 1
        id: row
        anchors.centerIn: parent
        maxTextWidth: root.textWidth
        waveWidth: root.waveWidth
        trackTitle: root.shownTitle
        trackArtist: root.shownArtist
        slide: root.skipSlide
        fade: root.skipFade
    }

    ClippingRectangle {
        id: art
        opacity: 1 - root.headerT
        visible: opacity > 0
        scale: root.pop

        x: row.x + row.artSlot.x
        y: row.y + row.artSlot.y
        width: row.artSlot.width
        height: width
        radius: Theme.radius.small
        color: Colors.surfaceContainerHigh

        Item {
            anchors.fill: parent
            opacity: root.skipFade
            transform: Translate { x: root.skipSlide / Theme.bar.skipSlide * art.width / 2 }

            Image {
                anchors.fill: parent
                source: root.shownArt
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: Media.playing ? 1 : 0.5

                Behavior on opacity {
                    NumberAnimation { duration: Theme.anim.medium }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "pause"
            font.family: Theme.font.icons
            font.pixelSize: 18
            color: Colors.textOnSurface
            opacity: Media.playing ? 0 : 1
            scale: Media.playing ? 0.6 : 1

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.medium }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.anim.medium
                    easing.type: Easing.OutBack
                }
            }
        }
    }
}
