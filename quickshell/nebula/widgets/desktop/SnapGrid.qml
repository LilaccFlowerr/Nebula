import QtQuick
import Quickshell
import qs.services
import qs.theme

Item {
    id: root

    required property string screenName
    readonly property bool lifted: WidgetSnap.dragging && WidgetSnap.screen === screenName
    readonly property bool shown: Settings.widgets.grid && (lifted || Widgets.editing)
    property real lens: lifted ? Theme.snap.lensSize : Theme.snap.dotSize

    Behavior on lens {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }
    readonly property real span: Math.hypot(width, height) + Theme.snap.waveBand * 3
    property real reveal: 0

    opacity: shown ? 1 : 0
    onShownChanged: if (shown) ripple.restart()

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    NumberAnimation {
        id: ripple
        target: root
        property: "reveal"
        from: 0
        to: root.span
        duration: Theme.snap.revealDuration * Theme.anim.scale
        easing.type: Easing.OutCubic
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.scrim
        opacity: Widgets.editing ? 0 : Theme.snap.gridDim
    }

    Loader {
        anchors.fill: parent
        active: root.shown || root.opacity > 0

        sourceComponent: ShaderEffect {
            readonly property real cell: Theme.snap.cell
            readonly property real base: Theme.snap.dotSize
            readonly property real grown: root.lens
            readonly property real reach: Theme.snap.lensReach
            readonly property real reveal: root.reveal
            readonly property real band: Theme.snap.waveBand
            readonly property real rest: Theme.snap.gridOpacity
            readonly property vector2d area: Qt.vector2d(width, height)
            readonly property vector2d origin: Qt.vector2d(WidgetSnap.focusX, WidgetSnap.focusY)
            readonly property color tint: Colors.primary
            readonly property color shade: Qt.alpha(Colors.scrim, Theme.snap.haloOpacity)
            readonly property real halo: Theme.snap.haloSize

            fragmentShader: "file://" + Quickshell.shellPath("shaders/snapgrid.frag.qsb")
        }
    }
}
