/*
 * FluentOS Acrylic Effect Shader
 * 亚克力材质效果 - Windows 11 云母效果前身
 *
 * 效果:
 * - 半透明背景
 * - 噪点纹理
 * - 微妙的光泽
 */

#include <common.glsl>

// uniform inputs
uniform float opacity;        // 透明度 (0.0 - 1.0)
uniform float noiseAmount;    // 噪点数量
uniform float noiseSize;      // 噪点大小
uniform float tintAmount;     // 染色强度
uniform vec4 tintColor;       // 染色颜色
uniform float luminance;      // 亮度调整
uniform float saturation;     // 饱和度调整

// varying inputs
varying vec2 texCoord;
varying vec4 color;

// 噪声函数
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 分形噪声 (更自然的纹理)
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }

    return value;
}

void main(void) {
    // 基础颜色
    vec4 baseColor = texture2D(sampleTexture, texCoord);

    // 创建亚克力噪点纹理
    vec2 noiseCoord = texCoord * noiseSize;
    float noisePattern = fbm(noiseCoord);
    noisePattern = mix(0.5, noisePattern, noiseAmount);

    // 应用噪点
    vec3 acrylicColor = baseColor.rgb;
    float noiseIntensity = (noisePattern - 0.5) * 0.1;
    acrylicColor += vec3(noiseIntensity);

    // 亮度调整
    if (luminance != 0.0) {
        float luma = dot(acrylicColor, vec3(0.299, 0.587, 0.114));
        acrylicColor = mix(vec3(luma), acrylicColor, 1.0 + luminance);
    }

    // 饱和度调整
    if (saturation != 1.0) {
        float luma = dot(acrylicColor, vec3(0.299, 0.587, 0.114));
        acrylicColor = mix(vec3(luma), acrylicColor, saturation);
    }

    // 染色
    if (tintAmount > 0.0 && tintColor.a > 0.0) {
        vec3 tintedColor = mix(acrylicColor, tintColor.rgb * tintAmount, tintColor.a * tintAmount);
        acrylicColor = mix(acrylicColor, tintedColor, tintColor.a);
    }

    // 微妙的光泽效果 - 边缘更亮
    float edgeFactor = 1.0 - smoothstep(0.2, 0.8, length(texCoord - vec2(0.5)));
    acrylicColor = mix(acrylicColor, acrylicColor * 1.05, edgeFactor * 0.3);

    // 应用透明度
    float finalAlpha = baseColor.a * opacity;

    gl_FragColor = vec4(acrylicColor, finalAlpha);
}
