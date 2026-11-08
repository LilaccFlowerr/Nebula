import QtQuick
import QtQuick.Shapes
import qs.components
import qs.services
import qs.theme
import "../../components/Curves.js" as Curves

FocusScope {
    id: root

    property bool active: false
    property real openT: 0
    property real closeT: 0
    property real modeT: 0
    property real shakeX: 0
    property real seconds: 0

    readonly property bool closing: Lock.unlocking
    readonly property real o: openT * Theme.lock.openDuration
    readonly property real c: closeT * Theme.lock.closeDuration
    readonly property real m: modeT * Theme.lock.modeDuration
    readonly property real unit: Math.max(0.7, Math.min(1.5, height / 1080))
    readonly property real cx: width / 2
    readonly property real cy: height * Theme.lock.centerHeight
    readonly property real phase: seconds * Math.PI * 2 / Theme.lock.orbitPeriod - Math.PI / 2
    readonly property real radiusX: width * Theme.lock.orbitX
    readonly property real radiusY: height * Theme.lock.orbitY
    readonly property var missedList: Notifications.missedApps.slice(0, Theme.lock.maxNotifications)
    readonly property int musicSlots: Media.active ? 1 : 0
    readonly property int total: 1 + musicSlots + missedList.length

    readonly property real activeClock: Theme.lock.activeClockSize * unit
    readonly property real passwordY: cy + activeClock / 2 + 28 * unit + Theme.lock.passwordHeight * unit / 2
    readonly property real musicX: cx - activeClock / 2 - Theme.lock.sideGap * unit - Theme.lock.activeMusicWidth * unit / 2
    readonly property real notificationX: cx + activeClock / 2 + Theme.lock.sideGap * unit + Theme.lock.activeNotificationWidth * unit / 2

    readonly property real holeBase: (1 + 0.25 * (Curves.outCubic(Curves.phase(m, 0, 260)) - Curves.outCubic(Curves.phase(m, 260, 260)))) * (1 - Curves.inQuad(Curves.phase(m, 180, 320)))

    readonly property real holeScale: {
        if (closing) {
            const grow = modeT > 0 ? Curves.outBack(Curves.phase(c, 180, 350), Theme.lock.centerOvershoot) : 0;
            return Math.max(holeBase, grow) * (1 - Curves.inBack(Curves.phase(c, 1000, 420), Theme.lock.foldOvershoot));
        }
        const pop = Curves.outBack(Curves.phase(o, 0, 350), Theme.lock.centerOvershoot);
        const bump = Curves.outCubic(Curves.phase(o, 820, 260)) - Curves.outCubic(Curves.phase(o, 1080, 320));
        return pop * (1 + 0.25 * bump) * holeBase;
    }

    readonly property real holeBoost: {
        if (closing) return 0.25 + 1.55 * Curves.inQuad(Curves.phase(c, 0, 500));
        if (o < 900) return Curves.inQuad(Curves.phase(o, 0, 900));
        return 1 - 0.75 * Curves.outQuint(Curves.phase(o, 960, 700));
    }

    readonly property real iconOpacity: closing
        ? (modeT > 0 ? Curves.phase(c, 180, 150) : 1) * (1 - Curves.phase(c, 1000, 250))
        : Curves.phase(o, 0, 200)

    readonly property real contentOpacity: closing
        ? 1 - Curves.inQuad(Curves.phase(c, 0, 100))
        : Curves.outCubic(Curves.phase(o, 1150, 140))

    readonly property real nebula: closing
        ? 1 - Curves.inQuad(Curves.phase(c, 180, 900))
        : Curves.outQuint(Curves.phase(o, 1000, 2400))

    readonly property real pillT: Curves.outBack(Curves.phase(m, 560, 300), Theme.lock.wingOvershoot)

    function wing(openDelay, closeDelay) {
        if (closing) return 1 - Curves.inQuad(Curves.phase(c, closeDelay, 300));
        return Curves.outBack(Curves.phase(o, 1080 + openDelay, 250), Theme.lock.wingOvershoot);
    }

    function settle(delay) {
        return Curves.outBack(Curves.phase(m, 260 + delay, 380), Theme.lock.wingOvershoot);
    }

    function openMs() {
        return Math.round(Theme.lock.openDuration * Theme.anim.scale);
    }

    function closeMs() {
        return Math.round(Theme.lock.closeDuration * Theme.anim.scale);
    }

    function wake() {
        idleTimer.restart();
        if (!active && !closing && openT > 0.4) active = true;
    }

    focus: true

    Component.onCompleted: {
        input.forceActiveFocus();
        openAnim.start();
    }

    onActiveChanged: {
        modeAnim.stop();
        modeAnim.to = active ? 1 : 0;
        modeAnim.duration = Math.round(Theme.lock.modeDuration * Theme.anim.scale * Math.abs(modeAnim.to - modeT));
        modeAnim.start();
    }

    FrameAnimation {
        running: true
        onTriggered: root.seconds += frameTime
    }

    Timer {
        id: idleTimer
        interval: Theme.lock.idleTimeout
        running: root.active && Lock.typed === 0 && !Lock.checking && !Lock.unlocking
        onTriggered: if (Lock.typed === 0 && !Lock.checking && !Lock.unlocking) root.active = false
    }

    NumberAnimation {
        id: openAnim
        target: root
        property: "openT"
        from: 0
        to: 1
        duration: root.openMs()
        easing.type: Easing.Linear
    }

    NumberAnimation {
        id: modeAnim
        target: root
        property: "modeT"
        easing.type: Easing.Linear
    }

    NumberAnimation {
        id: closeAnim
        target: root
        property: "closeT"
        from: 0
        to: 1
        duration: root.closeMs()
        easing.type: Easing.Linear
        onFinished: if (Lock.unlocking) Lock.finish()
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: root; property: "shakeX"; to: -10; duration: 55 }
        NumberAnimation { target: root; property: "shakeX"; to: 9; duration: 70 }
        NumberAnimation { target: root; property: "shakeX"; to: -6; duration: 70 }
        NumberAnimation { target: root; property: "shakeX"; to: 3; duration: 70 }
        NumberAnimation { target: root; property: "shakeX"; to: 0; duration: 60 }
    }

    Connections {
        target: Lock

        function onUnlockingChanged() {
            if (!Lock.unlocking) return;
            openAnim.stop();
            root.openT = 1;
            input.text = "";
            closeAnim.restart();
        }

        function onFailedAttempt() {
            input.text = "";
            shakeAnim.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.lock.space
    }

    LockBackdrop {
        anchors.fill: parent
    }

    LockStars {
        anchors.fill: parent
    }

    NebulaClouds {
        anchors.fill: parent
        spread: root.nebula
    }

    Shape {
        anchors.fill: parent
        opacity: Math.min(1, root.nebula * 2) * (1 - Math.min(1, root.modeT * 2))

        ShapePath {
            strokeColor: Qt.alpha(Colors.textOnSurface, 0.12)
            strokeWidth: 1
            strokeStyle: ShapePath.DashLine
            dashPattern: [3, 6]
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: root.radiusX
                radiusY: root.radiusY
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    BlackHole {
        x: root.cx - width / 2
        y: root.cy - height / 2
        width: Theme.lock.holeSize * root.unit
        height: width
        scale: Math.max(0, root.holeScale)
        boost: root.holeBoost
        iconOpacity: root.iconOpacity
        visible: root.holeScale > 0.002
    }

    OrbitSlot {
        centerX: root.cx
        centerY: root.cy
        radiusX: root.radiusX
        radiusY: root.radiusY
        phase: root.phase
        seconds: root.seconds
        slotIndex: 0
        total: root.total
        reveal: root.wing(0, 0)
        settle: root.settle(0)
        idleWidth: Theme.lock.clockSize * root.unit
        idleHeight: idleWidth
        layoutWidth: root.activeClock
        layoutHeight: layoutWidth
        layoutX: root.cx + root.shakeX * 0.6
        layoutY: root.cy

        LockClock {
            anchors.fill: parent
        }
    }

    OrbitSlot {
        centerX: root.cx
        centerY: root.cy
        radiusX: root.radiusX
        radiusY: root.radiusY
        phase: root.phase
        seconds: root.seconds
        slotIndex: 1
        total: root.total
        reveal: Media.active ? root.wing(60, 40) : 0
        settle: root.settle(60)
        idleWidth: Theme.lock.musicWidth * root.unit
        idleHeight: Theme.lock.musicHeight * root.unit
        layoutWidth: Theme.lock.activeMusicWidth * root.unit
        layoutHeight: Theme.lock.activeMusicHeight * root.unit
        layoutX: root.musicX
        layoutY: root.cy

        LockMusic {
            anchors.fill: parent
            morph: root.settle(60)
        }
    }

    Repeater {
        model: root.missedList

        OrbitSlot {
            required property int index
            required property var modelData

            centerX: root.cx
            centerY: root.cy
            radiusX: root.radiusX
            radiusY: root.radiusY
            phase: root.phase
            seconds: root.seconds
            slotIndex: 1 + root.musicSlots + index
            total: root.total
            reveal: root.wing(120 + index * 60, 80 + index * 40)
            settle: root.settle(120 + index * 60)
            idleWidth: Theme.lock.notificationWidth * root.unit
            idleHeight: Theme.lock.notificationHeight * root.unit
            layoutWidth: Theme.lock.activeNotificationWidth * root.unit
            layoutHeight: Theme.lock.activeNotificationHeight * root.unit
            layoutX: root.notificationX
            layoutY: root.cy + (index - (root.missedList.length - 1) / 2) * (Theme.lock.activeNotificationHeight + Theme.lock.notificationGap) * root.unit

            LockNotification {
                anchors.fill: parent
                entry: modelData
            }
        }
    }

    Item {
        x: root.cx - width / 2 + root.shakeX
        y: root.passwordY - height / 2
        width: Theme.lock.passwordWidth * root.unit
        height: Theme.lock.passwordHeight * root.unit
        scale: Math.max(0, root.pillT)
        opacity: Math.min(1, root.pillT * 1.6) * root.contentOpacity
        visible: opacity > 0

        GlassRect {
            anchors.fill: parent
            radius: height / 2
            fill: Lock.failed ? Colors.errorContainer : Colors.secondaryContainer
            tint: Theme.lock.surfaceTint
            light: 0

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8
            visible: Lock.typed > 0 && !Lock.checking

            Repeater {
                model: Math.min(Lock.typed, Theme.lock.maxDots)

                Rectangle {
                    width: 9
                    height: 9
                    radius: 4.5
                    color: Colors.textOnSecondaryContainer
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: Lock.typed === 0 || Lock.checking
            text: Lock.checking ? "Checking…" : Lock.failed ? Lock.message : "Enter password"
            font.family: Theme.font.family
            font.pixelSize: Theme.font.large
            color: Lock.failed ? Colors.textOnErrorContainer : Qt.alpha(Colors.textOnSecondaryContainer, 0.7)
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: {
            input.forceActiveFocus();
            root.wake();
        }
    }

    TextInput {
        id: input

        width: 1
        height: 1
        opacity: 0
        focus: true
        echoMode: TextInput.Password
        readOnly: Lock.checking || Lock.unlocking
        onTextChanged: Lock.typed = text.length

        Keys.onPressed: event => {
            if (event.isAutoRepeat && event.key !== Qt.Key_Backspace) return;
            if (!root.active) {
                root.wake();
                if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape) event.accepted = true;
                return;
            }
            idleTimer.restart();
        }

        onAccepted: Lock.submit(text)

        Keys.onEscapePressed: {
            if (text !== "") text = "";
            else root.active = false;
        }
    }
}
