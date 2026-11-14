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
    property var measures: []
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

    function snapAxis(start, size, lines, spaced) {
        let best = { start: start, line: null, refs: [], held: false };
        let reach = Theme.snap.distance;
        for (const line of lines) {
            const points = line.center ? [start + size / 2] : [start, start + size];
            for (const point of points) {
                const gap = Math.abs(line.at - point);
                if (gap > reach) continue;
                reach = gap;
                best = { start: start + line.at - point, line: line, refs: [], held: true };
            }
        }
        for (const option of spaced) {
            const gap = Math.abs(option.start - start);
            if (gap >= reach) continue;
            reach = gap;
            best = { start: option.start, line: null, refs: option.refs, held: true };
        }
        return best.held ? best : { start: gridAxis(start, size), line: null, refs: [], held: false };
    }

    function gridAxis(start, size) {
        if (!Settings.widgets.grid) return start;
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

    function axis(rect, horizontal) {
        return horizontal ? { start: rect.x, size: rect.w, cross: rect.y, crossSize: rect.h }
            : { start: rect.y, size: rect.h, cross: rect.x, crossSize: rect.w };
    }

    function moved(rect, horizontal, start) {
        return horizontal ? { x: start, y: rect.y, w: rect.w, h: rect.h } : { x: rect.x, y: start, w: rect.w, h: rect.h };
    }

    function overlaps(aStart, aSize, bStart, bSize) {
        return aStart < bStart + bSize - 0.5 && aStart + aSize > bStart + 0.5;
    }

    function neighbor(rect, others, horizontal, side) {
        const a = axis(rect, horizontal);
        let best = null;
        for (const o of others) {
            const b = axis(o, horizontal);
            if (!overlaps(a.cross, a.crossSize, b.cross, b.crossSize)) continue;
            const gap = side < 0 ? a.start - (b.start + b.size) : b.start - (a.start + a.size);
            if (gap < -0.5 || (best && gap >= best.gap)) continue;
            best = {
                other: o,
                gap: Math.max(0, gap),
                from: side < 0 ? b.start + b.size : a.start + a.size,
                mid: (Math.max(a.cross, b.cross) + Math.min(a.cross + a.crossSize, b.cross + b.crossSize)) / 2
            };
        }
        return best;
    }

    function measureOf(found, horizontal) {
        return {
            horizontal: horizontal,
            x: horizontal ? found.from : found.mid,
            y: horizontal ? found.mid : found.from,
            length: found.gap,
            value: Math.round(found.gap)
        };
    }

    function spacing(rect, others, horizontal) {
        const a = axis(rect, horizontal);
        const out = [];
        const offer = (start, side, other, ref) => {
            const found = neighbor(moved(rect, horizontal, start), others, horizontal, side);
            if (found && found.other === other && Math.abs(found.gap - ref.gap) < 0.5)
                out.push({ start: start, refs: [measureOf(ref, horizontal)] });
        };
        for (const o of others) {
            const ref = neighbor(o, others, horizontal, 1);
            if (!ref || ref.gap < 1) continue;
            for (const p of others) {
                const b = axis(p, horizontal);
                if (!overlaps(a.cross, a.crossSize, b.cross, b.crossSize)) continue;
                if (p !== o) offer(b.start + b.size + ref.gap, -1, p, ref);
                if (p !== ref.other) offer(b.start - ref.gap - a.size, 1, p, ref);
            }
        }
        const before = neighbor(rect, others, horizontal, -1);
        const after = neighbor(rect, others, horizontal, 1);
        if (before && after) {
            const start = (before.from + after.from + after.gap - a.size) / 2;
            const spot = moved(rect, horizontal, start);
            const left = neighbor(spot, others, horizontal, -1);
            const right = neighbor(spot, others, horizontal, 1);
            if (left && right && left.other === before.other && right.other === after.other && left.gap >= 1)
                out.push({ start: start, refs: [] });
        }
        return out;
    }

    function measureAll(rect, others, refs) {
        const out = [];
        for (const horizontal of [true, false])
            for (const side of [-1, 1]) {
                const found = neighbor(rect, others, horizontal, side);
                if (found && found.gap >= 1) out.push(measureOf(found, horizontal));
            }
        for (const ref of refs) {
            const text = JSON.stringify(ref);
            if (!out.some(m => JSON.stringify(m) === text)) out.push(ref);
        }
        if (JSON.stringify(out) !== JSON.stringify(measures)) measures = out;
    }

    function snap(rect, others, room, screenName) {
        const across = snapAxis(rect.x, rect.w, lines(others.map(o => ({ start: o.x, size: o.w })), room.w), spacing(rect, others, true));
        const midway = moved(rect, true, across.start);
        const down = snapAxis(rect.y, rect.h, lines(others.map(o => ({ start: o.y, size: o.h })), room.h), spacing(midway, others, false));
        const spot = moved(midway, false, down.start);
        const next = [];
        if (across.line) next.push(guide(spot, others, across.line, true, room.h));
        if (down.line) next.push(guide(spot, others, down.line, false, room.w));
        show(next, screenName);
        measureAll(spot, others, across.refs.concat(down.refs));
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
        if (measures.length > 0) measures = [];
    }

    function end() {
        active = false;
        dragging = false;
        if (measures.length > 0) measures = [];
    }
}
