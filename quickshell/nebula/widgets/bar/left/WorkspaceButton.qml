import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property int wsId: 1

    readonly property string style: Settings.bar.workspaceStyle
    readonly property bool active: Workspaces.activeId === root.wsId
    readonly property bool occupied: Workspaces.isOccupied(root.wsId)
    readonly property bool urgent: Workspaces.isUrgent(root.wsId)

    readonly property int ownShape: Theme.workspaces.shapes[(wsId - 1) % Theme.workspaces.shapes.length]
    property int activeShape: ownShape
    readonly property int shownShape: active ? activeShape : ownShape

    function pickShape() {
        const pool = Theme.workspaces.activeShapes.filter(s => s !== ownShape && s !== activeShape);
        activeShape = pool[Math.floor(Math.random() * pool.length)];
    }

    onActiveChanged: if (active) pickShape()
    Component.onCompleted: if (active) pickShape()

    implicitWidth: style !== "shapes" && active ? Theme.workspaces.activeWidth : Theme.button.size
    implicitHeight: Theme.button.size

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.style !== "shapes"
        radius: Theme.radius.full

        color: root.urgent   ? Colors.errorColor
             : root.active   ? Colors.primary
             : root.occupied ? Colors.surfaceContainerLow
             :                 Colors.surfaceContainer

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.slow
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.style === "numbers"
            text: root.wsId
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: root.active ? Colors.textOnPrimary : Colors.textOnSurface
            opacity: root.active || root.occupied ? 1 : 0.4
        }

        MaterialShape {
            anchors.centerIn: parent
            visible: root.style === "pills"
            implicitSize: Theme.workspaces.innerShapeSize
            shape: root.shownShape
            animationDuration: Theme.anim.slow
            animationEasing.type: Easing.BezierSpline
            animationEasing.bezierCurve: Theme.anim.emphasizedDecel
            color: root.active ? Colors.textOnPrimary : Colors.textOnSurface
            opacity: root.active || root.occupied ? 1 : 0.4
        }
    }

    MaterialShape {
        anchors.centerIn: parent
        visible: root.style === "shapes"
        implicitSize: root.active ? Theme.workspaces.activeShapeSize : Theme.workspaces.shapeSize
        shape: root.shownShape
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.BezierSpline
        animationEasing.bezierCurve: Theme.anim.emphasizedDecel

        color: root.urgent   ? Colors.errorColor
             : root.active   ? Colors.primary
             : root.occupied ? Colors.surfaceContainerHighest
             :                 Colors.surfaceContainerHigh

        Behavior on implicitSize {
            NumberAnimation {
                duration: Theme.anim.slow
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.emphasizedDecel
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.slow
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Workspaces.focus(root.wsId)
    }
}
