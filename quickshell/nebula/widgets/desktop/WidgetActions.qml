import QtQuick
import qs.theme

Item {
    id: root

    property var actions: []
    property int hovered: -1
    property int holding: -1
    property real holdProgress: 0
    readonly property int holdDuration: 700
    readonly property real gap: 3
    readonly property real wide: 2.6
    readonly property real outer: height / 2
    readonly property real inner: 6

    property real total: actions.length + (hovered >= 0 ? wide - 1 : 0)

    signal triggered(string key)

    component Face: Row {
        id: face

        property string icon
        property string text
        property real reveal
        property real progress
        property color fg

        spacing: Theme.spacing.xs * reveal

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: face.icon
            color: face.fg
            font.family: Theme.font.icons
            font.pixelSize: 20
            scale: 1 + 0.2 * face.progress
            rotation: Math.sin(face.progress * Math.PI * 6) * 10 * face.progress
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: label.implicitWidth * face.reveal
            height: label.implicitHeight
            clip: true

            Text {
                id: label
                text: face.text
                color: face.fg
                opacity: face.reveal
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
                font.weight: Font.DemiBold
            }
        }
    }

    implicitHeight: 44

    Behavior on total {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    NumberAnimation {
        id: holdAnim
        target: root
        property: "holdProgress"
        to: 1
        duration: root.holdDuration * (1 - root.holdProgress)
        onFinished: {
            if (root.holdProgress < 1) return;
            const key = root.actions[root.holding]?.key ?? "";
            root.holding = -1;
            root.holdProgress = 0;
            if (key !== "") root.triggered(key);
        }
    }

    NumberAnimation {
        id: releaseAnim
        target: root
        property: "holdProgress"
        to: 0
        duration: Theme.anim.fast
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.standard
        onFinished: root.holding = -1
    }

    HoverHandler {
        onHoveredChanged: if (!hovered) root.hovered = -1
    }

    Row {
        anchors.fill: parent
        spacing: root.gap

        Repeater {
            model: root.actions

            Rectangle {
                id: button

                required property var modelData
                required property int index

                readonly property bool hot: root.hovered === index
                readonly property bool first: index === 0
                readonly property bool last: index === root.actions.length - 1
                readonly property real progress: root.holding === index ? root.holdProgress : 0

                property real weight: hot ? root.wide : 1
                property real round: hot ? 1 : 0
                property real reveal: hot ? 1 : 0

                Behavior on weight {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                }
                Behavior on round {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                }
                Behavior on reveal {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                }

                function corner(isOuter) {
                    const base = isOuter ? root.outer : root.inner;
                    const pressed = mouse.pressed ? 0.6 : 1;
                    return (base + (root.outer - base) * round) * pressed;
                }

                width: (root.width - root.gap * (root.actions.length - 1)) * weight / root.total
                height: root.height
                topLeftRadius: corner(first)
                bottomLeftRadius: corner(first)
                topRightRadius: corner(last)
                bottomRightRadius: corner(last)
                color: hot ? (modelData.danger ? Colors.errorContainer : Colors.secondaryContainer) : Colors.surfaceContainerHighest

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }

                Face {
                    anchors.centerIn: parent
                    icon: button.modelData.icon
                    text: button.progress > 0 ? "Keep holding" : button.modelData.text
                    reveal: button.reveal
                    progress: button.progress
                    fg: button.modelData.danger ? (button.hot ? Colors.textOnErrorContainer : Colors.errorColor)
                        : button.hot ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                }

                Rectangle {
                    id: fill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * button.progress
                    visible: button.progress > 0
                    clip: true
                    topLeftRadius: parent.topLeftRadius
                    bottomLeftRadius: parent.bottomLeftRadius
                    topRightRadius: Math.min(parent.topRightRadius, width / 2)
                    bottomRightRadius: Math.min(parent.bottomRightRadius, width / 2)
                    color: Colors.errorColor

                    Face {
                        x: (button.width - width) / 2
                        y: (button.height - height) / 2
                        icon: button.modelData.icon
                        text: "Keep holding"
                        reveal: button.reveal
                        progress: button.progress
                        fg: Colors.textOnError
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: if (containsMouse) root.hovered = button.index
                    onPressed: {
                        if (!button.modelData.hold) return;
                        releaseAnim.stop();
                        root.holding = button.index;
                        holdAnim.restart();
                    }
                    onReleased: {
                        if (!button.modelData.hold || root.holding !== button.index) return;
                        holdAnim.stop();
                        releaseAnim.restart();
                    }
                    onClicked: if (!button.modelData.hold) root.triggered(button.modelData.key)
                }
            }
        }
    }
}
