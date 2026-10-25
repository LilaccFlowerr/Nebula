#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    vec4 glow;
};
layout(binding = 1) uniform sampler2D from;
layout(binding = 2) uniform sampler2D to;

float hash(float n) { return fract(sin(n * 12.9898) * 43758.5453); }

const float COLS = 34.0;
const float BAND = 0.14;

float frontAt(float x, out float fx, out float c) {
    float wob = (hash(floor(x * 7.0)) - 0.5) * 0.6;
    float cx = x * COLS + wob;
    c = floor(cx);
    fx = fract(cx);
    float delay = hash(c) * 0.45;
    float speed = 0.8 + hash(c + 31.7) * 0.7;
    float t = clamp((progress - delay) / (1.0 - delay), 0.0, 1.0);
    float eased = t * t * (3.0 - 2.0 * t);
    float tip = 1.0 - sqrt(max(0.0, 1.0 - pow(fx * 2.0 - 1.0, 2.0)));
    return eased * speed * (1.0 + BAND + 0.15) * 1.25 - tip * 0.035;
}

vec3 glitched(sampler2D tex, vec2 uv, float k, float c, float tick) {
    float fine = floor(uv.y * 140.0);
    float coarse = floor(uv.y * 22.0);
    float s1 = fine + c * 13.0 + tick * 7.0;
    float s2 = coarse + c * 5.0 + tick * 3.0;

    float jump = step(0.3, hash(s1 + 3.0)) * (hash(s1) - 0.5) * 0.18;
    float block = step(0.6, hash(s2 + 9.0)) * (hash(s2) - 0.5) * 0.3;
    uv.x += (jump + block) * k;

    float split = (0.012 + 0.03 * step(0.7, hash(s2 + 4.0))) * k;
    vec3 col;
    col.r = texture(tex, uv + vec2(split, 0.0)).r;
    col.g = texture(tex, uv + vec2(0.0, split * 0.3)).g;
    col.b = texture(tex, uv - vec2(split, 0.0)).b;

    float on = step(0.25, k);
    if (on > 0.0 && hash(s2 + 17.0) > 0.85) col = col.gbr;
    if (on > 0.0 && hash(s1 + 23.0) > 0.95) col = vec3(1.0) - col;
    float levels = mix(256.0, 5.0, step(0.75, hash(s2 + 41.0)) * k);
    col = floor(col * levels) / levels;

    float scan = 0.75 + 0.25 * step(0.5, fract(uv.y * 360.0));
    return mix(col, col * scan, k);
}

void main() {
    vec2 uv = qt_TexCoord0;
    float fx, c;
    float front = frontAt(uv.x, fx, c);
    float dist = front - uv.y;
    float live = step(0.001, progress) * (1.0 - smoothstep(0.85, 1.0, progress));
    float tick = floor(progress * 40.0);

    float tear = step(0.985, hash(floor(uv.y * 60.0) + tick * 11.0)) * live;

    if (dist <= 0.0) {
        float near = clamp(1.0 + dist / 0.05, 0.0, 1.0);
        float k = max(near * near * 0.6, tear) * live;
        vec3 col = glitched(from, uv, k, c, tick);
        col = mix(col, glow.rgb, smoothstep(-0.02, 0.0, dist) * 0.3 * live);
        fragColor = vec4(col, 1.0) * qt_Opacity;
        return;
    }

    float k = clamp(1.0 - dist / BAND, 0.0, 1.0);
    k = max(k * k, tear) * live;

    float pull = 0.12 * exp(-dist * 9.0) * live;
    vec3 col = glitched(to, vec2(uv.x, uv.y - pull), k, c, tick);

    float edge = smoothstep(0.02, 0.0, dist) * live;
    col = mix(col, glow.rgb, edge * 0.9);
    col += glow.rgb * k * 0.2;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
