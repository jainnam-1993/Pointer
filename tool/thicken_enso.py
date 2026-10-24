#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow>=10", "numpy>=1.26"]
# ///
"""
Thicken the brush enso in the app icon master by a factor, keeping its taper and texture.

The enso is a ring of ink around a center. For every angle, the stroke has a
center line at radius r_mid(angle). Each output pixel at radius r samples the
source at r_mid + (r - r_mid) / factor along the same angle, so the stroke grows
the same proportion everywhere: the thick left side stays thicker than the thin
right side, and the dry-brush streaks widen with it.

Run from the repo root: tool/thicken_enso.py [factor] [--check]
It rewrites assets/icons/enso_icon.png. Then regenerate the platform icons:
  dart run flutter_launcher_icons && tool/make_icon_variants.py
  git checkout -- ios/Runner.xcodeproj/project.pbxproj android/app/src/main/res/values/colors.xml
flutter_launcher_icons 0.14.4 sets every ASSETCATALOG_COMPILER_* setting of the
PointerWidget extension to "AppIcon" (breaking its accent and background colors)
and strips the final newline of colors.xml, so restore both files after it runs.
--check prints the measured stroke width before and after without writing.
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MASTER = ROOT / "assets/icons/enso_icon.png"
BINS = 720


def ink(rgb: np.ndarray) -> np.ndarray:
    """Ink coverage 0..1 from luminance; the master is dark ink on white."""
    lum = rgb[..., :3] @ np.array([0.299, 0.587, 0.114])
    return np.clip((255.0 - lum) / (255.0 - 32.0), 0.0, 1.0)


def polar(shape, center):
    ys, xs = np.indices(shape, dtype=np.float64)
    dx, dy = xs - center[0], ys - center[1]
    return np.hypot(dx, dy), np.arctan2(dy, dx)


def smooth_circular(values: np.ndarray, width: int) -> np.ndarray:
    kernel = np.ones(width) / width
    padded = np.concatenate([values[-width:], values, values[:width]])
    return np.convolve(padded, kernel, mode="same")[width:-width]


def mid_radius(cov: np.ndarray, r: np.ndarray, theta: np.ndarray) -> np.ndarray:
    """Ink-weighted mean radius per angle bin, gaps filled and smoothed around the circle."""
    idx = ((theta + np.pi) / (2 * np.pi) * BINS).astype(int) % BINS
    weight = np.bincount(idx.ravel(), cov.ravel(), BINS)
    total = np.bincount(idx.ravel(), (cov * r).ravel(), BINS)
    mid = np.where(weight > 1.0, total / np.maximum(weight, 1e-9), np.nan)
    good = ~np.isnan(mid)
    angles = np.arange(BINS)
    mid = np.interp(angles, angles[good], mid[good], period=BINS)
    return smooth_circular(mid, 15)


def stroke_widths(cov: np.ndarray, r: np.ndarray, theta: np.ndarray) -> np.ndarray:
    """Ink area per angle bin divided by the arc length: the stroke width in px at each angle."""
    idx = ((theta + np.pi) / (2 * np.pi) * BINS).astype(int) % BINS
    area = np.bincount(idx.ravel(), (cov > 0.5).ravel().astype(float), BINS)
    radius = np.bincount(idx.ravel(), ((cov > 0.5) * r).ravel(), BINS) / np.maximum(
        area, 1
    )
    return area / np.maximum(radius * 2 * np.pi / BINS, 1e-9)


def bilinear(img: np.ndarray, x: np.ndarray, y: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    x = np.clip(x, 0, w - 1.001)
    y = np.clip(y, 0, h - 1.001)
    x0, y0 = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x - x0)[..., None], (y - y0)[..., None]
    a, b = img[y0, x0], img[y0, x0 + 1]
    c, d = img[y0 + 1, x0], img[y0 + 1, x0 + 1]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def thicken(src: np.ndarray, factor: float) -> np.ndarray:
    cov = ink(src)
    ys, xs = np.nonzero(cov > 0.5)
    center = ((xs.min() + xs.max()) / 2.0, (ys.min() + ys.max()) / 2.0)
    r, theta = polar(cov.shape, center)
    mid = mid_radius(cov, r, theta)
    bin_pos = (theta + np.pi) / (2 * np.pi) * BINS
    lo = np.floor(bin_pos).astype(int) % BINS
    frac = bin_pos - np.floor(bin_pos)
    r_mid = mid[lo] * (1 - frac) + mid[(lo + 1) % BINS] * frac
    r_src = r_mid + (r - r_mid) / factor
    return bilinear(
        src, center[0] + r_src * np.cos(theta), center[1] + r_src * np.sin(theta)
    )


def report(label: str, rgb: np.ndarray) -> None:
    cov = ink(rgb)
    ys, xs = np.nonzero(cov > 0.5)
    r, theta = polar(
        cov.shape, ((xs.min() + xs.max()) / 2.0, (ys.min() + ys.max()) / 2.0)
    )
    w = stroke_widths(cov, r, theta)
    w = w[w > 1]
    print(
        f"{label}: stroke width px median {np.median(w):.1f}, 10th pct {np.percentile(w, 10):.1f}, 90th pct {np.percentile(w, 90):.1f}"
    )


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    factor = float(args[0]) if args else 1.5
    src = np.asarray(Image.open(MASTER).convert("RGB"), dtype=np.float64)
    out = thicken(src, factor)
    report("before", src)
    report("after ", out)
    if "--check" in sys.argv:
        return
    Image.fromarray(np.clip(out + 0.5, 0, 255).astype(np.uint8), "RGB").convert(
        "RGBA"
    ).save(MASTER, optimize=True)
    print(f"wrote {MASTER.relative_to(ROOT)} (factor {factor})")


if __name__ == "__main__":
    main()
