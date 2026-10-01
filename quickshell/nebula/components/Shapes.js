.pragma library

const names = ["circle", "square", "diamond", "gem", "pill", "slanted", "ghost", "triangle",
    "pentagon", "arch", "cookie4", "cookie6", "cookie9", "cookie12", "clover4", "clover8"];

function len(x, y) {
    return Math.sqrt(x * x + y * y);
}

function segment(px, py, ax, ay, bx, by) {
    const dx = bx - ax, dy = by - ay;
    const t = Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)));
    return len(px - ax - t * dx, py - ay - t * dy);
}

function polygon(px, py, v) {
    let d = Infinity, inside = false;
    for (let i = 0, j = v.length - 1; i < v.length; j = i++) {
        d = Math.min(d, segment(px, py, v[j][0], v[j][1], v[i][0], v[i][1]));
        if ((v[i][1] > py) !== (v[j][1] > py)
            && px < (v[j][0] - v[i][0]) * (py - v[i][1]) / (v[j][1] - v[i][1]) + v[i][0])
            inside = !inside;
    }
    return inside ? -d : d;
}

function regular(n, r, turn) {
    const v = [];
    for (let i = 0; i < n; i++) {
        const a = turn + i * 2 * Math.PI / n;
        v.push([r * Math.cos(a), r * Math.sin(a)]);
    }
    return v;
}

const sdf = {
    circle: (x, y) => len(x, y) - 1,
    square: (x, y) => polygon(x, y, [[-0.7, -0.7], [0.7, -0.7], [0.7, 0.7], [-0.7, 0.7]]) - 0.3,
    diamond: (x, y) => polygon(x, y, [[0, -0.85], [0.65, 0], [0, 0.85], [-0.65, 0]]) - 0.15,
    gem: (x, y) => polygon(x, y, [[-0.4, -0.8], [0.4, -0.8], [0.8, -0.15], [0, 0.85], [-0.8, -0.15]]) - 0.15,
    pill: (x, y) => segment(x, y, -0.45, 0.45, 0.45, -0.45) - 0.5,
    slanted: (x, y) => polygon(x, y, [[-0.45, -0.75], [0.85, -0.75], [0.45, 0.75], [-0.85, 0.75]]) - 0.2,
    ghost: (x, y) => Math.min(
        len(x, y + 0.15) - 0.8,
        polygon(x, y, [[-0.8, -0.15], [0.8, -0.15], [0.8, 0.6], [-0.8, 0.6]]),
        len(x + 0.53, y - 0.6) - 0.27,
        len(x, y - 0.6) - 0.27,
        len(x - 0.53, y - 0.6) - 0.27),
    triangle: (x, y) => polygon(x, y, regular(3, 0.75, -Math.PI / 2)) - 0.25,
    pentagon: (x, y) => polygon(x, y, regular(5, 0.8, -Math.PI / 2)) - 0.2,
    arch: (x, y) => Math.min(len(x, y) - 0.85, polygon(x, y, [[-0.85, 0], [0.85, 0], [0.85, 0.85], [-0.85, 0.85]]) - 0.0)
};

function polar(name, a) {
    const m = name.match(/^(cookie|clover)(\d+)$/);
    const n = parseInt(m[2]);
    if (m[1] === "cookie") return 1 + Math.min(0.1, 0.45 / n) * Math.cos(n * a);
    const lobe = n <= 4 ? 0.75 : 0.5, c = 1 / (1 + lobe), rho = c * lobe;
    let sum = 0;
    for (let k = 0; k < n; k++) {
        const d = a - Math.PI / 4 * (n === 4 ? 1 : 0) - k * 2 * Math.PI / n;
        const s = c * Math.sin(d), co = c * Math.cos(d);
        if (Math.abs(s) < rho && co > 0) sum += Math.pow(co + Math.sqrt(rho * rho - s * s), 24);
    }
    return Math.pow(sum, 1 / 24);
}

function radius(name, a) {
    const f = sdf[name];
    if (!f) return polar(name, a);
    const cx = Math.cos(a), cy = Math.sin(a);
    let lo = 0, hi = 2;
    for (let i = 0; i < 24; i++) {
        const mid = (lo + hi) / 2;
        if (f(cx * mid, cy * mid) < 0) lo = mid;
        else hi = mid;
    }
    return lo;
}

function points(name, width, height) {
    const raw = [];
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (let i = 0; i <= 360; i += 2) {
        const a = i * Math.PI / 180;
        const r = radius(name, a);
        const x = r * Math.cos(a), y = r * Math.sin(a);
        raw.push([x, y]);
        minX = Math.min(minX, x); maxX = Math.max(maxX, x);
        minY = Math.min(minY, y); maxY = Math.max(maxY, y);
    }
    const s = Math.min(width / (maxX - minX), height / (maxY - minY));
    const ox = (width - (maxX - minX) * s) / 2 - minX * s;
    const oy = (height - (maxY - minY) * s) / 2 - minY * s;
    return raw.map(p => [ox + p[0] * s, oy + p[1] * s]);
}
