#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 color1;
    vec4 color2;
    vec2 itemSize;
    float radius;
    float fillLevel;
    float waveAmp;
    float phase;
};

float roundBox(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 px = qt_TexCoord0 * itemSize;
    float d = roundBox(px - itemSize * 0.5, itemSize * 0.5, radius);
    float mask = 1.0 - smoothstep(-0.7, 0.7, d);

    float surface = itemSize.y * (1.0 - fillLevel);
    float u = px.x / itemSize.x;
    float wave = waveAmp * (sin(u * 9.4248 + phase) * 0.7 + sin(u * 15.708 - phase * 1.3) * 0.3);
    float below = px.y - (surface + wave);

    float filled = smoothstep(-0.8, 0.8, below);
    float depth = clamp(below / max(itemSize.y * fillLevel, 1.0), 0.0, 1.0);
    vec4 col = mix(color1, color2, depth);
    col.rgb += 0.10 * (1.0 - smoothstep(0.0, 7.0, below));

    float a = col.a * filled * mask * qt_Opacity;
    fragColor = vec4(col.rgb * a, a);
}
