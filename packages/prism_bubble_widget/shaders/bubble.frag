#version 460 core

#include <flutter/runtime_effect.glsl>

// Version 0.0.11-alpha

uniform vec2 uSize;
uniform vec4 uTint;
uniform float uArcOpacity;
uniform float uDiffusion;
uniform float uPhaseAngle;

out vec4 fragColor;

const float PI = 3.14159265359;

// Signed distance function for rounded arc capsule
float sdArc(vec2 p, float sca, float scb, float r, float thickness) {
    vec2 sc = vec2(sin(scb), cos(scb));
    p = mat2(cos(sca), -sin(sca), sin(sca), cos(sca)) * p;
    p.x = abs(p.x);
    float k = (sc.y * p.x > sc.x * p.y) ? dot(p, sc) : length(p);
    return sqrt(dot(p, p) + r * r - 2.0 * r * k) - thickness;
}

void main() {
    // 1. Normalized coordinate space [-1.0, 1.0]
    vec2 localPos = FlutterFragCoord().xy;
    float minDim = min(uSize.x, uSize.y);
    vec2 uv = (localPos - (uSize * 0.5)) / (minDim * 0.5);
    uv.y = -uv.y; // Cartesian +Y is UP

    float r = length(uv);
    float baseAngle = atan(uv.y, uv.x); // [-PI, PI]
    float radius = 0.88;
    float pixel = 2.0 / minDim;

    // Hard clip outside outer boundary
    if (r > radius + 0.08) {
        fragColor = vec4(0.0);
        return;
    }

    // Swirling phase angle for liquid rotation
    float angle = mod(baseAngle + uPhaseAngle + PI, 2.0 * PI) - PI;

    // 2. Continuous pastel rainbow palette along the perimeter
    vec3 colBlue       = vec3(0.65, 0.72, 0.98);
    vec3 colMagenta    = vec3(0.92, 0.68, 0.92);
    vec3 colCyan       = vec3(0.68, 0.95, 0.88);
    vec3 colPeach      = vec3(0.98, 0.82, 0.65);

    vec3 colGold       = vec3(0.95, 0.88, 0.55);
    vec3 colLavender   = vec3(0.85, 0.75, 0.95);
    vec3 colPeriwinkle = vec3(0.68, 0.75, 0.98);

    // Top arc angular color blending (angle ~ 0.5 to 2.6)
    vec3 topColor = vec3(0.0);
    topColor += colBlue    * clamp(1.0 - abs(angle - 2.4) * 2.2, 0.0, 1.0);
    topColor += colMagenta * clamp(1.0 - abs(angle - 1.6) * 2.0, 0.0, 1.0);
    topColor += colCyan    * clamp(1.0 - abs(angle - 0.9) * 2.0, 0.0, 1.0);
    topColor += colPeach   * clamp(1.0 - abs(angle - 0.3) * 2.2, 0.0, 1.0);

    // Bottom arc angular color blending (angle ~ -2.7 to -0.3)
    vec3 bottomColor = vec3(0.0);
    bottomColor += colGold       * clamp(1.0 - abs(angle + 2.5) * 2.2, 0.0, 1.0);
    bottomColor += colLavender   * clamp(1.0 - abs(angle + 1.9) * 2.0, 0.0, 1.0);
    bottomColor += colPeriwinkle * clamp(1.0 - abs(angle + 1.2) * 2.0, 0.0, 1.0);
    bottomColor += colCyan       * clamp(1.0 - abs(angle + 0.5) * 2.2, 0.0, 1.0);

    vec3 rimColor = topColor + bottomColor;

    // Shift rim color tones with background tint if provided
    rimColor = mix(rimColor, rimColor * uTint.rgb, uTint.a);

    // 3. Radial Gaussian profile with controllable diffusion/refraction width
    float dynamicWidth = mix(0.035, 0.12, clamp(uDiffusion, 0.0, 1.0));
    float radialDist = (r - radius) / dynamicWidth;
    float radialProfile = exp(-0.5 * radialDist * radialDist);
    float colorAlpha = radialProfile * mix(0.60, 0.85, clamp(uDiffusion, 0.0, 1.0));

    // 4. Exact 1px full-circle continuous outer boundary closure
    float circleLineDist = abs(r - radius);
    float fullPerimeterLine = 1.0 - smoothstep(pixel * 0.4, pixel * 1.4, circleLineDist);

    // 5. Stylized inner flourish arcs (Top-Left and Bottom-Right)
    float dArc1 = sdArc(uv, -2.35, 0.30, 0.76, 0.026);
    float arc1 = 1.0 - smoothstep(0.0, pixel * 1.5, dArc1);

    float dArc2 = sdArc(uv, 0.87, 0.22, 0.77, 0.022);
    float arc2 = 1.0 - smoothstep(0.0, pixel * 1.5, dArc2);

    float flourishMask = clamp(arc1 + arc2, 0.0, 1.0);
    vec3 flourishColor = mix(vec3(1.0), uTint.rgb, uTint.a);
    float flourishAlpha = flourishMask * uArcOpacity;

    // 6. Composite Output (Center is transparent: alpha = 0.0)
    vec3 finalRgb = rimColor * colorAlpha;
    float finalAlpha = colorAlpha;

    // 1px outer rim
    vec3 ringColor = mix(vec3(1.0), uTint.rgb, uTint.a * 0.4);
    finalRgb = mix(finalRgb, ringColor, fullPerimeterLine * 0.85);
    finalAlpha = max(finalAlpha, fullPerimeterLine * 0.85);

    // Tinted flourish arcs
    finalRgb = mix(finalRgb, flourishColor, flourishAlpha);
    finalAlpha = max(finalAlpha, flourishAlpha);

    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    // Premultiplied alpha output
    fragColor = vec4(finalRgb * finalAlpha, finalAlpha);
}