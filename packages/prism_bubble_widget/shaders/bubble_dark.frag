// bubble_dark.frag - Version 0.0.2

#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uTint;
uniform float uArcOpacity;
uniform float uDiffusion;
uniform float uPhaseAngle;

out vec4 fragColor;

const float PI = 3.14159265359;

// Thin-film interference spectral approximation
vec3 thinFilmInterference(float thickness, float cosTheta) {
    // Optical path difference based on film thickness and angle of incidence
    float opd = thickness * cosTheta;
    
    // Phase shifts for RGB wavelengths (Red: 650nm, Green: 532nm, Blue: 450nm)
    vec3 phase = 2.0 * PI * opd * vec3(1.0 / 0.650, 1.0 / 0.532, 1.0 / 0.450);
    
    // Construct interference pattern with pastels tuned for dark backgrounds
    vec3 spectral = 0.5 + 0.5 * cos(phase);
    
    // Boost luminance and vibrance for dark background contrast
    spectral = pow(spectral, vec3(1.2));
    return spectral;
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

    // 3. Physical Fresnel Reflection
    float fresnelPower = mix(3.5, 2.0, clamp(uDiffusion, 0.0, 1.0));
    float fresnel = pow(1.0 - cosTheta, fresnelPower);

    // 4. Thin-Film Iridescence Calculation
    float baseAngle = atan(uv.y, uv.x);
    // Dynamic film thickness variations (soap swirl gradient)
    float thicknessGradient = 1.2 + 0.4 * sin(baseAngle * 2.0 + uPhaseAngle) 
                                 + 0.3 * cos(normR * 5.0 - uPhaseAngle * 1.5);
    
    vec3 iridColor = thinFilmInterference(thicknessGradient, cosTheta);
    
    // Blend with user tint
    iridColor = mix(iridColor, iridColor * uTint.rgb, uTint.a * 0.7);

    // 5. 3D Specular Highlights (Front Key Light + Back-Wall Bounce)
    // Key light positioned at top-left
    vec3 lightDirFront = normalize(vec3(-0.45, 0.55, 0.70));
    // Bounce light positioned at bottom-right (transmitting from rear)
    vec3 lightDirBack = normalize(vec3(0.35, -0.45, -0.60));

    // Blinn-Phong half-vectors
    vec3 halfFront = normalize(lightDirFront + viewDir);
    vec3 halfBack = normalize(lightDirBack + viewDir);

    // Front specular glint (sharp & high intensity)
    float nDotHFront = max(0.0, dot(normalFront, halfFront));
    float specFront = pow(nDotHFront, 72.0);
    // Warp into elongated spherical surface reflection
    specFront += pow(nDotHFront, 16.0) * 0.25;

    // Back interior wall reflection (softer, inverted bounce)
    float nDotHBack = max(0.0, dot(-normalBack, halfBack));
    float specBack = pow(nDotHBack, 36.0) * 0.35;

    float totalSpecular = (specFront + specBack) * uArcOpacity;

    // 6. Volumetric Edge & Core Composition
    float edgeAlpha = smoothstep(radius + pixel, radius - pixel, r);
    float diffusionSpread = mix(0.70, 0.98, clamp(uDiffusion, 0.0, 1.0));
    float rimProfile = smoothstep(diffusionSpread - 0.4, 0.98, normR);
    
    // Core dome transparency (clear center, intense rim)
    float filmAlpha = (fresnel * 0.85 + rimProfile * 0.15);
    filmAlpha = clamp(filmAlpha, 0.0, 1.0);
    
    // Subtle translucent dome sheen
    float domeSheen = 0.04 * (1.0 - zFront);

    // Composite thin-film color
    vec3 finalRgb = iridColor * (filmAlpha + domeSheen);
    float finalAlpha = (filmAlpha + domeSheen);

    // Composite specular glints (pure luminous white / tint highlight)
    vec3 specColor = mix(vec3(1.0), uTint.rgb, uTint.a * 0.3);
    finalRgb = mix(finalRgb, specColor, totalSpecular);
    finalAlpha = max(finalAlpha, totalSpecular);

    // Apply anti-aliased perimeter edge clipping
    finalAlpha *= edgeAlpha;
    finalAlpha = clamp(finalAlpha, 0.0, 1.0);

    // Premultiplied alpha output
    fragColor = vec4(finalRgb * finalAlpha, finalAlpha);
}