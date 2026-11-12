pragma Singleton

import QtQuick
import Quickshell
import qs.theme

Singleton {
    id: root

    property bool dragging: false
    property bool active: false
    property string screen: ""
    property var guides: []
    property real focusX: 0
    property real focusY: 0

    function lines(spans, extent) {
        const out = [
            { at: 0, center: false },
            { at: Theme.snap.margin, center: false },
            { at: extent / 2, center: true },
            { at: extent - Theme.snap.margin, center: false },
            { at: extent, center: false }
        ];
        for (const span of spans) {
            out.push({ at: span.start, center: false });
            out.push({ at: span.start + span.size / 2, center: true });
            out.push({ at: span.start + span.size, center: false });
        }
        return out;
    }

    function snapAxis(start, size, lines) {
        let best = { start: start, line: null };
        let reach = Theme.snap.distance;
        for (const line of lines) {
            const points = line.center ? [start + size / 2] : [start, start + size];
            for (const point of points) {
                const gap = Math.abs(line.at - point);
                if (gap > reach) continue;
                reach = gap;
                best = { start: start + line.at - point, line: line };
            }
        }
        return best.line ? best : { start: gridAxis(start, size), line: null };
    }

    function gridAxis(start, size) {
        let shift = 0;
        let reach = Theme.snap.gridDistance;
        for (const point of [start, start + size]) {
            const gap = Math.round(point / Theme.snap.cell) * Theme.snap.cell - point;
            if (Math.abs(gap) > reach) continue;
            reach = Math.abs(gap);
            shift = gap;
        }
        return start + shift;
    }

    function touches(start, size, line) {
        if (line.center) return Math.abs(start + size / 2 - line.at) < 0.5;
        return Math.abs(start - line.at) < 0.5 || Math.abs(start + size - line.at) < 0.5;
    }

    function guide(rect, others, line, vertical, extent) {
        let from = vertical ? rect.y : rect.x;
        let to = from + (vertical ? rect.h : rect.w);
        let linked = false;
        for (const o of others) {
            if (!touches(vertical ? o.x : o.y, vertical ? o.w : o.h, line)) continue;
            const start = vertical ? o.y : o.x;
            from = Math.min(from, start);
            to = Math.max(to, start + (vertical ? o.h : o.w));
            linked = true;
        }
        if (!linked) {
            from = 0;
            to = extent;
        }
        return { vertical: vertical, at: line.at, from: from, to: to };
    }

    function snap(rect, others, room, screenName) {
        const across = snapAxis(rect.x, rect.w, lines(others.map(o => ({ start: o.x, size: o.w })), room.w));
        const down = snapAxis(rect.y, rect.h, lines(others.map(o => ({ start: o.y, size: o.h })), room.h));
        const spot = { x: across.start, y: down.start, w: rect.w, h: rect.h };
        const next = [];
        if (across.line) next.push(guide(spot, others, across.line, true, room.h));
        if (down.line) next.push(guide(spot, others, down.line, false, room.w));
        show(next, screenName);
        return spot;
    }

    function show(next, screenName) {
        active = next.length > 0;
        if (next.length === 0) return;
        screen = screenName;
        if (JSON.stringify(next) !== JSON.stringify(guides)) guides = next;
    }

    function focus(x, y) {
        focusX = x;
        focusY = y;
    }

    function begin(screenName) {
        screen = screenName;
        dragging = true;
    }

    function release() {
        active = false;
    }

    function end() {
        active = false;
        dragging = false;
    }
}
