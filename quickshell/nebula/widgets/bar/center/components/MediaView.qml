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
    property int cardWidth: 500

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool expanded: GlobalStates.mediaExpanded && GlobalStates.isOn(screenName) && Media.active
    readonly property bool resizing: row.resizing

    implicitWidth: expanded ? cardWidth + Theme.spacing.lg * 2 : row.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: expanded ? card.implicitHeight + Theme.spacing.lg * 2 : Theme.button.size

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

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: root.expanded && !GlobalStates.capturing
        onCleared: GlobalStates.mediaExpanded = false
    }

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
        visible: !root.expanded
        opacity: Theme.visualizer.pillOpacity
        barWidth: Theme.visualizer.barWidth
        count: Cava.bars
        values: Cava.values
    }

    Visualizer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.lg
        height: Theme.visualizer.cardHeight
        opacity: root.expanded ? Theme.visualizer.pillOpacity : 0
        visible: opacity > 0
        barWidth: Theme.visualizer.barWidth
        count: Cava.bars
        values: Cava.values

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.expanded
        cursorShape: Qt.PointingHandCursor
        onClicked: GlobalStates.toggleMedia(root.screenName)
    }

    MediaRow {
        id: row
        anchors.centerIn: parent
        opacity: root.expanded ? 0 : 1
        maxTextWidth: root.textWidth
        waveWidth: root.waveWidth
        trackTitle: root.shownTitle
        trackArtist: root.shownArtist
        slide: root.skipSlide
        fade: root.skipFade

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }

    MediaCard {
        id: card
        expanded: root.expanded
        trackTitle: root.shownTitle
        trackArtist: root.shownArtist
        slide: root.skipSlide
        fade: root.skipFade
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.spacing.lg
        width: root.cardWidth
    }

    ClippingRectangle {
        id: art

        property real t: root.expanded ? 1 : 0

        Behavior on t {
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }

        readonly property real smallX: row.x + row.artSlot.x
        readonly property real smallY: row.y + row.artSlot.y
        readonly property real bigX: card.x + card.artX
        readonly property real bigY: card.y + card.artY

        x: smallX + (bigX - smallX) * t
        y: smallY + (bigY - smallY) * t
        width: row.artSlot.width + (card.artSlot.width - row.artSlot.width) * t
        height: width
        radius: Theme.radius.small + (Theme.radius.medium - Theme.radius.small) * t
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

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                GlobalStates.mediaExpanded = false;
                Media.raise();
            }
        }
    }
}
