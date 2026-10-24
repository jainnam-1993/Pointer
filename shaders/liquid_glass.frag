// Liquid Glass lens for the tab bar and rail, applied as a backdrop ImageFilter.shader (Impeller only).
//
// Coordinates: the engine binds the glass's backdrop as uTexture and its physical size as uSize. Everything else is
// computed in logical pixels of the glass box (uBox), so the maths uses small numbers and is the same at any
// devicePixelRatio. highp throughout: mediump breaks on the phone's GPU (phonefix's finding).
#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;   // 0-1: set by the engine, physical px of the bound backdrop
uniform vec2 uBox;    // 2-3: glass box size, logical px
uniform vec4 uShape;  // 4-7: corner radius, lens band width, refraction (px of displacement), light angle (rad)
uniform vec4 uLight;  // 8-11: rim alpha facing the light, rim alpha opposite, fresnel alpha, inner shadow alpha
uniform vec4 uRimColor; // 12-15: rim rgb, rim width (logical px)

uniform sampler2D uTexture;

out vec4 fragColor;

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec2 sdNormal(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  vec2 n = (q.x > 0.0 || q.y > 0.0) ? normalize(max(q, vec2(0.0))) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
  return n * sign(p + vec2(1e-4));
}

vec4 sampleBackdrop(vec2 uv) {
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTexture, clamp(uv, vec2(0.0), vec2(1.0)));
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 local = uv * uBox;
  vec2 halfBox = uBox * 0.5;
  vec2 p = local - halfBox;
  float radius = uShape.x;
  float band = max(uShape.y, 1.0);

  float d = sdRoundBox(p, halfBox, radius);
  if (d > 0.0) {
    fragColor = sampleBackdrop(uv);
    return;
  }

  float t = clamp(-d / band, 0.0, 1.0);  // 0 at the rim, 1 past the band
  float edge = 1.0 - t;
  vec2 n = sdNormal(p, halfBox, radius);

  // Lens: a convex rim pulls the backdrop inward, so content near the edge is magnified and bent.
  float slope = edge * edge;
  vec2 q = local - n * uShape.z * slope;
  vec4 col = sampleBackdrop(q / uBox);

  // Light from a key light; the rim facing it is bright, the far rim faint, with a fresnel lift at the edge.
  vec2 L = vec2(cos(uShape.w), sin(uShape.w));
  float facing = dot(n, -L);
  float rimBand = 1.0 - smoothstep(0.0, max(uRimColor.w, 0.5), -d);
  float rim = rimBand * (uLight.x * max(facing, 0.0) + uLight.y * max(-facing, 0.0));
  float fres = uLight.z * pow(edge, 5.0);
  float inner = uLight.w * (1.0 - smoothstep(0.0, 4.0, -d)) * max(-facing, 0.0);

  vec3 rgb = col.rgb;
  rgb = mix(rgb, uRimColor.rgb, clamp(rim + fres, 0.0, 1.0));
  rgb *= 1.0 - inner;
  fragColor = vec4(rgb, col.a);
}
