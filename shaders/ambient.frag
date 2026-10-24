// Ambient background for Here Now: time-of-day gradient, slow aurora flow,
// drifting dust motes in three depth layers and a hash dither, in one pass.
//
// The same program draws "analytic frost" inside glass cards: the card paints
// this shader at its own global offset (uOrigin) with uFrost > 0, which widens
// the aurora, softens motes into discs and lifts lightness and saturation.
// That replaces a live BackdropFilter read of the moving background.
//
// Uniform order is load-bearing: lib/widgets/ambient/ambient_shader.dart sets
// them by index.
#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;     // 0-1   paint size (logical px)
uniform vec2 uOrigin;   // 2-3   global offset of this paint (logical px)
uniform vec2 uScreen;   // 4-5   full background size (logical px)
uniform float uTime;    // 6     seconds; frozen when motion is reduced
uniform float uFrost;   // 7     0 = background, 1 = full frost
uniform float uAurora;  // 8     aurora strength (0 for OLED)
uniform float uMotes;   // 9     mote strength
uniform float uDark;    // 10    1 = dark theme, 0 = light
uniform vec3 uTop;      // 11-13 base gradient
uniform vec3 uMid;      // 14-16
uniform vec3 uBottom;   // 17-19
uniform vec3 uAccA;     // 20-22 aurora field colors
uniform vec3 uAccB;     // 23-25
uniform vec3 uAccC;     // 26-28

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Two octaves only: cheap enough to run full screen at 30 fps on low-end GPUs.
float fbm2(vec2 p) {
  return 0.65 * noise(p) + 0.35 * noise(p * 2.03 + vec2(7.1, 3.7));
}

float field(vec2 p, vec2 c, float k) {
  vec2 d = p - c;
  return exp(-dot(d, d) * k);
}

void main() {
  vec2 frag = FlutterFragCoord().xy + uOrigin;
  vec2 screen = max(uScreen, vec2(1.0));
  vec2 uv = clamp(frag / screen, 0.0, 1.0);
  float aspect = screen.x / screen.y;
  float t = uTime;

  // Base vertical gradient with a slight diagonal lean.
  float g = clamp(uv.y * 0.85 + uv.x * 0.15, 0.0, 1.0);
  vec3 col = g < 0.5 ? mix(uTop, uMid, g * 2.0) : mix(uMid, uBottom, (g - 0.5) * 2.0);

  // Aurora: three soft color fields on slow Lissajous paths, sampled through a
  // domain warp so their edges flow instead of sliding as a band.
  vec2 q = vec2(uv.x * aspect, uv.y);
  vec2 w = vec2(fbm2(q * 1.7 + vec2(0.0, t * 0.021)), fbm2(q * 1.7 + vec2(5.2, -t * 0.018)));
  vec2 r = q + (w - 0.5) * (0.5 + 0.3 * uFrost);
  float k = mix(5.0, 3.2, uFrost);
  vec2 c1 = vec2(aspect * (0.22 + 0.10 * sin(t * 0.031)), 0.20 + 0.06 * cos(t * 0.023));
  vec2 c2 = vec2(aspect * (0.82 + 0.08 * cos(t * 0.027 + 1.3)), 0.50 + 0.08 * sin(t * 0.019 + 0.7));
  vec2 c3 = vec2(aspect * (0.42 + 0.12 * sin(t * 0.017 + 2.1)), 0.88 + 0.05 * cos(t * 0.029 + 0.4));
  float f1 = field(r, c1, k);
  float f2 = field(r, c2, k * 1.15);
  float f3 = field(r, c3, k * 0.9);
  float veil = 0.75 + 0.25 * fbm2(r * 3.0 - vec2(t * 0.012, 0.0));
  col = mix(col, uAccA, clamp(f1 * uAurora * veil, 0.0, 1.0));
  col = mix(col, uAccB, clamp(f2 * uAurora * veil, 0.0, 1.0));
  col = mix(col, uAccC, clamp(f3 * uAurora * veil, 0.0, 1.0));

  // Dust motes: three depth layers; nearer layers are larger, brighter, faster.
  float motes = 0.0;
  for (int l = 0; l < 3; l++) {
    float fl = float(l);
    float scale = 9.0 - fl * 2.5;
    vec2 drift = vec2(0.006, -0.012) * (1.0 + fl * 0.8) * t;
    vec2 cell = (q + drift) * scale;
    vec2 id = floor(cell);
    vec2 gv = fract(cell) - 0.5;
    float h = hash(id + fl * 17.13);
    if (h > mix(0.74, 0.8, uDark)) {
      vec2 off = (vec2(hash(id + 3.1), hash(id + 5.7)) - 0.5) * 0.5;
      float rad = mix(0.016, 0.03, hash(id + 9.3)) * (1.0 + uFrost * 0.5);
      float d = length(gv - off);
      float core = smoothstep(rad, rad * mix(0.25, 0.0, uFrost), d);
      float twinkle = 0.65 + 0.35 * sin(t * (0.5 + h) + h * 40.0);
      motes += core * twinkle * (0.45 + fl * 0.3);
    }
  }
  motes *= uMotes * mix(1.0, 0.15, uFrost);
  vec3 moteColor = uDark > 0.5 ? vec3(1.0, 0.95, 0.86) : vec3(1.0);
  col = mix(col, moteColor, clamp(motes, 0.0, 1.0));

  // Frost: lift lightness and boost saturation slightly.
  if (uFrost > 0.0) {
    float lum = dot(col, vec3(0.2126, 0.7152, 0.0722));
    col = mix(vec3(lum), col, 1.0 + 0.35 * uFrost);
    col += uFrost * mix(0.06, 0.035, uDark) * (1.0 - col);
  }

  // Static hash dither (+-0.5 LSB) against 8-bit banding in dark gradients.
  col += (hash(frag + 0.5) - 0.5) / 255.0;
  fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
