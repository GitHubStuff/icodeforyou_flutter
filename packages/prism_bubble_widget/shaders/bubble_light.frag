// bubble_light.frag - Version 0.0.2

#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uTint;
uniform float uArcOpacity;
uniform float uDiffusion;
uniform float uPhaseAngle;

out vec4 fragColor;

const float PI = 3.14159265359;

// Subtractive thin-film interference tuned for bright light transmission
vec3 thinFilmInterferenceLight(float thickness, float cosTheta) {
    // Optical path difference based on film thickness and incident angle
    float opd = thickness * cosTheta;

    // Wavelength phase shifts (Red: 650nm, Green: 532nm, Blue: 450nm)
    vec3 phase = 2.0 * PI * opd * vec3(1.0 / 0.650, 1.0 / 0.532, 1.0 / 0.450);

    // Pigment-rich spectral dispersion (avoids washing out to gray on white)
    vec3 spectral = 0.5 + 0.5 * cos(phase);

    // Deepen saturation and contrast for transmission over white backgrounds
    vec3 saturated = mix(spectral, vec3(dot(spectral, vec3(0.299, 0.587, 0.114))), -0.45);
    return clamp(saturated, 0.0, 1.0);
}

void main() {
    // 1. Normalized coordinate space [-1.0, 1.0] with Cartesian +Y upwards
    vec2 localPos = FlutterFragCoord().xy;
    float minDim = min(uSize.x, uSize.y);
    vec2 uv = (localPos - (uSize * 0.5)) / (minDim * 0.5);
    uv.y = -uv.y;

    float r = length(uv);
    float radius = 0.90;
    float pixel = 2.0 / minDim;

    // Hard clip outside outer spherical boundary with smooth anti-aliasing
    if (r > radius + pixel) {
        fragColor = vec4(0.0);
        return;
    }

    // 2. 3D Hemispherical Normal Reconstruction
    float normR = clamp(r / radius, 0.0, 1.0);
    float zFront = sqrt(max(0.0, 1.0 - normR * normR));
    vec3 normalFront = vec3(uv / radius, zFront);
    vec3 normalBack = vec3(uv / radius, -zFront);

    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    float cosTheta = clamp(dot(normalFront, viewDir), 0.0, 1.0);

    // 3. Steep Fresnel Falloff (concentrates color density along rim)
    float fresnelPower = mix(4.2, 2.4, clamp(uDiffusion, 0.0, 1.0));
    float fresnel = pow(1.0 - cosTheta, fresnelPower);

    // 4. Thin-Film Iridescence Calculation
    float baseAngle = atan(uv.y, uv.x);
    // Dynamic film thickness variations (swirling soap currents)
    float thicknessGradient = 1.25 + 0.45 * sin(baseAngle * 2.0 + uPhaseAngle)
                                  + 0.35 * cos(normR * 5.0 - uPhaseAngle * 1.5);

    vec3 iridColor = thinFilmInterferenceLight(thicknessGradient, cosTheta);

    // Blend with user tint
    iridColor = mix(iridColor, uTint.rgb, uTint.a * 0.4);

    // 5. 3D Specular Highlights (Key Light + Internal Secondary Bounce)
    vec3 lightDirFront = normalize(vec3(-0.45, 0.55, 0.70));
    vec3 lightDirBack = normalize(vec3(0.35, -0.45, -0.60));

    vec3 halfFront = normalize(lightDirFront + viewDir);
    vec3 halfBack = normalize(lightDirBack + viewDir);

    // Front high-gloss specular flare
    float nDotHFront = max(0.0, dot(normalFront, halfFront));
    float specFront = pow(nDotHFront, 80.0);
    specFront += pow(nDotHFront, 20.0) * 0.20;

    // Back interior wall reflection
    float nDotHBack = max(0.0, dot(-normalBack, halfBack));
    float specBack = pow(nDotHBack, 40.0) * 0.28;

    float totalSpecular = (specFront + specBack) * uArcOpacity;

    // 6. Subtractive Rim Contour & Clean Composition
    float edgeAlpha = smoothstep(radius + pixel, radius - pixel, r);
    float diffusionSpread = mix(0.75, 0.98, clamp(uDiffusion, 0.0, 1.0));
    float rimProfile = smoothstep(diffusionSpread - 0.35, 0.98, normR);

    // Glass refraction edge density (darker, crisp definition on white)
    float filmAlpha = (fresnel * 0.75 + rimProfile * 0.25);
    filmAlpha = clamp(filmAlpha, 0.0, 1.0);

    // Glass perimeter shadow contour to cleanly define bubble boundary
    float glassEdge = smoothstep(0.86, 0.99, normR) * 0.18;
    vec3 edgeShadowColor = vec3(0.60, 0.68, 0.78);

    // Base thin-film composite
    vec3 finalRgb = iridColor;
    float finalAlpha = filmAlpha * 0.85;

    // Layer glass shadow edge for perimeter definition on white
    finalRgb = mix(finalRgb, edgeShadowColor, glassEdge);
    finalAlpha = max(finalAlpha, glassEdge);

    // Layer bright white specular highlights
    finalRgb = mix(finalRgb, vec3(1.0), totalSpecular);
    finalAlpha = max(finalAlpha, totalSpecular);

    // Anti-aliased outer boundary cut
    finalAlpha *= edgeAlpha;
    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    // Premultiplied alpha output
    fragColor = vec4(finalRgb * finalAlpha, finalAlpha);
}