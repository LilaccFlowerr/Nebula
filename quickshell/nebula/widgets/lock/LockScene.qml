import QtQuick
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
    readonly property real innerPhase: -seconds * Math.PI * 2 / Theme.lock.innerPeriod + Math.PI / 2
    readonly property real innerX: width * Theme.lock.innerOrbitX
    readonly property real innerY: height * Theme.lock.innerOrbitY
    readonly property var missedList: Notifications.missedApps.slice(0, Theme.lock.maxNotifications)
    readonly property int musicSlots: Media.active ? 1 : 0
    readonly property int total: 1 + musicSlots + notes.count
    readonly property bool weatherOn: Weather.enabled && Weather.current !== null
    readonly property bool batteryOn: Battery.available
    readonly property int innerTotal: (weatherOn ? 1 : 0) + 1 + (batteryOn ? 1 : 0)
    readonly property int moonIndex: weatherOn ? 1 : 0

    readonly property real activeClock: Theme.lock.activeClockSize * unit
    readonly property real musicX: cx - activeClock / 2 - Theme.lock.sideGap * unit - Theme.lock.activeMusicWidth * unit / 2
    readonly property real notificationX: cx + activeClock / 2 + Theme.lock.sideGap * unit + Theme.lock.activeNotificationWidth * unit / 2
    readonly property real rowY: cy - activeClock / 2 - Theme.lock.rowOffset * unit
    readonly property real inputY: cy + activeClock / 2 + (Theme.lock.inputGap + Theme.lock.inputHeight / 2) * unit
    readonly property real statsY: inputY + (Theme.lock.inputHeight / 2 + Theme.lock.statsGap + Theme.lock.statsHeight / 2) * unit

    readonly property real bass: {
        const v = Cava.values;
        if (!v || v.length === 0) return 0;
        let sum = 0;
        for (let i = 0; i < 8; i++) sum += v[i] ?? 0;
        return Math.min(1, sum / 8 * 1.8);
    }
    property real pulse: Media.playing && !active ? bass : 0

    readonly property var bandLevels: {
        if (!Media.playing || active) return [];
        const v = Cava.values;
        if (!v || v.length < 10) return [];
        const per = v.length / 10;
        const out = [];
        for (let b = 0; b < 10; b++) {
            let sum = 0;
            let n = 0;
            for (let i = Math.floor(b * per); i < Math.floor((b + 1) * per) && i < v.length; i++) {
                sum += v[i];
                n++;
            }
            let level = n > 0 ? sum / n : 0;
            if (Equalizer.available) level *= Math.pow(10, (Equalizer.gains[b] ?? 0) / 40);
            out.push(Math.min(1, level * 1.3));
        }
        return out;
    }

    Behavior on pulse {
        NumberAnimation { duration: 70 }
    }

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

    readonly property real inputT: Curves.outBack(Curves.phase(m, 560, 300), Theme.lock.wingOvershoot)
    readonly property real statsT: Curves.outBack(Curves.phase(m, 660, 320), Theme.lock.wingOvershoot)

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

    function syncNotes() {
        const want = missedList;
        for (let i = notes.count - 1; i >= 0; i--) {
            const name = notes.get(i).name;
            if (!want.some(a => a.name === name)) notes.remove(i);
        }
        want.forEach((a, i) => {
            const data = { name: a.name, count: a.count, summary: a.items[0] ? a.items[0].summary : "", icon: Notifications.iconFor(a.data) };
            let at = -1;
            for (let j = 0; j < notes.count; j++) {
                if (notes.get(j).name === a.name) at = j;
            }
            if (at < 0) {
                notes.insert(Math.min(i, notes.count), data);
            } else {
                notes.set(at, data);
                if (at !== i) notes.move(at, i, 1);
            }
        });
    }

    focus: true

    onMissedListChanged: syncNotes()

    Component.onDestruction: SystemStats.users--

    Component.onCompleted: {
        SystemStats.users++;
        Weather.refreshIfOld();
        syncNotes();
        input.forceActiveFocus();
        openAnim.start();
    }

    onActiveChanged: {
        modeAnim.stop();
        modeAnim.to = active ? 1 : 0;
        modeAnim.duration = Math.round(Theme.lock.modeDuration * Theme.anim.scale * Math.abs(modeAnim.to - modeT));
        modeAnim.start();
    }

    ListModel {
        id: notes
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

    BlackHole {
        x: root.cx - width / 2
        y: root.cy - height / 2
        width: Theme.lock.holeSize * root.unit
        height: width
        scale: Math.max(0, root.holeScale) * (1 + Theme.lock.holePulse * root.pulse)
        boost: root.holeBoost
        pulse: root.pulse
        levels: root.bandLevels
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
        model: notes

        OrbitSlot {
            id: note

            required property int index
            required property string name
            required property int count
            required property string summary
            required property string icon

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
            layoutY: root.cy + (index - (notes.count - 1) / 2) * (Theme.lock.activeNotificationHeight + Theme.lock.notificationGap) * root.unit

            Component.onCompleted: if (root.openT > 0.7 && !root.closing) arriveNow()

            LockNotification {
                anchors.fill: parent
                name: note.name
                count: note.count
                summary: note.summary
                icon: note.icon
                unit: root.unit
                morph: root.settle(120 + note.index * 60)
            }
        }
    }

    OrbitSlot {
        centerX: root.cx
        centerY: root.cy
        radiusX: root.innerX
        radiusY: root.innerY
        phase: root.innerPhase
        seconds: root.seconds
        slotIndex: 0
        total: root.innerTotal
        reveal: root.weatherOn ? root.wing(180, 120) : 0
        settle: root.settle(200)
        idleWidth: Theme.lock.planetSize * root.unit
        idleHeight: idleWidth
        layoutWidth: 92 * root.unit
        layoutHeight: layoutWidth
        layoutX: root.cx + (0 - (root.innerTotal - 1) / 2) * Theme.lock.rowSpacing * root.unit
        layoutY: root.rowY

        LockWeather {
            anchors.fill: parent
        }
    }

    OrbitSlot {
        centerX: root.cx
        centerY: root.cy
        radiusX: root.innerX
        radiusY: root.innerY
        phase: root.innerPhase
        seconds: root.seconds
        slotIndex: root.moonIndex
        total: root.innerTotal
        reveal: root.wing(240, 160)
        settle: root.settle(240)
        idleWidth: Theme.lock.moonSize * root.unit
        idleHeight: idleWidth + 24
        layoutWidth: 80 * root.unit
        layoutHeight: layoutWidth + 24
        layoutX: root.cx + (root.moonIndex - (root.innerTotal - 1) / 2) * Theme.lock.rowSpacing * root.unit
        layoutY: root.rowY + 12

        LockMoon {
            anchors.fill: parent
        }
    }

    OrbitSlot {
        centerX: root.cx
        centerY: root.cy
        radiusX: root.innerX
        radiusY: root.innerY
        phase: root.innerPhase
        seconds: root.seconds
        slotIndex: root.moonIndex + 1
        total: root.innerTotal
        reveal: root.batteryOn ? root.wing(300, 200) : 0
        settle: root.settle(280)
        idleWidth: Theme.lock.batterySize * root.unit
        idleHeight: idleWidth
        layoutWidth: 80 * root.unit
        layoutHeight: layoutWidth
        layoutX: root.cx + (root.moonIndex + 1 - (root.innerTotal - 1) / 2) * Theme.lock.rowSpacing * root.unit
        layoutY: root.rowY

        LockBattery {
            anchors.fill: parent
        }
    }

    SpiralSlot {
        originX: root.cx
        originY: root.cy
        targetX: root.cx + root.shakeX
        targetY: root.inputY
        reveal: Math.min(root.inputT, root.closing ? 1 - Curves.inQuad(Curves.phase(root.c, 0, 300)) : 1)
        width: Theme.lock.inputWidth * root.unit
        height: Theme.lock.inputHeight * root.unit

        LockInput {
            anchors.fill: parent
            onSubmit: Lock.submit(input.text)
        }
    }

    Item {
        readonly property real shownT: Math.min(Curves.outCubic(Curves.phase(root.m, 660, 420)), root.closing ? 1 - Curves.inQuad(Curves.phase(root.c, 60, 300)) : 1)

        x: root.cx - width / 2
        y: root.statsY - height / 2 + (1 - shownT) * 28 * root.unit
        width: Theme.lock.statsWidth * root.unit
        height: Theme.lock.statsHeight * root.unit
        opacity: shownT
        visible: opacity > 0

        LockStats {
            anchors.fill: parent
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
