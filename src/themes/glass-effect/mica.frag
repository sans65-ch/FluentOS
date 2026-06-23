/*
 * FluentOS Mica Effect Shader
 * 云母材质效果 - Windows 11 主要视觉效果
 *
 * 特点:
 * - 透明到半透明渐变
 * - 色调映射
 * - 微妙的不透明效果
 */

#include <common.glsl>

// uniform inputs
uniform float baseOpacity;     // 基础透明度
uniform float tintAmount;     // 染色强度
uniform vec4 tintColor;       // 染色颜色
uniform float saturation;     // 饱和度
uniform float brightness;     // 亮度
uniform float contrast;       // 对比度
uniform float noiseAmount;    // 噪点强度

// varying inputs
varying vec2 texCoord;
varying vec4 color;

// 噪声
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// HSV 转 RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// RGB 转 HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main(void) {
    // 获取背景纹理
    vec4 bgColor = texture2D(sampleTexture, texCoord);

    // 基础色调映射
    vec3 mappedColor = bgColor.rgb;

    // 应用饱和度调整
    if (saturation != 1.0) {
        vec3 hsv = rgb2hsv(mappedColor);
        hsv.y *= saturation;
        mappedColor = hsv2rgb(hsv);
    }

    // 应用亮度调整
    if (brightness != 0.0) {
        mappedColor += vec3(brightness);
    }

    // 应用对比度调整
    if (contrast != 1.0) {
        mappedColor = (mappedColor - 0.5) * contrast + 0.5;
    }

    // 应用染色
    if (tintAmount > 0.0 && tintColor.a > 0.0) {
        vec3 tintedColor = mix(mappedColor, tintColor.rgb, tintAmount * tintColor.a);
        mappedColor = mix(mappedColor, tintedColor, tintColor.a);
    }

    // 云母噪点 - 非常微妙
    if (noiseAmount > 0.0) {
        float n = noise(texCoord * 200.0) * 2.0 - 1.0;
        mappedColor += vec3(n * noiseAmount * 0.02);
    }

    // 垂直渐变 - 顶部更透明，底部更不透明 (模拟云母材质)
    float gradientFactor = smoothstep(0.0, 0.5, texCoord.y);
    float gradientOpacity = mix(baseOpacity + 0.2, baseOpacity, gradientFactor);

    // 确保 alpha 在有效范围内
    float finalAlpha = clamp(bgColor.a * gradientOpacity, 0.0, 1.0);

    // 轻微的边缘变暗效果
    vec2 edgeDist = abs(texCoord - 0.5) * 2.0;
    float edgeDarken = 1.0 - smoothstep(0.8, 1.0, max(edgeDist.x, edgeDist.y)) * 0.05;
    mappedColor *= edgeDarken;

    gl_FragColor = vec4(mappedColor, finalAlpha);
}
