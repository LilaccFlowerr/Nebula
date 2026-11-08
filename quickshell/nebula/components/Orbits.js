.pragma library

const paths = [
    { rx: 150, ry: 70, tilt: -0.35, speed: 0.32, offset: 0.4 },
    { rx: 190, ry: 85, tilt: 0.5, speed: 0.22, offset: 2.2 },
    { rx: 120, ry: 110, tilt: 0.15, speed: 0.27, offset: 4.1 },
    { rx: 210, ry: 60, tilt: -0.8, speed: 0.18, offset: 5.3 },
    { rx: 170, ry: 95, tilt: 0.9, speed: 0.25, offset: 1.2 },
    { rx: 230, ry: 75, tilt: 0.3, speed: 0.2, offset: 3.3 },
    { rx: 140, ry: 90, tilt: -1.1, speed: 0.3, offset: 2.9 },
    { rx: 200, ry: 100, tilt: -0.1, speed: 0.16, offset: 0.9 }
];

const count = paths.length;

function at(index, time, scale) {
    const p = paths[index % paths.length];
    const a = time * p.speed * 2 + p.offset;
    const x = Math.cos(a) * p.rx * scale, y = Math.sin(a) * p.ry * scale;
    return { x: x * Math.cos(p.tilt) - y * Math.sin(p.tilt), y: x * Math.sin(p.tilt) + y * Math.cos(p.tilt), depth: (Math.sin(a) + 1) / 2 };
}
