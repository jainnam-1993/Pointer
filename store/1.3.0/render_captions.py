#!/usr/bin/env -S uv run --script --quiet
# /// script
# dependencies = ["pillow"]
# ///
"""Render captioned store frames from raw store screenshots.

Usage: render_captions.py <shots dir> <out dir> <fonts dir> [device ...]
Shots are named <device>_<light|dark>_<n>_<screen>.png; captions come from CAPS (see captions.md).
The dark background is the app's night ambient as rendered (lib/widgets/ambient.dart, dark[night]:
top 0B0C1C with fields 34358A indigo and 52327E plum), sampled from the dark screenshots.
"""

import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

CAPS = [
    ("1_today", "One pointing. Right now.", "From Zen, Advaita and the Direct Path"),
    (
        "2_library",
        "Teachings, by tradition.",
        "Short readings and guided inquiries",
    ),
    ("3_saved", "Keep the lines that open you.", "Your favorites, always close"),
    ("4_inquiry", "A minute to look within.", "One question at a time"),
]
SIZES = {
    "iphone69": (1320, 2868),
    "ipad13": (2064, 2752),
    "play_phone": (1080, 2424),
    "play_tablet7": (1200, 1920),
    "play_tablet10": (2560, 1600),
}
THEMES = {
    # background stops (top, mid, bottom), headline ink, subtitle ink (>= 4.5:1 on the background)
    "light": (
        ((246, 241, 230), (244, 239, 227), (229, 236, 225)),
        (0x3A, 0x36, 0x30),
        (0x5E, 0x5A, 0x52),
    ),
    "dark": (
        ((28, 22, 51), (44, 35, 78), (39, 25, 45)),
        (246, 243, 252),
        (0xD2, 0xCE, 0xE0),
    ),
}


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def background(w, h, stops, dark):
    top, mid, bot = stops
    col = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / (h - 1)
        col.putpixel(
            (0, y), lerp(top, mid, t * 2) if t < 0.5 else lerp(mid, bot, (t - 0.5) * 2)
        )
    bg = col.resize((w, h))
    if dark:  # soft indigo and plum fields, as the ambient shader draws them
        glow = Image.new("RGB", (w, h), (0, 0, 0))
        g = ImageDraw.Draw(glow)
        g.ellipse((-w * 0.3, h * 0.05, w * 0.7, h * 0.45), fill=(0x34, 0x35, 0x8A))
        g.ellipse((w * 0.4, h * 0.55, w * 1.3, h * 1.0), fill=(0x52, 0x32, 0x7E))
        glow = glow.filter(ImageFilter.GaussianBlur(w * 0.25))
        bg = Image.blend(bg, glow, 0.22)
    return bg


def font(path, size, name):
    f = ImageFont.truetype(path, size)
    f.set_variation_by_name(name)
    return f


def drop_island(im):
    """Paint out the black Dynamic Island pill the simulator draws (on-device screenshots never show it)."""
    px = im.load()
    w = im.width
    for y in range(20, 140):
        row = [px[x, y] for x in range(int(w * 0.33), int(w * 0.67))]
        dark = [i for i, c in enumerate(row) if max(c) < 20]
        if len(dark) < 40:
            continue
        left = px[int(w * 0.31), y]
        for x in range(int(w * 0.33), int(w * 0.67)):
            if max(px[x, y]) < 60:
                px[x, y] = left
    return im


def render(shots, out, fonts, dev):
    W, H = SIZES[dev]
    portrait = H > W
    for mode, (stops, ink, sub) in THEMES.items():
        for key, line, second in CAPS:
            shot = Image.open(f"{shots}/{dev}_{mode}_{key}.png").convert("RGB")
            if dev == "iphone69":
                shot = drop_island(shot)
            can = background(W, H, stops, mode == "dark")
            d = ImageDraw.Draw(can)
            base = W if portrait else H
            f1 = font(f"{fonts}/Newsreader-Variable.ttf", int(base * 0.070), b"Medium")
            f2 = font(f"{fonts}/Inter-Variable.ttf", int(base * 0.040), b"Regular")
            top = int(H * (0.060 if portrait else 0.055))
            for txt, f, colr, gap in [
                (line, f1, ink, int(H * 0.016)),
                (second, f2, sub, 0),
            ]:
                tw = d.textlength(txt, font=f)
                d.text(((W - tw) / 2, top), txt, font=f, fill=colr)
                top += f.size + gap
            y = int(H * (0.215 if portrait else 0.26))
            if portrait:
                sw = int(W * 0.80)
                sh = int(shot.height * sw / shot.width)
                if y + sh > H - int(H * 0.04):  # keep the whole screen, bottom corners included
                    sh = H - y - int(H * 0.04)
                    sw = int(shot.width * sh / shot.height)
            else:
                sh = H - y - int(H * 0.05)
                sw = int(shot.width * sh / shot.height)
            s = shot.resize((sw, sh), Image.LANCZOS)
            x = (W - sw) // 2
            r = int(min(sw, sh) * 0.06)
            mask = Image.new("L", (sw, sh), 0)
            ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1), r, fill=255)
            shadow = Image.new("L", (W, H), 0)
            ImageDraw.Draw(shadow).rounded_rectangle(
                (x, y + 12, x + sw, y + sh + 12), r, fill=90
            )
            can.paste(
                Image.new("RGB", (W, H), (0, 0, 0)),
                (0, 0),
                shadow.filter(ImageFilter.GaussianBlur(28)),
            )
            can.paste(s, (x, y), mask)
            edge = (120, 112, 150) if mode == "dark" else (196, 186, 166)  # device edge on night or cream
            ImageDraw.Draw(can).rounded_rectangle((x, y, x + sw - 1, y + sh - 1), r, outline=edge, width=3)
            can.save(f"{out}/{dev}_{mode}_{key}_captioned.png")


if __name__ == "__main__":
    shots, out, fonts, *devs = sys.argv[1:]
    for dev in devs or SIZES:
        render(shots, out, fonts, dev)
