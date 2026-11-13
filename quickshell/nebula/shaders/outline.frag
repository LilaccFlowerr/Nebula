#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float gap;
    float line;
    float amplitude;
    float count;
    float phase;
    vec2 texel;
    vec4 tint;
};
layout(binding = 1) uniform sampler2D source;

float reach(float radius) {
    float found = 0.0;
    for (int i = 0; i < 20; i++) {
        float angle = 6.2831853 * float(i) / 20.0;
        found = max(found, texture(source, qt_TexCoord0 + vec2(cos(angle), sin(angle)) * texel * radius).a);
    }
    return smoothstep(0.15, 0.45, found);
}

void main() {
    vec2 away = (qt_TexCoord0 - vec2(0.5)) / texel;
    float wave = amplitude * sin(atan(away.y, away.x) * count + phase);
    float inner = gap + amplitude + wave;
    float ring = reach(inner + line) * (1.0 - reach(inner));
    fragColor = vec4(tint.rgb, 1.0) * ring * qt_Opacity;
}
