import QtQuick
import Quickshell
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Cookie12Sided"
    property real baseSize: 220
    property string colorRole: "primary"
    property bool showSeconds: true
    property bool showDate: true
    property bool showNumbers: false
    property bool live: true
    readonly property var colors: Widgets.palette(colorRole)

    property real size: baseSize

    Behavior on size {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    implicitWidth: size
    implicitHeight: size

    readonly property date now: clock.date
    readonly property real ticks: Math.floor((now.getTime() - now.getTimezoneOffset() * 60000) / 1000)
    readonly property real minuteTicks: Math.floor(ticks / 60)

    property real shownSecond: ticks * 6
    property real shownMinute: minuteTicks * 6
    property real shownHour: minuteTicks * 0.5

    Behavior on shownSecond {
        enabled: root.showSeconds
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    Behavior on shownMinute {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    Behavior on shownHour {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    readonly property real secondAngle: shownSecond % 360
    readonly property real minuteAngle: shownMinute % 360
    readonly property real hourAngle: shownHour % 360

    property int version: 0
    property bool ready: false
    property real innerTarget: 0.4
    property real innerRatio: innerTarget
    readonly property real inner: innerRatio * size

    Behavior on innerRatio {
        enabled: root.ready
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    function remeasure() {
        if (ref.width <= 0) return;
        let least = ref.width / 2;
        for (let a = 0; a < 360; a += 4) least = Math.min(least, ref.distanceAtAngle(a));
        innerTarget = Math.max(0.2, least / ref.width);
        version++;
        ready = true;
    }

    function edgeRatio(angle) {
        if (ref.width <= 0) return 0.4;
        return Math.min(ref.distanceAtAngle(angle) / ref.width, innerTarget * 1.25);
    }

    readonly property real handWidth: Math.max(4, size * 0.06)
    readonly property real dotSize: Math.max(6, size * 0.06)
    readonly property real numberSize: Math.max(8, size * 0.075)

    readonly property string datePosition: {
        const h = hourAngle * Math.PI / 180;
        const m = minuteAngle * Math.PI / 180;
        const top = Math.max(0, Math.cos(h)) + Math.max(0, Math.cos(m));
        const bottom = Math.max(0, -Math.cos(h)) + Math.max(0, -Math.cos(m));
        const right = Math.max(0, Math.sin(h)) + Math.max(0, Math.sin(m));
        const left = Math.max(0, -Math.sin(h)) + Math.max(0, -Math.sin(m));
        const least = Math.min(top, bottom, left, right);
        if (least === bottom) return "bottom";
        if (least === top) return "top";
        if (least === right) return "right";
        return "left";
    }

    SystemClock {
        id: clock
        enabled: root.live
        precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    MaterialShape {
        id: face
        anchors.fill: parent
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Cookie12Sided
        color: root.colors.fill
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot

    }

    MaterialShape {
        id: ref
        width: 200
        height: 200
        visible: false
        shape: face.shape
        animationDuration: 0

        onShapeChanged: Qt.callLater(root.remeasure)
        Component.onCompleted: Qt.callLater(root.remeasure)
    }

    Repeater {
        model: root.showNumbers ? 12 : 0

        Text {
            required property int index
            readonly property real angle: (index + 1) * 30
            property real ratio: (root.version, root.edgeRatio(angle))
            readonly property real distance: ratio * root.size - root.numberSize * 1.1

            Behavior on ratio {
                enabled: root.ready
                NumberAnimation {
                    duration: Theme.anim.slow
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.emphasizedDecel
                }
            }

            x: root.width / 2 + distance * Math.sin(angle * Math.PI / 180) - width / 2
            y: root.height / 2 - distance * Math.cos(angle * Math.PI / 180) - height / 2
            text: index + 1
            font.family: Theme.font.family
            font.pixelSize: root.numberSize
            font.weight: Font.DemiBold
            color: Qt.alpha(root.colors.text, 0.7)
        }
    }

    Text {
        id: dateText

        readonly property real reach: root.inner * 0.5
        property real dirX: root.datePosition === "left" ? -1 : root.datePosition === "right" ? 1 : 0
        property real dirY: root.datePosition === "top" ? -1 : root.datePosition === "bottom" ? 1 : 0

        visible: root.showDate
        x: root.width / 2 - width / 2 + dirX * reach
        y: root.height / 2 - height / 2 + dirY * reach
        text: root.now.toLocaleString(Qt.locale("en_US"), "ddd d")
        font.family: Theme.font.family
        font.pixelSize: root.numberSize
        font.weight: Font.DemiBold
        color: root.colors.text

        Behavior on dirX {
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
        Behavior on dirY {
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
    }

    Rectangle {
        id: hourHand

        readonly property real length: root.inner * 0.55

        x: root.width / 2 - width / 2
        y: root.height / 2 - length
        width: root.handWidth
        height: length + width / 2
        radius: width / 2
        color: root.colors.text
        antialiasing: true

        transform: Rotation {
            origin.x: hourHand.width / 2
            origin.y: hourHand.length
            angle: root.hourAngle
        }
    }

    Rectangle {
        id: minuteHand

        readonly property real length: root.inner * 0.82

        x: root.width / 2 - width / 2
        y: root.height / 2 - length
        width: root.handWidth
        height: length + width / 2
        radius: width / 2
        color: Qt.alpha(root.colors.text, 0.6)
        antialiasing: true

        transform: Rotation {
            origin.x: minuteHand.width / 2
            origin.y: minuteHand.length
            angle: root.minuteAngle
        }
    }

    Rectangle {
        id: secondDot

        readonly property real distance: Math.max(root.inner * 0.5, (face.width > 0 ? face.distanceAtAngle(root.secondAngle) : root.inner) - root.dotSize * 1.4)

        visible: root.showSeconds
        x: root.width / 2 + distance * Math.sin(root.secondAngle * Math.PI / 180) - width / 2
        y: root.height / 2 - distance * Math.cos(root.secondAngle * Math.PI / 180) - height / 2
        width: root.dotSize
        height: width
        radius: width / 2
        color: root.colors.text
    }
}
