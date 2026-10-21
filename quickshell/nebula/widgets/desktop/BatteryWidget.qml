import QtQuick
import QtQuick.Shapes
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property string shapeName: "Cookie12Sided"
    property real baseSize: 200
    property string colorRole: "secondary"
    readonly property var colors: Widgets.palette(colorRole)
    readonly property real gap: 14

    property real size: baseSize

    Behavior on size {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    readonly property real level: Battery.available ? Battery.level : 0
    property real shownLevel: level

    Behavior on shownLevel {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    readonly property bool critical: Battery.available && level <= Settings.power.lowBattery / 100
    readonly property bool halfway: Battery.available && level <= 0.5
    property color accent: !Battery.available ? Colors.outline : critical ? Colors.errorColor : halfway ? Colors.tertiary : Colors.primary

    Behavior on accent {
        ColorAnimation { duration: Theme.anim.medium }
    }

    property real innerTarget: 0.4
    property real innerRatio: innerTarget
    property bool ready: false

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
        ready = true;
    }

    readonly property real ringWidth: size * 0.07
    readonly property real ringRadius: Math.min(size * 0.37, innerRatio * size - ringWidth / 2 - size * 0.04)
    readonly property real sweep: Math.min(360, 360 * shownLevel)
    readonly property real trackSweep: Math.max(0, 360 - sweep - gap * 2)

    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        if (minutes < 1) return "";
        return minutes >= 60 ? Math.floor(minutes / 60) + "h " + (minutes % 60) + "m" : minutes + "m";
    }

    readonly property string status: {
        if (!Battery.available) return "No battery";
        if (Battery.full) return "Full";
        const time = duration(Battery.charging ? Battery.timeToFull : Battery.timeToEmpty);
        if (Battery.charging) return time !== "" ? time + " to full" : "Charging";
        if (Battery.pluggedIn) return "Plugged in";
        return time !== "" ? time + " left" : "On battery";
    }

    implicitWidth: size
    implicitHeight: size

    MaterialShape {
        id: body
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
        shape: body.shape
        animationDuration: 0

        onShapeChanged: Qt.callLater(root.remeasure)
        Component.onCompleted: Qt.callLater(root.remeasure)
    }

    Shape {
        anchors.fill: parent
        visible: Battery.available
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.ringWidth
            strokeColor: root.accent
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90
                sweepAngle: Math.max(0.5, root.sweep)
            }
        }

        ShapePath {
            strokeWidth: root.trackSweep > 0 ? root.ringWidth : 0
            strokeColor: Qt.alpha(root.colors.text, 0.2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.size / 2
                centerY: root.size / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90 + root.sweep + root.gap
                sweepAngle: root.trackSweep
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: root.ringRadius * 0.03

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Battery.available
            spacing: root.ringRadius * 0.03

            Text {
                text: Battery.percent
                font.family: Theme.font.family
                font.pixelSize: root.ringRadius * (Battery.percent >= 100 ? 0.62 : 0.8)
                font.weight: Font.DemiBold
                color: root.colors.text
            }

            Text {
                anchors.top: parent.top
                anchors.topMargin: root.ringRadius * 0.12
                text: "%"
                font.family: Theme.font.family
                font.pixelSize: root.ringRadius * 0.27
                font.weight: Font.Medium
                color: root.colors.text
                opacity: 0.8
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: statusRow.implicitWidth + root.ringRadius * 0.24
            implicitHeight: statusRow.implicitHeight + root.ringRadius * 0.1
            radius: height / 2
            color: Qt.alpha(root.colors.text, 0.16)

            Row {
                id: statusRow
                anchors.centerIn: parent
                spacing: root.ringRadius * 0.05

                Text {
                    visible: Battery.charging
                    text: "bolt"
                    font.family: Theme.font.icons
                    font.pixelSize: root.ringRadius * 0.26
                    color: root.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    width: Math.min(implicitWidth, root.ringRadius * 0.95)
                    text: root.status
                    elide: Text.ElideRight
                    font.family: Theme.font.family
                    font.pixelSize: root.ringRadius * (Battery.available ? 0.19 : 0.3)
                    font.weight: Font.Medium
                    color: root.colors.text
                }
            }
        }
    }
}
