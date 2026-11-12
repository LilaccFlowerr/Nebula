#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float cell;
    float base;
    float grown;
    float reach;
    float reveal;
    float band;
    float rest;
    vec2 area;
    vec2 origin;
    vec4 tint;
    vec4 shade;
    float halo;
};

void main() {
    vec2 p = qt_TexCoord0 * area;
    vec2 node = floor(p / cell + 0.5) * cell;
    float away = distance(node, origin);
    float near = 1.0 - smoothstep(reach * 0.3, reach, away);
    float wave = 1.0 - smoothstep(reveal - band, reveal, away);
    float front = wave * smoothstep(reveal - band * 2.5, reveal - band, away);
    float radius = mix(base, grown, max(near, front * 0.7)) * 0.5 * wave;
    float away2 = distance(p, node);
    float strength = mix(rest, 1.0, max(near, front)) * wave;
    float core = (1.0 - smoothstep(radius - 0.7, radius + 0.7, away2)) * strength;
    float ring = (1.0 - smoothstep(radius, radius + halo + 1.0, away2)) * shade.a * strength;
    vec4 under = vec4(shade.rgb, 1.0) * ring;
    fragColor = (vec4(tint.rgb, 1.0) * core + under * (1.0 - core)) * qt_Opacity;
}
