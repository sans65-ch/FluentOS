/*
 * FluentOS Glass Effect Shader
 * 液态玻璃效果 - 基于 KWin GL shader
 *
 * 效果:
 * - 背景模糊
 * - 边缘高光
 * - 渐变透明度
 * - 轻微的色彩偏移
 */

#include <common.glsl>

// uniform inputs
uniform float strength;        // 模糊强度 (0.0 - 1.0)
uniform float radius;         // 模糊半径
uniform vec4 tintColor;       // 染色颜色
uniform float tintOpacity;    // 染色透明度
uniform float highlight;      // 高光强度
uniform float borderRadius;   // 边框圆角
uniform bool noise;           // 是否添加噪点纹理
uniform float noiseStrength;  // 噪点强度

// varying inputs
varying vec2 texCoord;
varying vec4 color;

// 噪声函数 (用于纹理)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise2D(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 模糊函数 (双线性滤波)
vec4 blur9(sampler2D tex, vec2 uv, vec2 resolution, vec2 direction) {
    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.3846153846) * direction;
    vec2 off2 = vec2(3.2307692308) * direction;

    color += texture2D(tex, uv) * 0.2270270270;
    color += texture2D(tex, uv + (off1 / resolution)) * 0.3162162162;
    color += texture2D(tex, uv - (off1 / resolution)) * 0.3162162162;
    color += texture2D(tex, uv + (off2 / resolution)) * 0.0702702703;
    color += texture2D(tex, uv - (off2 / resolution)) * 0.0702702703;

    return color;
}

// 主函数
void main(void) {
    // 获取屏幕纹理
    vec2 texSize = vec2(textureSize(sampleTexture, 0));
    vec4 origColor = texture2D(sampleTexture, texCoord);

    // 基础模糊
    vec4 blurred = blur9(sampleTexture, texCoord, texSize, vec2(1.0) * radius);

    // 边缘检测 - 用于高光
    vec4 blurH = blur9(sampleTexture, texCoord, texSize, vec2(1.0, 0.0) * radius);
    vec4 blurV = blur9(sampleTexture, texCoord, texSize, vec2(0.0, 1.0) * radius);
    vec4 edgeColor = abs(blurH - blurred) + abs(blurV - blurred);

    // 边缘高光
    float edgeFactor = smoothstep(0.0, 0.15, length(edgeColor.rgb));
    vec3 highlightColor = mix(origColor.rgb, vec3(1.0), edgeFactor * highlight);

    // 应用模糊强度
    vec3 finalColor = mix(origColor.rgb, blurred.rgb, strength);

    // 添加染色
    if (tintOpacity > 0.0) {
        finalColor = mix(finalColor, tintColor.rgb, tintOpacity * tintColor.a);
    }

    // 添加噪点纹理
    if (noise && noiseStrength > 0.0) {
        float noiseVal = noise2D(texCoord * 100.0) * 2.0 - 1.0;
        finalColor += vec3(noiseVal * noiseStrength);
    }

    // 添加高光
    finalColor = mix(finalColor, highlightColor, edgeFactor * highlight * 0.5);

    // 轻微的色彩偏移 (Chromatic aberration)
    if (strength > 0.3) {
        float aberration = strength * 0.002;
        vec2 dir = normalize(texCoord - vec2(0.5)) * aberration;
        float r = texture2D(sampleTexture, texCoord + dir).r;
        float b = texture2D(sampleTexture, texCoord - dir).b;
        finalColor.r = mix(finalColor.r, r, strength * 0.3);
        finalColor.b = mix(finalColor.b, b, strength * 0.3);
    }

    // 输出
    gl_FragColor = vec4(finalColor, origColor.a);
}
