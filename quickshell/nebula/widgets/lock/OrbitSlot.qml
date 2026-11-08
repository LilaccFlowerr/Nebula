import QtQuick
import qs.theme

SpiralSlot {
    id: root

    property real centerX: 0
    property real centerY: 0
    property real radiusX: 0
    property real radiusY: 0
    property real phase: 0
    property real seconds: 0
    property int slotIndex: 0
    property int total: 1

    property real settle: 0
    property real idleWidth: 0
    property real idleHeight: 0
    property real layoutWidth: 0
    property real layoutHeight: 0
    property real layoutX: 0
    property real layoutY: 0

    property real offset: slotIndex / Math.max(1, total) * Math.PI * 2

    Behavior on offset {
        NumberAnimation {
            duration: Theme.anim.slow * 2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    readonly property real angle: phase + offset
    readonly property real depth: Math.sin(angle)
    readonly property real bobY: Math.sin(seconds * Math.PI * 2 / Theme.lock.bobPeriod + slotIndex * 1.7) * Theme.lock.bob
    readonly property real held: Math.max(0, Math.min(1, settle))
    readonly property real orbitTargetX: centerX + Math.cos(angle) * radiusX
    readonly property real orbitTargetY: centerY + Math.sin(angle) * radiusY + bobY

    originX: centerX
    originY: centerY
    targetX: orbitTargetX + (layoutX - orbitTargetX) * settle
    targetY: orbitTargetY + (layoutY - orbitTargetY) * settle
    width: idleWidth + (layoutWidth - idleWidth) * settle
    height: idleHeight + (layoutHeight - idleHeight) * settle
    depthScale: (1 - Theme.lock.depthScale * (1 - depth) / 2) * (1 - held) + held
    depthOpacity: (1 - Theme.lock.depthOpacity * (1 - depth) / 2) * (1 - held) + held
    z: 10 + depth * (1 - held)
}
