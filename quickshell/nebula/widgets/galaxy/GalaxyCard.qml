import QtQuick
import QtQuick.Layouts
import Quickshell
import M3Shapes
import qs.components
import qs.services
import qs.theme
import "../../components/Curves.js" as Curves
import "../../components/Orbits.js" as Orbits

Item {
    id: root

    property real open: 0
    property real time: 0
    property real now: Date.now()
    property string selected: ""
    property string focused: ""
    property real fan: 0
    property int offset: 0
    property real shownOffset: offset
    property real burst: 1
    property string clearing: ""
    property var expanded: -1
    property real expandExtra: 0
    property real away: 0
    property var removing: null
    property real removeT: 0
    property var slots: ({})

    readonly property var apps: Notifications.missedApps.slice(0, Orbits.count)
    readonly property var picked: apps.find(a => a.name === selected) ?? null
    readonly property int pickedCount: apps.find(a => a.name === focused)?.items.length ?? 0
    readonly property int visibleCards: Math.min(pickedCount, Theme.galaxy.maxCards)
    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real holdX: cx - Theme.galaxy.holdOffset

    signal closeRequested()

    function removeEntry(entry) {
        if (removing !== null) return;
        removing = entry;
        removeAnim.restart();
    }

    function burstIn() {
        burst = 0;
        burstAnim.restart();
    }

    function clearAll() {
        if (clearing !== "") return;
        clearing = "*";
        awayAnim.restart();
    }

    function clearApp(name) {
        if (clearing !== "") return;
        clearing = name;
        awayAnim.restart();
    }

    function reset() {
        fanIn.stop();
        fanOut.stop();
        selected = "";
        focused = "";
        fan = 0;
        offset = 0;
        expanded = -1;
    }

    function back() {
        if (expanded !== -1) {
            expanded = -1;
            return true;
        }
        if (selected !== "") {
            selected = "";
            return true;
        }
        return false;
    }

    function ago(time) {
        const s = (now - time) / 1000;
        if (s < 60) return "now";
        if (s < 3600) return Math.round(s / 60) + " min";
        if (s < 86400) return Math.round(s / 3600) + " h";
        return Math.round(s / 86400) + " d";
    }

    function slotFor(name) {
        if (!(name in slots)) {
            const used = Object.values(slots);
            let slot = 0;
            while (used.includes(slot)) slot++;
            slots[name] = slot;
        }
        return slots[name];
    }

    function mix(a, b, t) {
        return a + (b - a) * t;
    }

    onSelectedChanged: {
        if (focused === "") {
            focused = selected;
            if (focused !== "") fanIn.restart();
        } else {
            fanIn.stop();
            fanOut.restart();
        }
    }
    onAppsChanged: if (selected !== "" && !picked) selected = ""

    Behavior on shownOffset {
        NumberAnimation {
            duration: Theme.anim.medium * Theme.anim.scale
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    NumberAnimation {
        id: burstAnim
        target: root
        property: "burst"
        from: 0
        to: 1
        duration: Theme.galaxy.burstDuration * Theme.anim.scale
    }

    NumberAnimation {
        id: removeAnim
        target: root
        property: "removeT"
        from: 0
        to: 1
        duration: Theme.galaxy.clearDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedAccel
        onFinished: {
            if (root.expanded === root.removing.id) root.expanded = -1;
            Notifications.forget(root.removing);
            root.removing = null;
            root.removeT = 0;
            root.offset = Math.max(0, Math.min(root.offset, root.pickedCount - Theme.galaxy.maxCards));
        }
    }

    NumberAnimation {
        id: awayAnim
        target: root
        property: "away"
        from: 0
        to: 1
        duration: Theme.galaxy.clearDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedAccel
        onFinished: {
            const name = root.clearing;
            if (name === "*") {
                Notifications.clearMissed();
                root.closeRequested();
            }
            if (name === "*" || root.focused === name) {
                root.focused = "";
                root.selected = "";
                root.fan = 0;
                root.offset = 0;
            }
            root.clearing = "";
            root.away = 0;
            if (name !== "*") Notifications.forgetApp(name);
        }
    }

    NumberAnimation {
        id: fanIn
        target: root
        property: "fan"
        to: 1
        duration: Theme.galaxy.fanDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.standard
    }

    NumberAnimation {
        id: fanOut
        target: root
        property: "fan"
        to: 0
        duration: Theme.galaxy.fanDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.standard
        onFinished: {
            root.offset = 0;
            root.expanded = -1;
            root.focused = root.selected;
            if (root.focused !== "") fanIn.restart();
        }
    }

    width: Theme.galaxy.width
    height: Theme.galaxy.height

    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (root.focused === "" || root.pickedCount <= Theme.galaxy.maxCards || wheel.angleDelta.y === 0) return;
            const step = wheel.angleDelta.y < 0 ? 1 : -1;
            root.offset = Math.max(0, Math.min(root.pickedCount - Theme.galaxy.maxCards, root.offset + step));
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        text: root.apps.length > 0 ? "Missed" : "All caught up"
        color: Colors.textOnSurface
        font.family: Theme.font.family
        font.pixelSize: Theme.font.large + 6
        font.weight: 700
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 32
        visible: root.apps.length > 0
        text: Notifications.missedCount + (Notifications.missedCount === 1 ? " notification" : " notifications") + " from " + Notifications.missedApps.length + (Notifications.missedApps.length === 1 ? " app" : " apps")
        color: Colors.textOnSurfaceVariant
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        visible: root.apps.length > 0 && root.focused === ""
        width: clearText.implicitWidth + Theme.spacing.xl
        height: 34
        radius: height / 2
        color: clearMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

        Text {
            id: clearText
            anchors.centerIn: parent
            text: "Clear all"
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            font.weight: 600
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clearAll()
        }
    }

    ShapedArt {
        width: Theme.galaxy.coreSize
        height: width
        x: root.cx - width / 2
        y: root.cy - height / 2
        shape: MaterialShape.Cookie12Sided
        shapeRotation: root.time * 6
        color: Colors.primaryContainer
        source: SystemInfo.avatar
        sourceSize: Qt.size(Theme.galaxy.coreSize * 2, Theme.galaxy.coreSize * 2)
        scale: Curves.back(Curves.phase(root.open, 0, 0.8), Theme.anim.overshoot)
        opacity: 1 - root.fan * 0.5
    }

    Repeater {
        model: ScriptModel {
            values: root.apps
            objectProp: "name"
        }

        Item {
            id: planet

            required property var modelData
            readonly property int slot: root.slotFor(modelData.name)
            readonly property var orbit: Orbits.at(slot, root.time, 1)
            property real born: 0
            readonly property real fly: Curves.back(Curves.phase(root.burst, Theme.galaxy.burstStart + slot * Theme.galaxy.burstStagger, Theme.galaxy.burstLength), Theme.anim.overshoot) * born
            readonly property real gone: root.clearing === "*" || root.clearing === modelData.name ? root.away : 0
            readonly property bool active: root.focused === modelData.name
            readonly property bool dim: root.focused !== "" && !active
            readonly property real hold: active ? root.fan : 0
            readonly property real px: root.mix(root.mix(root.cx + orbit.x * fly, root.holdX, hold), root.cx, gone)
            readonly property real py: root.mix(root.mix(root.cy + orbit.y * fly, root.cy, hold), root.cy, gone)
            readonly property int expandIndex: modelData.items.findIndex(item => item.id === root.expanded)
            readonly property real size: (Theme.galaxy.planetSize + Math.min(modelData.count, Theme.galaxy.maxGrowth) * Theme.galaxy.planetGrow) * (1 + hold * 0.3) * (1 - 0.8 * gone)

            anchors.fill: parent
            z: active ? 20 : orbit.depth * 10

            NumberAnimation on born {
                to: 1
                duration: Theme.anim.slow * Theme.anim.scale
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }

            Repeater {
                model: Theme.galaxy.trail

                Rectangle {
                    required property int index
                    readonly property var at: Orbits.at(planet.slot, root.time - (index + 1) * Theme.galaxy.trailStep, 1)

                    width: 6 - index * 0.7
                    height: width
                    radius: width / 2
                    x: root.cx + at.x * planet.fly - width / 2
                    y: root.cy + at.y * planet.fly - height / 2
                    color: [Colors.primary, Colors.tertiary, Colors.secondary][planet.slot % 3]
                    opacity: (0.45 - index * 0.07) * root.open * (root.focused !== "" ? 1 - root.fan : 1) * (1 - planet.gone)
                }
            }

            Planet {
                app: planet.modelData
                index: planet.slot
                width: planet.size
                height: width
                x: planet.px - width / 2
                y: planet.py - height / 2
                rotation: root.time * 14 * (planet.slot % 2 ? 1 : -1)
                opacity: (planet.dim ? 1 - root.fan * 0.7 : 1) * (1 - Curves.phase(planet.gone, 0.6, 0.4))

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            root.clearApp(planet.modelData.name);
                        else
                            root.selected = root.selected === planet.modelData.name ? "" : planet.modelData.name;
                    }
                }
            }

            Text {
                visible: planet.active && root.pickedCount > Theme.galaxy.maxCards
                x: root.holdX - implicitWidth / 2
                y: root.cy + planet.size / 2 + Theme.spacing.lg
                opacity: root.fan
                text: (root.offset + 1) + "–" + (root.offset + root.visibleCards) + " of " + root.pickedCount
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
            }

            Rectangle {
                visible: planet.active && root.clearing === ""
                x: root.holdX - width / 2
                y: root.cy + planet.size / 2 + Theme.spacing.lg + (root.pickedCount > Theme.galaxy.maxCards ? 24 : 0)
                width: clearAppText.implicitWidth + Theme.spacing.xl
                height: 32
                radius: height / 2
                opacity: root.fan
                color: clearAppMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

                Text {
                    id: clearAppText
                    anchors.centerIn: parent
                    text: "Clear"
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    font.weight: 600
                }

                MouseArea {
                    id: clearAppMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clearApp(planet.modelData.name)
                }
            }

            Repeater {
                model: ScriptModel {
                    values: planet.active ? planet.modelData.items : []
                    objectProp: "id"
                }

                Item {
                    id: leaf

                    required property var modelData
                    required property int index
                    readonly property bool mine: root.expanded === modelData.id
                    property real e: mine ? 1 : 0
                    property real shift: planet.expandIndex >= 0 && index > planet.expandIndex ? root.expandExtra / Theme.galaxy.fanRadius : 0
                    readonly property real rel: index - root.shownOffset - (root.visibleCards - 1) / 2
                    readonly property real edge: Math.max(0, Math.min(1, root.visibleCards / 2 + 0.5 - Math.abs(rel)))
                    readonly property real t: Curves.back(Curves.phase(root.fan, Math.max(0, index - root.offset) * 0.12, 0.7), Theme.anim.overshoot)
                    readonly property real arc: rel * Theme.galaxy.fanSpread + shift
                    readonly property real flight: root.removing?.id === modelData.id ? root.removeT : 0
                    readonly property real pad: Theme.spacing.md + 2
                    readonly property var messages: modelData.entries.slice(0, Theme.galaxy.expandMessages).reverse()
                    readonly property real fullHeight: Math.max(content.implicitHeight, avatar.height) + actions.height + pad * 2 + Theme.spacing.sm

                    Behavior on e {
                        NumberAnimation {
                            duration: Theme.anim.medium
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.emphasizedDecel
                        }
                    }

                    Behavior on shift {
                        NumberAnimation {
                            duration: Theme.anim.medium
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.emphasizedDecel
                        }
                    }

                    width: Theme.galaxy.cardWidth
                    height: root.mix(Theme.galaxy.cardHeight, fullHeight, e)
                    transformOrigin: Item.Top
                    x: root.mix(root.mix(planet.px - width / 2, root.holdX + Math.cos(arc) * Theme.galaxy.fanRadius - 40, t), root.cx - width / 2, planet.gone) + flight * Theme.galaxy.flyAway
                    y: root.mix(root.mix(planet.py - height / 2, root.cy + Math.sin(arc) * Theme.galaxy.fanRadius - Theme.galaxy.cardHeight / 2, t), root.cy - height / 2, planet.gone)
                    z: mine ? 5 : 0
                    rotation: arc * 57 * 0.45 * t
                    scale: (0.3 + 0.7 * Math.min(1, t)) * (1 - 0.8 * planet.gone)
                    opacity: Math.min(1, t * 1.6) * (mine ? 1 : edge) * (1 - Curves.phase(flight, 0.5, 0.5)) * (1 - Curves.phase(planet.gone, 0.6, 0.4))
                    visible: edge > 0 || mine

                    HoverHandler {
                        id: leafHover
                    }

                    Binding {
                        when: leaf.mine
                        target: root
                        property: "expandExtra"
                        value: leaf.fullHeight - Theme.galaxy.cardHeight
                        restoreMode: Binding.RestoreNone
                    }

                    FontMetrics {
                        id: bodyMetrics
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 22
                        color: leafHover.hovered && !leaf.mine ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton)
                                root.removeEntry(leaf.modelData);
                            else
                                root.expanded = leaf.mine ? -1 : leaf.modelData.id;
                        }
                    }

                    Item {
                        anchors.fill: parent
                        clip: leaf.e > 0

                        ShapedArt {
                            id: avatar
                            readonly property string url: leaf.modelData.data.image ?? ""
                            x: Theme.spacing.md
                            y: root.mix((Theme.galaxy.cardHeight - height) / 2, leaf.pad, leaf.e)
                            width: Theme.galaxy.avatarSize
                            height: width
                            visible: url !== "" && !url.startsWith("image://icon/")
                            shape: MaterialShape.Cookie9Sided
                            color: Colors.primaryContainer
                            source: visible ? url : ""
                            sourceSize: Qt.size(width * 2, height * 2)
                        }

                        Column {
                            id: content
                            x: avatar.visible ? avatar.x + avatar.width + Theme.spacing.md : Theme.spacing.lg + 2
                            y: root.mix((Theme.galaxy.cardHeight - summary.implicitHeight - bodyMetrics.height) / 2, leaf.pad, leaf.e)
                            width: Theme.galaxy.cardWidth - x - leaf.pad

                            Row {
                                width: parent.width - Theme.galaxy.timeSpace
                                spacing: Theme.spacing.xs + 2

                                Text {
                                    id: summary
                                    width: Math.min(implicitWidth, parent.width - (badge.visible ? badge.width + parent.spacing : 0))
                                    elide: Text.ElideRight
                                    text: leaf.modelData.summary
                                    color: Colors.textOnSurface
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.normal - 1
                                    font.weight: 700
                                }

                                Rectangle {
                                    id: badge
                                    anchors.verticalCenter: summary.verticalCenter
                                    visible: leaf.modelData.count > 1
                                    width: Math.max(height, badgeText.implicitWidth + 10)
                                    height: 18
                                    radius: height / 2
                                    color: Colors.primary

                                    Text {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        text: leaf.modelData.count
                                        color: Colors.textOnPrimary
                                        font.family: Theme.font.family
                                        font.pixelSize: 11
                                        font.weight: 700
                                    }
                                }
                            }

                            Text {
                                width: parent.width - Theme.galaxy.timeSpace
                                visible: !leaf.mine
                                elide: Text.ElideRight
                                text: leaf.modelData.data.body
                                color: Colors.textOnSurfaceVariant
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small
                            }

                            Column {
                                width: parent.width
                                visible: leaf.mine
                                topPadding: Theme.spacing.xs
                                spacing: Theme.spacing.xs

                                Repeater {
                                    model: leaf.mine ? leaf.messages : []

                                    Rectangle {
                                        required property var modelData

                                        width: Math.min(message.implicitWidth, parent.width - Theme.spacing.sm * 2) + Theme.spacing.sm * 2
                                        height: message.height + Theme.spacing.xs * 2
                                        radius: 10
                                        color: Colors.surfaceContainerHighest

                                        Text {
                                            id: message
                                            x: Theme.spacing.sm
                                            y: Theme.spacing.xs
                                            width: Math.min(implicitWidth, parent.parent.width - Theme.spacing.sm * 2)
                                            elide: Text.ElideRight
                                            wrapMode: Text.Wrap
                                            maximumLineCount: Theme.galaxy.expandLines
                                            text: parent.modelData.data.body
                                            color: Colors.textOnSurface
                                            font.family: Theme.font.family
                                            font.pixelSize: Theme.font.small
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: leaf.pad
                            y: Theme.spacing.md - 1
                            text: root.ago(leaf.modelData.time)
                            color: Colors.textOnSurfaceVariant
                            font.family: Theme.font.family
                            font.pixelSize: 11
                        }

                        RowLayout {
                            id: actions
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: Theme.spacing.sm + 2
                            spacing: Theme.spacing.xs
                            visible: leaf.e > 0
                            opacity: Curves.phase(leaf.e, 0.5, 0.5)

                            LeafButton {
                                id: closeButton
                                icon: "close"
                                Layout.preferredWidth: implicitWidth + (pressed ? Theme.spacing.md : 0)
                                onClicked: root.removeEntry(leaf.modelData)

                                Behavior on Layout.preferredWidth {
                                    NumberAnimation {
                                        duration: Theme.anim.fast
                                    }
                                }
                            }

                            LeafButton {
                                text: "Open " + leaf.modelData.data.appName
                                primary: true
                                Layout.fillWidth: true
                                onClicked: {
                                    const entry = leaf.modelData;
                                    root.closeRequested();
                                    Notifications.openMissed(entry);
                                }
                            }

                            LeafButton {
                                id: copyButton
                                icon: copyTimer.running ? "inventory" : "content_copy"
                                Layout.preferredWidth: implicitWidth + (pressed ? Theme.spacing.md : 0)
                                onClicked: {
                                    Quickshell.clipboardText = leaf.messages.map(m => m.data.body).join("\n") || leaf.modelData.summary;
                                    copyTimer.restart();
                                }

                                Behavior on Layout.preferredWidth {
                                    NumberAnimation {
                                        duration: Theme.anim.fast
                                    }
                                }

                                Timer {
                                    id: copyTimer
                                    interval: 3000
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
