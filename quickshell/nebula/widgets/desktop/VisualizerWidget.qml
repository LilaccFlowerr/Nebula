import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property string colorRole: "primary"
    property real baseSize: 640
    property real aspect: Widgets.types.visualizer.aspect
    property string style: "bars"
    property string direction: "up"
    property bool mirror: false
    property bool live: true

    property real size: baseSize

    readonly property var roles: ({ primary: Colors.primary, secondary: Colors.secondary, tertiary: Colors.tertiary, surface: Colors.textOnSurface })
    readonly property bool wave: style === "wave"
    readonly property bool upright: direction === "left" || direction === "right"
    readonly property real along: upright ? height : width
    readonly property real across: upright ? width : height
    readonly property int bars: Math.max(4, Math.min(Theme.visWidget.maxBars, Math.floor((along + Theme.visWidget.gap) / (Theme.visWidget.barWidth + Theme.visWidget.gap))))

    implicitWidth: size
    implicitHeight: size * aspect

    Behavior on size {
        enabled: !Widgets.resizing
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    CavaVisualizer {
        anchors.fill: parent
        active: root.live
        previewDemo: Widgets.editing
        color: root.roles[root.colorRole] ?? Colors.primary
        vertical: root.upright
        alignment: root.mirror ? "center" : root.direction === "down" || root.direction === "right" ? "start" : "end"
        continuous: root.wave
        count: root.wave ? Theme.visWidget.wavePoints : root.bars
        rise: root.wave ? Theme.visWidget.waveRise : 1
        fall: root.wave ? Theme.visWidget.waveFall : 1
        maxLength: root.across * (root.wave ? Theme.visWidget.waveReach : Theme.visWidget.barReach)
        spacing: Theme.visWidget.gap
        minLength: Theme.visWidget.minLength
        radiusRatio: Theme.visWidget.radius
        opacityBase: Theme.visWidget.opacityBase
        opacityRange: Theme.visWidget.opacityRange
        edgeFade: true
    }
}
