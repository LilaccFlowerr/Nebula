import QtQuick
import qs.theme

Item {
    id: root

    readonly property real synodic: 29.530588853
    readonly property real knownNew: Date.UTC(2000, 0, 6, 18, 14)
    property real phase: compute()
    readonly property real illumination: Math.round((1 - Math.cos(phase * Math.PI * 2)) / 2 * 100)
    readonly property string phaseName: {
        const p = phase;
        if (p < 0.03 || p >= 0.97) return "New moon";
        if (p < 0.22) return "Waxing crescent";
        if (p < 0.28) return "First quarter";
        if (p < 0.47) return "Waxing gibbous";
        if (p < 0.53) return "Full moon";
        if (p < 0.72) return "Waning gibbous";
        if (p < 0.78) return "Last quarter";
        return "Waning crescent";
    }

    function compute() {
        const days = (Date.now() - knownNew) / 86400000;
        const p = (days / synodic) % 1;
        return p < 0 ? p + 1 : p;
    }

    Timer {
        interval: 600000
        running: root.visible
        repeat: true
        onTriggered: root.phase = root.compute()
    }

    Canvas {
        id: disc

        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width
        height: width
        onWidthChanged: requestPaint()

        Connections {
            target: root
            function onPhaseChanged() { disc.requestPaint(); }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const R = width / 2 - 2, cx = width / 2, cy = height / 2;
            ctx.fillStyle = "rgba(255,255,255,0.09)";
            ctx.beginPath();
            ctx.arc(cx, cy, R, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = "rgba(255,255,255,0.22)";
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.arc(cx, cy, R, 0, Math.PI * 2);
            ctx.stroke();
            const k = Math.cos(root.phase * Math.PI * 2);
            const dir = root.phase < 0.5 ? 1 : -1;
            ctx.fillStyle = Theme.lock.star;
            ctx.beginPath();
            for (let i = 0; i <= 40; i++) {
                const t = -Math.PI / 2 + i / 40 * Math.PI;
                const x = cx + dir * R * Math.cos(t), y = cy + R * Math.sin(t);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            for (let i = 0; i <= 40; i++) {
                const t = Math.PI / 2 - i / 40 * Math.PI;
                ctx.lineTo(cx + dir * k * R * Math.cos(t), cy + R * Math.sin(t));
            }
            ctx.closePath();
            ctx.fill();
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: disc.bottom
        anchors.topMargin: 6
        text: root.phaseName + " · " + root.illumination + "%"
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
        color: Qt.alpha(Colors.textOnSurface, 0.85)
    }
}
