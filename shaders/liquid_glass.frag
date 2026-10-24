// Liquid Glass optics for the tab bar and rail, applied as a backdrop ImageFilter.shader (Impeller only).
//
// fp16 safety: the phone's GPU (Adreno 750, Impeller Vulkan) runs this at half precision even when highp is declared.
// So the only pixel-sized value is FlutterFragCoord, and it is divided by uSize at once. All geometry is in "units" of
// the glass box's shorter side, so every intermediate stays within about +-8. Dart (liquidGlassUniforms) passes the
// box half-extents and every length already in units.
#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;     // 0-1: set by the engine, physical px of the bound backdrop
uniform vec2 uHalf;     // 2-3: half-extents of the glass box, units
uniform vec4 uShape;    // 4-7: corner radius, bevel band, refraction, rim width (units)
uniform vec4 uLight;    // 8-11: rim alpha on the lit (top-left) edge, rim alpha on the far edge, fresnel, top inner shadow
uniform vec4 uRimColor; // 12-15: rim rgb, bevel darkening
uniform vec4 uBody;     // 16-19: body saturation, bevel saturation, light direction x, light direction y

uniform sampler2D uTexture;

out vec4 fragColor;

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec2 sdNormal(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  vec2 n = (q.x > 0.0 || q.y > 0.0) ? normalize(max(q, vec2(0.0))) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
  return n * sign(p + vec2(1e-3));
}

vec4 sampleBackdrop(vec2 uv) {
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTexture, clamp(uv, vec2(0.0), vec2(1.0)));
}

vec3 saturateBy(vec3 c, float s) {
  float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
  return clamp(mix(vec3(l), c, s), 0.0, 1.0);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;   // 0..1, the only pixel-derived value
  vec2 p = (uv - 0.5) * 2.0 * uHalf;         // units, centred
  float radius = uShape.x;
  float band = max(uShape.y, 0.01);
  float rimW = max(uShape.w, 0.005);

  float d = sdRoundBox(p, uHalf, radius);
  if (d > 0.0) {
    fragColor = sampleBackdrop(uv);
    return;
  }
  float depth = -d;                           // 0 at the edge, growing inward
  float bevel = 1.0 - clamp(depth / band, 0.0, 1.0);
  vec2 n = sdNormal(p, uHalf, radius);

  // Bevel: the edge band bends the backdrop inward (a convex lens), so content near the edge is magnified.
  vec2 q = p - n * uShape.z * bevel * bevel;
  vec4 col = sampleBackdrop(q / (2.0 * uHalf) + 0.5);

  // Vibrancy: the body lifts the colour of what is behind it; the bevel adds a touch more and darkens slightly (thickness).
  vec3 base = col.a > 0.0 ? col.rgb / col.a : col.rgb;  // unpremultiply
  vec3 rgb = saturateBy(base, uBody.x + uBody.y * bevel);
  rgb *= 1.0 - uRimColor.w * bevel * bevel;

  // Specular rim: bright along the lit (top-left) edges and fading around the sides, faint on the far edge.
  vec2 lightDir = normalize(uBody.zw);
  float facing = dot(n, lightDir);
  float rimBand = 1.0 - smoothstep(0.0, rimW, depth);
  float rim = rimBand * (uLight.x * smoothstep(0.0, 0.9, facing) + uLight.y * smoothstep(0.0, 0.9, -facing));
  float fres = uLight.z * bevel * bevel * bevel * bevel;

  // Inner shadow just under the top rim, so the capsule reads as floating glass.
  float under = smoothstep(rimW, rimW * 2.0, depth) * (1.0 - smoothstep(rimW * 2.0, band * 1.6, depth));
  float inner = uLight.w * under * max(-n.y, 0.0);

  rgb = mix(rgb, uRimColor.rgb, clamp(rim + fres, 0.0, 1.0));
  rgb *= 1.0 - inner;
  fragColor = vec4(rgb * col.a, col.a);
}
