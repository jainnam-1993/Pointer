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

// fp16 safety is load-bearing. Mobile GPUs can run this shader at half
// precision (the vivo V2330's Adreno 750 under Impeller on Vulkan does, even
// with highp declared), and fp16's largest finite value is 65504. hash() used
// to scale raw fragment coordinates by up to 456.21, so it overflowed to
// inf/NaN past x = 65504 / 123.34 = 531 and y = 65504 / 456.21 = 144 logical
// px, and everything beyond painted black. hash() now wraps its input to
// [0, 32) first, so every intermediate stays below 14,600 at any precision,
// and the wrap doubles as the period that keeps the time-driven flow small.
// Desktop GPUs and the emulator run in fp32, which is why only the phone
// showed it. test/widgets/ambient_shader_precision_test.dart guards this.
precision highp float;

uniform vec2 uSize;     // 0-1   paint size (logical px)
uniform vec2 uOrigin;   // 2-3   global offset of this paint (logical px)
uniform vec2 uScreen;   // 4-5   full background size (logical px)
uniform float uFrost;   // 6     0 = background, 1 = full frost
uniform float uAurora;  // 7     aurora strength (0 for OLED)
uniform float uMotes;   // 8     mote strength
uniform float uDark;    // 9     1 = dark theme, 0 = light
uniform vec3 uTop;      // 10-12 base gradient
uniform vec3 uMid;      // 13-15
uniform vec3 uBottom;   // 16-18
uniform vec3 uAccA;     // 19-21 aurora field colors
uniform vec3 uAccB;     // 22-24
uniform vec3 uAccC;     // 25-27
// Time never reaches the GPU raw: at fp16 a clock of 300 s only resolves 0.25 s
// and 1100 s only 1 s, so motion would stall into steps as a session ages.
// AmbientShader.setUniforms turns time into small periodic values in fp64.
uniform vec4 uOrbitA;   // 28-31 field centers: sin(t*.031), cos(t*.023), cos(t*.027+1.3), sin(t*.019+.7)
uniform vec2 uOrbitB;   // 32-33 sin(t*.017+2.1), cos(t*.029+.4)
uniform vec3 uFlow;     // 34-36 noise flow t*.021, t*.018, t*.012, each mod kHashWrap
uniform vec4 uDrift0;   // 37-40 mote layer 0 drift in cells: fract.xy, floor mod kHashWrap .zw
uniform vec4 uDrift1;   // 41-44 layer 1
uniform vec4 uDrift2;   // 45-48 layer 2
uniform float uTwinkle; // 49    t*.5 mod 2*pi

out vec4 fragColor;

const float kHashWrap = 32.0;

float hash(vec2 p) {
  p = mod(p, kHashWrap);
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
// o is a flow offset that wraps at kHashWrap; the second octave moves at 2x so
// both octaves stay periodic in o and the wrap is seamless.
float fbm2(vec2 p, vec2 o) {
  return 0.65 * noise(p + o) + 0.35 * noise(p * 2.03 + o * 2.0 + vec2(7.1, 3.7));
}

float field(vec2 p, vec2 c, float k) {
  vec2 d = p - c;
  return exp(-dot(d, d) * k);
}

void main() {
  vec2 frag = FlutterFragCoord().xy + uOrigin;
  vec2 screen = max(uScreen, vec2(1.0));
  // No clamp: glass outside the screen bounds (horizontal lists) must not flatten.
  vec2 uv = frag / screen;
  float aspect = screen.x / screen.y;

  // Base vertical gradient with a slight diagonal lean.
  float g = clamp(uv.y * 0.85 + uv.x * 0.15, 0.0, 1.0);
  vec3 col = g < 0.5 ? mix(uTop, uMid, g * 2.0) : mix(uMid, uBottom, (g - 0.5) * 2.0);

  // Aurora: three soft color fields on slow Lissajous paths, sampled through a
  // domain warp so their edges flow instead of sliding as a band.
  vec2 q = vec2(uv.x * aspect, uv.y);
  vec2 w = vec2(fbm2(q * 1.7, vec2(0.0, uFlow.x)), fbm2(q * 1.7 + vec2(5.2, 0.0), vec2(0.0, -uFlow.y)));
  vec2 r = q + (w - 0.5) * (0.5 + 0.3 * uFrost);
  float k = mix(5.0, 3.2, uFrost);
  vec2 c1 = vec2(aspect * (0.22 + 0.10 * uOrbitA.x), 0.20 + 0.06 * uOrbitA.y);
  vec2 c2 = vec2(aspect * (0.82 + 0.08 * uOrbitA.z), 0.50 + 0.08 * uOrbitA.w);
  vec2 c3 = vec2(aspect * (0.42 + 0.12 * uOrbitB.x), 0.88 + 0.05 * uOrbitB.y);
  float f1 = field(r, c1, k);
  float f2 = field(r, c2, k * 1.15);
  float f3 = field(r, c3, k * 0.9);
  float veil = 0.75 + 0.25 * fbm2(r * 3.0, vec2(-uFlow.z, 0.0));
  col = mix(col, uAccA, clamp(f1 * uAurora * veil, 0.0, 1.0));
  col = mix(col, uAccB, clamp(f2 * uAurora * veil, 0.0, 1.0));
  col = mix(col, uAccC, clamp(f3 * uAurora * veil, 0.0, 1.0));

  // Dust motes: three depth layers; nearer layers are larger, brighter, faster.
  float motes = 0.0;
  for (int l = 0; l < 3; l++) {
    float fl = float(l);
    float scale = 9.0 - fl * 2.5;
    vec4 drift = l == 0 ? uDrift0 : (l == 1 ? uDrift1 : uDrift2);
    vec2 cell = q * scale + drift.xy;
    vec2 id = floor(cell) + drift.zw;
    vec2 gv = fract(cell) - 0.5;
    float h = hash(id + fl * 17.13);
    if (h > mix(0.74, 0.8, uDark)) {
      vec2 off = (vec2(hash(id + 3.1), hash(id + 5.7)) - 0.5) * 0.5;
      float rad = mix(0.016, 0.03, hash(id + 9.3)) * (1.0 + uFrost * 0.5);
      float d = length(gv - off);
      float core = smoothstep(rad, rad * mix(0.25, 0.0, uFrost), d);
      // Speeds 0.5, 1 and 1.5 rad/s: integer multiples keep the wrapped phase seamless.
      float twinkle = 0.65 + 0.35 * sin(uTwinkle * (1.0 + floor(hash(id + 11.7) * 3.0)) + h * 40.0);
      motes += core * twinkle * (0.45 + fl * 0.3);
    }
  }
  // Under glass the motes are off: on a dark card they read as specks in the glass.
  motes *= uMotes * (1.0 - uFrost);
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
