.pragma library

function escape(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/ /g, "&nbsp;");
}

function cube(n) {
    if (n >= 232) {
        const g = 8 + (n - 232) * 10;
        return "rgb(" + g + "," + g + "," + g + ")";
    }
    const i = n - 16;
    const v = c => c === 0 ? 0 : 55 + c * 40;
    return "rgb(" + v(Math.floor(i / 36)) + "," + v(Math.floor(i / 6) % 6) + "," + v(i % 6) + ")";
}

function indexed(n, colors) {
    if (n < 16) return colors[n] ?? colors[n % 8] ?? null;
    return cube(n);
}

function extended(codes, i, colors) {
    if (codes[i + 1] === 5) return { color: indexed(codes[i + 2] ?? 0, colors), skip: 2 };
    if (codes[i + 1] === 2) return { color: "rgb(" + (codes[i + 2] ?? 0) + "," + (codes[i + 3] ?? 0) + "," + (codes[i + 4] ?? 0) + ")", skip: 4 };
    return { color: null, skip: 0 };
}

function apply(state, codes, colors) {
    if (codes.length === 0) codes = [0];
    for (let i = 0; i < codes.length; i++) {
        const c = codes[i];
        if (c === 0) { state.fg = null; state.bg = null; state.bold = false; }
        else if (c === 1) state.bold = true;
        else if (c === 22) state.bold = false;
        else if (c >= 30 && c <= 37) state.fg = indexed(c - 30 + (state.bold ? 8 : 0), colors);
        else if (c >= 90 && c <= 97) state.fg = indexed(c - 90 + 8, colors);
        else if (c >= 40 && c <= 47) state.bg = indexed(c - 40, colors);
        else if (c >= 100 && c <= 107) state.bg = indexed(c - 100 + 8, colors);
        else if (c === 39) state.fg = null;
        else if (c === 49) state.bg = null;
        else if (c === 38 || c === 48) {
            const e = extended(codes, i, colors);
            if (c === 38) state.fg = e.color; else state.bg = e.color;
            i += e.skip;
        }
    }
}

function span(text, state) {
    if (text === "") return "";
    let style = "";
    if (state.fg) style += "color:" + state.fg + ";";
    if (state.bold) style += "font-weight:700;";
    const out = escape(text);
    return style === "" ? out : "<span style=\"" + style + "\">" + out + "</span>";
}

function clean(raw) {
    return raw
        .replace(/\x1b\][^\x07\x1b]*(\x07|\x1b\\)/g, "")
        .replace(/\x1b\[\?[0-9;]*[A-Za-z]/g, "")
        .replace(/\x1b\[[0-9;]*[ABD-FH-Za-ln-z]/g, "")
        .replace(/\x1b[()][0-9A-Za-z]/g, "")
        .split("\n")
        .map(l => {
            const parts = l.split("\r");
            return parts.length > 1 && parts[parts.length - 1] === "" ? parts[parts.length - 2] : parts[parts.length - 1];
        })
        .map(l => l.replace(/\t/g, "        "));
}

const symbols = "●○◆◇■□▪▫█▀▄▌▐⬤";

function plain(line) {
    return line.replace(/\x1b\[[0-9;]*[CGm]/g, "");
}

function parse(raw, colors) {
    const lines = clean(raw ?? "");
    const state = { fg: null, bg: null, bold: false };
    const out = [];
    for (const line of lines) {
        let html = "";
        let text = "";
        let last = 0;
        const swatches = [];
        const re = /\x1b\[([0-9;]*)([CGm])/g;
        let m;
        const take = t => {
            if (t === "") return;
            if (state.bg && t.trim() === "") swatches.push(state.bg);
            for (const ch of t.replace(/\s/g, "")) if (symbols.includes(ch) && state.fg) swatches.push(state.fg);
            html += span(t, state);
            text += t;
        };
        while ((m = re.exec(line)) !== null) {
            take(line.slice(last, m.index));
            const n = parseInt(m[1]) || 1;
            if (m[2] === "m") apply(state, m[1] === "" ? [] : m[1].split(";").map(x => parseInt(x) || 0), colors ?? []);
            else if (m[2] === "C") take(" ".repeat(n));
            else take(" ".repeat(Math.max(0, n - 1 - text.length)));
            last = re.lastIndex;
        }
        take(line.slice(last));
        const palette = swatches.length > 0 && text.split("").every(ch => ch.trim() === "" || symbols.includes(ch));
        out.push({ html: html, text: text, palette: palette ? swatches : null });
    }
    while (out.length > 0 && !out[out.length - 1].palette && out[out.length - 1].text.trim() === "") out.pop();
    while (out.length > 0 && !out[0].palette && out[0].text.trim() === "") out.shift();
    return out;
}

function columns(lines) {
    return lines.reduce((w, l) => l.palette ? w : Math.max(w, l.text.replace(/\s+$/, "").length), 0);
}

function merge(lines) {
    const out = [];
    for (const l of lines) {
        const prev = out[out.length - 1];
        if (l.palette && prev && prev.palette) continue;
        out.push(l.palette ? { html: l.html, text: l.text, palette: l.palette.filter((c, i, a) => a.indexOf(c) === i) } : l);
    }
    return out;
}
