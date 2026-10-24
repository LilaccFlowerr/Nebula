import QtQuick
import Quickshell
import M3Shapes
import qs.components
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
    property string tickStyle: "hours"
    readonly property bool showTicks: tickStyle !== "off"
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

    function edgeFrame(angle) {
        if (!ready) {
            const a = angle * Math.PI / 180;
            return { x: size / 2 + 0.4 * size * Math.sin(a), y: size / 2 - 0.4 * size * Math.cos(a), nx: Math.sin(a), ny: -Math.cos(a) };
        }
        const k = size / ref.width;
        const before = ref.pointAtAngle(angle - 1.5);
        const after = ref.pointAtAngle(angle + 1.5);
        const edge = ref.pointAtAngle(angle);
        const tx = after.x - before.x;
        const ty = after.y - before.y;
        const length = Math.hypot(tx, ty) || 1;
        return {
            x: size / 2 + (edge.x - ref.width / 2) * k,
            y: size / 2 + (edge.y - ref.height / 2) * k,
            nx: ty / length,
            ny: -tx / length
        };
    }

    function edgeRatio(angle) {
        if (!ready) return 0.4;
        return Math.min(ref.distanceAtAngle(angle) / ref.width, innerTarget * 1.25);
    }

    readonly property real handWidth: Math.max(4, size * 0.06)
    readonly property real dotSize: Math.max(6, size * 0.06)
    readonly property real numberSize: Math.max(8, size * 0.075)
    readonly property real tickInset: showTicks ? size * 0.075 : 0
    readonly property real numberDistance: inner - numberSize * 1.1 - tickInset

    SystemClock {
        id: clock
        enabled: root.live
        precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    GlassShape {
        id: face
        anchors.fill: parent
        shape: MaterialShape[root.shapeName] ?? MaterialShape.Cookie12Sided
        fill: root.colors.fill
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
        model: root.tickStyle === "all" ? 60 : root.tickStyle === "hours" ? 12 : 0

        Rectangle {
            required property int index
            readonly property real angle: index * (root.tickStyle === "all" ? 6 : 30)
            readonly property bool major: root.tickStyle === "hours" || index % 5 === 0
            readonly property var frame: (root.version, root.edgeFrame(angle))
            readonly property real length: root.size * (major ? 0.07 : 0.035)
            readonly property real reach: root.size * 0.03 + length / 2

            property real ex: frame.x
            property real ey: frame.y
            property real nx: frame.nx
            property real ny: frame.ny

            Behavior on ex { enabled: root.ready; NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel } }
            Behavior on ey { enabled: root.ready; NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel } }
            Behavior on nx { enabled: root.ready; NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel } }
            Behavior on ny { enabled: root.ready; NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel } }

            x: ex - nx * reach - width / 2
            y: ey - ny * reach - height / 2
            width: Math.max(major ? 2.5 : 1.5, root.size * (major ? 0.014 : 0.008))
            height: length
            radius: width / 2
            rotation: Math.atan2(nx, -ny) * 180 / Math.PI
            antialiasing: true
            color: Qt.alpha(root.colors.text, major ? 0.9 : 0.4)
        }
    }

    Repeater {
        model: root.showNumbers ? 12 : 0

        Text {
            required property int index
            readonly property real angle: (index + 1) * 30
            readonly property real distance: root.numberDistance

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

        property real sideRatio: (root.version, root.edgeRatio(180))
        readonly property real free: root.showNumbers ? root.numberDistance - root.numberSize * 0.9 : sideRatio * root.size - root.tickInset - root.size * 0.05
        readonly property real reach: Math.max(0, Math.min(root.inner * 0.5, Math.sqrt(Math.max(0, free * free - width * width / 4)) - height / 2))

        Behavior on sideRatio {
            enabled: root.ready
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        visible: root.showDate
        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2 + reach
        text: root.now.toLocaleString(Qt.locale("en_US"), "ddd d")
        font.family: Theme.font.family
        font.pixelSize: root.numberSize
        font.weight: Font.DemiBold
        color: root.colors.text
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

        readonly property real distance: Math.max(root.inner * 0.5, (root.ready && face.width > 0 ? face.distanceAtAngle(root.secondAngle) : root.inner) - root.dotSize * 1.4 - root.tickInset)

        visible: root.showSeconds
        x: root.width / 2 + distance * Math.sin(root.secondAngle * Math.PI / 180) - width / 2
        y: root.height / 2 - distance * Math.cos(root.secondAngle * Math.PI / 180) - height / 2
        width: root.dotSize
        height: width
        radius: width / 2
        color: root.colors.text
    }
}
