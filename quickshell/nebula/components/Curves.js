.pragma library

function clamp(t) {
    return Math.max(0, Math.min(1, t));
}

function phase(t, start, length) {
    return clamp((t - start) / length);
}

function decel(t) {
    return 1 - Math.pow(1 - t, 3);
}

function back(t, overshoot) {
    const c1 = 1.70158 * overshoot, c3 = c1 + 1;
    return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}
