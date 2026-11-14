import QtQuick
import QtQuick.Effects
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Cookie4Sided"
    property real baseSize: 520
    property string colorRole: "primary"
    property string backdrop: "none"
    property bool live: true

    property real size: baseSize

    readonly property bool pill: backdrop === "pill"
    readonly property var palette: Widgets.palette(colorRole)
    readonly property var roles: ({ primary: Colors.primary, secondary: Colors.secondary, tertiary: Colors.tertiary, surface: Colors.textOnSurface })
    readonly property color fill: roles[colorRole] ?? Colors.primary
    readonly property color accent: colorRole === "tertiary" ? Colors.primary : Colors.tertiary
    readonly property var shapes: [shapeName, "Cookie6Sided", "Cookie7Sided", "Cookie9Sided", "Cookie12Sided"]

    readonly property bool synced: Media.active && Lyrics.synced
    readonly property bool demo: Widgets.editing && !synced
    readonly property var demoLines: [
        { time: 0, text: "" },
        { time: 2, text: "This is where the words go" },
        { time: 5, text: "Sung along as the music plays" },
        { time: 8, text: "Drag me where you like" },
        { time: 11, text: "" }
    ]
    readonly property var lines: demo ? demoLines : synced ? Lyrics.lines : []
    readonly property bool paused: synced && !demo && !Media.playing

    property real time: 0

    readonly property int index: {
        let found = -1;
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].time <= time) found = i;
            else break;
        }
        return found;
    }
    readonly property var current: Lyrics.timing(lines, index)
    readonly property real sungUntil: current.length > 0 ? current[current.length - 1].end : 0
    readonly property real nextAt: lines[index + 1]?.time ?? Infinity
    readonly property bool waiting: lines.length > 0 && (current.length === 0 || (time > sungUntil + 1.5 && nextAt - time > 2.5))
    readonly property int beat: Math.floor(time * 1.5) % 3

    readonly property real big: size * 0.085
    readonly property real shrink: 0.58
    readonly property real step: big * 1.25
    readonly property Item nowItem: slots.count > 0 ? slots.itemAt(((index % 5) + 5) % 5) : null
    readonly property real nowWidth: waiting || !nowItem ? dots.width : nowItem.shownWidth

    implicitWidth: size
    implicitHeight: size * (Widgets.types.lyrics.aspect ?? 0.46)

    Behavior on size {
        enabled: !Widgets.resizing
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    FrameAnimation {
        running: root.live && (root.demo || (root.synced && Media.playing))
        onTriggered: {
            if (root.demo) {
                root.time = (root.time + frameTime) % 12;
                return;
            }
            const off = Lyrics.clock() - root.time;
            root.time = Math.abs(off) > 1 ? root.time + off : root.time + frameTime + off * Math.min(1, frameTime * 2);
        }
    }

    Connections {
        target: Lyrics

        function onPositionChanged() {
            if (!root.demo && !Media.playing) root.time = Lyrics.position;
        }
    }

    GlassRect {
        x: (root.width - width) / 2
        y: stage.middle - height / 2
        width: root.nowWidth + root.big * 1.4
        height: root.big * 1.7
        radius: height / 2
        fill: root.palette.fill
        light: 0
        visible: opacity > 0
        opacity: root.pill && root.lines.length > 0 ? (root.paused ? 0.6 : 1) : 0

        Behavior on width {
            NumberAnimation {
                duration: Theme.anim.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.emphasizedDecel
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }
    }

    Item {
        id: stage

        readonly property real middle: height * 0.48

        anchors.fill: parent
        opacity: root.paused ? 0.45 : 1
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Colors.scrim
            shadowOpacity: 0.9
            shadowBlur: 0.7
            shadowVerticalOffset: 2
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }

        Repeater {
            id: slots

            model: 5

            LyricsLine {
                id: slot

                required property int index
                readonly property int line: root.index - 2 + ((((index - (root.index - 2)) % 5) + 5) % 5)
                readonly property int role: line - root.index
                readonly property bool now: role === 0
                readonly property real fit: Math.min(1, root.width * 0.92 / Math.max(1, implicitWidth * (now ? 1 : root.shrink)))
                readonly property real shownWidth: implicitWidth * fit

                words: Lyrics.timing(root.lines, line)
                time: root.time
                size: root.big
                singing: now
                sung: role < 0
                marker: now && !root.waiting
                ink: root.pill && now ? Qt.alpha(root.palette.text, 0.45) : "white"
                fill: root.pill && now ? root.palette.text : root.fill
                markerColor: root.accent
                markerShape: root.shapeName

                x: (stage.width - width) / 2
                y: stage.middle + role * root.step * (Math.abs(role) > 1 ? 0.8 : 1) - height / 2
                scale: (now ? 1 : root.shrink) * fit
                rotation: role === 1 ? -2 : 0
                opacity: now ? (root.waiting ? 0 : 1) : role === -1 ? 0.45 : role === 1 ? 0.65 : 0
                visible: opacity > 0

                Behavior on y {
                    NumberAnimation {
                        duration: Theme.anim.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.emphasizedDecel
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.anim.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.emphasizedDecel
                    }
                }

                Behavior on rotation {
                    NumberAnimation {
                        duration: Theme.anim.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.emphasizedDecel
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.medium
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.standard
                    }
                }
            }
        }

        Row {
            id: dots

            x: (stage.width - width) / 2
            y: stage.middle - height / 2
            visible: opacity > 0
            opacity: root.waiting ? 1 : 0
            spacing: root.big * 0.4

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.medium }
            }

            Repeater {
                model: 3

                MaterialShape {
                    required property int index
                    readonly property bool lit: root.beat === index

                    implicitSize: root.big * 0.7
                    shape: MaterialShape[root.shapes[index % root.shapes.length]] ?? MaterialShape.Cookie4Sided
                    color: lit ? (root.pill ? root.palette.text : root.fill) : Qt.rgba(1, 1, 1, 0.4)
                    scale: lit ? 1.25 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.anim.medium
                            easing.type: Easing.OutBack
                            easing.overshoot: Theme.anim.overshoot
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.medium }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.big * 0.2
            visible: !root.demo && Media.active
            text: Media.title + (Media.artist !== "" ? " · " + Media.artist : "") + (root.synced || Lyrics.status === "loading" ? "" : " · no synced lyrics")
            width: Math.min(implicitWidth, root.width * 0.9)
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Math.max(11, root.size * 0.024)
            color: Qt.rgba(1, 1, 1, 0.75)
        }
    }
}
