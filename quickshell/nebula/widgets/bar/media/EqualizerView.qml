import QtQuick
import Quickshell
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property int columns: Theme.media.eqColumns
    property int rows: Theme.media.eqRows
    property var chipNames: null
    readonly property int perBand: (columns - 1) / 9
    readonly property real pad: Theme.media.eqPadding
    readonly property real gridTop: chips.height + Theme.spacing.md
    readonly property real gridHeight: height - gridTop - Theme.media.eqLabelHeight
    readonly property real colStep: (width - pad * 2) / (columns - 1)
    readonly property real rowStep: (gridHeight - pad * 2) / (rows - 1)
    readonly property real midY: rowY((rows - 1) / 2)
    readonly property real bottomY: rowY(rows - 1)

    property var fromGains: []
    property var shown: []
    property int ticked: 10
    property int tickCount: 0
    property real wave: 1
    readonly property bool waving: waveAnim.running
    readonly property real front: wave * (width + Theme.media.eqWaveReach * 2) - Theme.media.eqWaveReach

    function colX(c) {
        return pad + c * colStep;
    }

    function rowY(r) {
        return gridTop + pad + r * rowStep;
    }

    function yFor(db) {
        return midY - db / Equalizer.maxDb * (midY - rowY(0));
    }

    function dbFor(y) {
        return (midY - y) / (midY - rowY(0)) * Equalizer.maxDb;
    }

    function dbAt(gains, c) {
        const f = c / perBand;
        const i = Math.min(8, Math.floor(f)), t = f - i;
        const g = j => gains[Math.max(0, Math.min(9, j))];
        const p0 = g(i - 1), p1 = g(i), p2 = g(i + 1), p3 = g(i + 2);
        return 0.5 * (2 * p1 + (p2 - p0) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (3 * p1 - p0 - 3 * p2 + p3) * t * t * t);
    }

    function passedAt(x) {
        return waving ? Math.max(0, Math.min(1, (front - x) / 90 + 0.5)) : 1;
    }

    function bandNow(band) {
        const from = fromGains[band];
        return from + (Equalizer.gains[band] - from) * back(passedAt(colX(band * perBand)));
    }

    function tick() {
        if (Settings.sound.feedback && tickCount++ % 2 === 0)
            Quickshell.execDetached(["pw-play", "--volume", String(Theme.media.tickVolume), Quickshell.shellPath("assets/sounds/thock.wav")]);
    }

    function click() {
        tickCount = 0;
        tick();
    }

    function drag(band, y) {
        if (Equalizer.setGain(band, dbFor(y))) tick();
    }

    function back(t) {
        const c1 = 1.70158 * Theme.anim.overshoot, c3 = c1 + 1;
        return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
    }

    Connections {
        target: Equalizer

        function onPresetChanging() {
            root.fromGains = root.waving ? root.fromGains.map((db, band) => root.bandNow(band)) : root.shown;
            root.ticked = 0;
            root.tickCount = 0;
            waveAnim.restart();
        }
    }

    Component.onCompleted: {
        shown = Equalizer.gains.slice();
        fromGains = shown;
    }

    onFrontChanged: {
        const lead = Theme.media.eqTickLead / Theme.media.eqWaveDuration * (width + Theme.media.eqWaveReach * 2);
        const changes = fromGains.some((db, band) => Math.round(db) !== Equalizer.gains[band]);
        while (ticked < 10 && front + lead >= colX(ticked * perBand)) {
            if (changes) tick();
            ticked++;
        }
    }

    FrameAnimation {
        running: !root.waving && root.shown.some((db, i) => db !== Equalizer.gains[i])
        onTriggered: {
            const k = 1 - Math.exp(-frameTime * Theme.media.eqFollow);
            root.shown = root.shown.map((db, i) => {
                const target = Equalizer.gains[i];
                return Math.abs(target - db) < 0.02 ? target : db + (target - db) * k;
            });
        }
    }

    NumberAnimation {
        id: waveAnim
        target: root
        property: "wave"
        from: 0
        to: 1
        duration: Theme.media.eqWaveDuration * Theme.anim.scale
        onFinished: root.shown = Equalizer.gains.slice()
    }

    Row {
        id: chips
        spacing: Theme.spacing.xs + 2

        Repeater {
            model: root.chipNames ?? Equalizer.presetNames.concat(Equalizer.preset === "Custom" ? ["Custom", "+"] : [])

            Rectangle {
                id: chip
                required property string modelData
                readonly property bool active: modelData === Equalizer.preset

                width: chipRow.implicitWidth + Theme.spacing.lg
                height: 28
                radius: height / 2
                color: active ? Colors.primary : chipMouse.containsMouse ? Colors.surfaceContainerHighest : Qt.alpha(Colors.surfaceContainerHigh, 0.6)
                scale: chipMouse.pressed ? 0.92 : 1

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }
                Behavior on scale {
                    NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                }

                Row {
                    id: chipRow
                    anchors.centerIn: parent
                    spacing: Theme.spacing.xs + 2

                    MaterialShape {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: chip.active
                        width: 12
                        height: 12
                        shape: root.waving ? MaterialShape.Sunny : MaterialShape.Cookie6Sided
                        rotation: root.wave * 90
                        color: Colors.textOnPrimary
                    }

                    Text {
                        text: chip.modelData
                        color: chip.active ? Colors.textOnPrimary : Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        font.weight: 600
                    }
                }

                MouseArea {
                    id: chipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: chip.modelData !== "Custom"
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (chip.modelData === "+") {
                            root.click();
                            Equalizer.save();
                        } else if (mouse.button === Qt.RightButton) {
                            root.click();
                            Equalizer.remove(chip.modelData);
                        } else {
                            Equalizer.usePreset(chip.modelData);
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: chips.verticalCenter
        visible: !Equalizer.available
        text: "Off: link pipewire/nebula-eq.conf"
        color: Colors.textOnSurfaceVariant
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }

    Repeater {
        model: root.columns

        Item {
            id: column

            required property int index
            readonly property real cx: root.colX(index)
            readonly property bool band: index % root.perBand === 0
            readonly property int bandIndex: index / root.perBand
            readonly property real passed: root.passedAt(cx)
            readonly property real from: root.dbAt(root.fromGains, index)
            readonly property real value: root.waving ? from + (root.dbAt(Equalizer.gains, index) - from) * root.back(passed) : root.dbAt(root.shown, index)
            readonly property real curveY: root.yFor(value)
            readonly property real hit: root.waving ? Math.max(0, 1 - Math.abs(root.front - cx) / Theme.media.eqWaveWidth) : 0
            readonly property real tail: root.waving && root.front > cx ? Math.max(0, 1 - (root.front - cx) / Theme.media.eqWaveTail) : 0
            readonly property real level: Cava.values.length > 0 ? Math.pow(Cava.values[Math.round(index / (root.columns - 1) * (Cava.values.length - 1))], Theme.media.eqLevelCurve) : 0
            readonly property real fillY: root.bottomY + (curveY - root.bottomY) * Math.max(level, hit)

            Repeater {
                model: root.rows

                Rectangle {
                    required property int index
                    readonly property real cy: root.rowY(index)
                    readonly property bool lit: cy >= column.fillY - 1 && cy > column.curveY
                    readonly property real glow: Math.max(column.hit, column.tail * 0.35 * (lit ? 1 : 0.4))
                    readonly property color base: lit ? Qt.alpha(Colors.primary, Theme.media.eqLit) : Qt.alpha(Colors.textOnPrimaryContainer, Theme.media.eqIdle)

                    visible: Math.abs(cy - column.curveY) >= root.rowStep * 0.75
                    width: Theme.media.eqDot
                    height: width
                    radius: width / 2
                    x: column.cx - width / 2
                    y: cy - height / 2
                    color: glow > 0.03 ? Qt.tint(base, Qt.alpha(Colors.tertiary, glow)) : base
                }
            }

            Rectangle {
                visible: !column.band
                width: Theme.media.eqLineDot
                height: width
                radius: width / 2
                x: column.cx - width / 2
                y: column.curveY - height / 2
                color: column.hit > 0.15 ? Colors.tertiary : Colors.primary
            }

            MaterialShape {
                visible: column.band
                width: Theme.media.eqHandle + Theme.media.eqHandleHit * Math.max(column.hit, handleMouse.containsMouse || handleMouse.pressed ? 1 : 0)
                height: width
                x: column.cx - width / 2
                y: column.curveY - height / 2
                rotation: column.passed * 90
                shape: column.hit > 0.35 || handleMouse.pressed ? MaterialShape.Sunny : MaterialShape.Cookie9Sided
                color: column.hit > 0.15 || handleMouse.pressed ? Colors.tertiary : Colors.primary

                Behavior on width {
                    NumberAnimation { duration: Theme.anim.fast }
                }
            }

            MouseArea {
                id: handleMouse
                enabled: column.band
                x: column.cx - root.colStep * root.perBand / 2
                y: root.gridTop
                width: root.colStep * root.perBand
                height: root.gridHeight
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                onPressed: mouse => root.drag(column.bandIndex, mouse.y + y)
                onPositionChanged: mouse => {
                    if (pressed) root.drag(column.bandIndex, mouse.y + y);
                }
            }
        }
    }

    Repeater {
        model: Equalizer.labels

        Text {
            required property string modelData
            required property int index
            readonly property real cx: root.colX(index * root.perBand)
            readonly property real hit: root.waving ? Math.max(0, 1 - Math.abs(root.front - cx) / Theme.media.eqWaveWidth) : 0

            x: cx - width / 2
            y: root.height - Theme.media.eqLabelHeight + 4 - hit * 3
            text: modelData
            color: hit > 0.3 ? Colors.tertiary : Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: 11
            font.weight: hit > 0.3 ? 700 : 400
        }
    }
}
