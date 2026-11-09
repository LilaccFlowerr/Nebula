import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    signal submit()

    property real t: 0

    readonly property bool typing: Lock.typed > 0
    readonly property bool failed: Lock.failed && !typing
    readonly property var dotShapes: [MaterialShape.Cookie6Sided, MaterialShape.Clover4Leaf, MaterialShape.Flower, MaterialShape.Cookie9Sided, MaterialShape.Pentagon, MaterialShape.Sunny]
    readonly property var dotColors: [Colors.primary, Colors.tertiary, Colors.secondary]

    GlassRect {
        anchors.fill: parent
        radius: height / 2
        fill: Colors.surfaceContainerHigh
        tint: Theme.lock.surfaceTint
        light: 0
    }

    FrameAnimation {
        running: root.typing && root.visible
        onTriggered: root.t += frameTime
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "transparent"
        border.width: 1.5
        border.color: root.failed ? Colors.errorColor : root.typing || Lock.checking ? Qt.alpha(Colors.primary, 0.7) : Qt.alpha(Colors.textOnSurface, 0.06)

        Behavior on border.color {
            ColorAnimation { duration: Theme.anim.fast }
        }
    }

    Item {
        id: lockBox

        x: 6
        anchors.verticalCenter: parent.verticalCenter
        width: parent.height - 12
        height: width

        MaterialShape {
            id: lockShape

            anchors.fill: parent
            shape: root.failed ? MaterialShape.Pentagon
                : Lock.unlocking ? MaterialShape.Sunny
                : Lock.checking ? MaterialShape.Clover4Leaf
                : root.typing ? MaterialShape.Cookie12Sided
                : MaterialShape.Cookie9Sided
            color: root.failed ? Qt.alpha(Colors.errorColor, 0.28) : Qt.alpha(Colors.primary, 0.28)
            animationDuration: Theme.anim.slow

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 2400
                loops: Animation.Infinite
                running: Lock.checking || Lock.unlocking
            }
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            text: root.failed ? "lock_reset" : Lock.unlocking ? "lock_open" : "lock"
            font.family: Theme.font.icons
            font.pixelSize: 21
            color: root.failed ? Colors.errorColor : Colors.primary
        }
    }

    Item {
        anchors.left: lockBox.right
        anchors.leftMargin: 10
        anchors.right: button.left
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            visible: !root.typing && !Lock.checking
            text: root.failed ? Lock.message : "Enter password"
            font.family: Theme.font.family
            font.pixelSize: Theme.font.large
            font.weight: Font.Medium
            color: root.failed ? Colors.errorColor : Qt.alpha(Colors.textOnSurface, 0.55)
        }

        Row {
            anchors.centerIn: parent
            spacing: 3
            visible: root.typing || Lock.checking

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: Lock.checking
                NumberAnimation { to: 0.4; duration: 380; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 380; easing.type: Easing.InOutSine }
            }

            Repeater {
                model: Math.min(Lock.typed, Theme.lock.dotMax)

                Item {
                    id: piece

                    required property int index

                    width: 17
                    height: 17
                    scale: 0.5

                    Component.onCompleted: pop.start()

                    NumberAnimation {
                        id: pop

                        target: piece
                        property: "scale"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.5
                    }

                    MaterialShape {
                        y: Math.sin(root.t * 3.2 + piece.index * 0.8) * 2.5
                        width: parent.width
                        height: parent.height
                        rotation: root.t * 45 + piece.index * 40
                        shape: root.dotShapes[(Lock.typed - Math.min(Lock.typed, Theme.lock.dotMax) + piece.index) % root.dotShapes.length]
                        color: root.dotColors[(Lock.typed - Math.min(Lock.typed, Theme.lock.dotMax) + piece.index) % root.dotColors.length]
                    }
                }
            }

            Rectangle {
                width: 3
                height: 20
                radius: 1.5
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.primary
                visible: !Lock.checking

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 500 }
                    NumberAnimation { to: 1; duration: 500 }
                }
            }
        }
    }

    Item {
        id: button

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: parent.height - 12
        height: width
        scale: sendArea.pressed ? 0.88 : sendArea.containsMouse ? 1.06 : 1

        Behavior on scale {
            NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutCubic }
        }

        MaterialShape {
            anchors.fill: parent
            visible: !Lock.checking
            shape: root.typing ? MaterialShape.Cookie9Sided : MaterialShape.Circle
            color: root.typing ? Colors.primary : Qt.alpha(Colors.textOnSurface, 0.08)
            animationDuration: Theme.anim.slow

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !Lock.checking
            text: "arrow_forward"
            font.family: Theme.font.icons
            font.pixelSize: 22
            color: root.typing ? Colors.textOnPrimary : Qt.alpha(Colors.textOnSurface, 0.4)
        }

        MouseArea {
            id: sendArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.submit()
        }

        LoadingIndicator {
            anchors.centerIn: parent
            width: parent.width
            height: width
            contained: false
            running: Lock.checking
            visible: running
        }
    }
}
