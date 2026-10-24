#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow>=10"]
# ///
"""
Derive the iOS 18 dark and tinted app icons and the Android themed (monochrome)
icon layer from the existing ink enso artwork.

The enso is black ink on white, so ink coverage is 255 minus luminance. That
coverage becomes the alpha of each variant:

- iOS dark:    light enso on opaque near-black, full bleed (iOS masks the corners).
- iOS tinted:  grayscale (white) enso on a transparent background; iOS tints it.
- Android:     single-color white enso silhouette per density; the launcher tints it.

Run from the repo root: tool/make_icon_variants.py
It also writes the AppIcon Contents.json appearance entries and the adaptive
icon <monochrome> layer. Re-running is idempotent.
"""

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageOps

ROOT = Path(__file__).resolve().parent.parent
IOS_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
IOS_SOURCE = IOS_SET / "Icon-App-1024x1024@1x.png"
ANDROID_RES = ROOT / "android/app/src/main/res"
ANDROID_SOURCE = ANDROID_RES / "drawable-xxxhdpi/ic_launcher_foreground.png"
ADAPTIVE_XML = ANDROID_RES / "mipmap-anydpi-v26/ic_launcher.xml"

NEAR_BLACK = (14, 14, 18)
DARK_INK = (237, 232, 222)  # warm off-white, reads as paper ink on black
# Android adaptive foreground is 108 dp; px per density.
DENSITIES = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}


def ink_mask(path: Path) -> Image.Image:
    """Ink coverage (0 paper, 255 ink) of a black-on-white image, composited on white first."""
    src = Image.open(path).convert("RGBA")
    flat = Image.new("RGBA", src.size, (255, 255, 255, 255))
    flat.alpha_composite(src)
    mask = ImageOps.invert(flat.convert("L"))
    # Lift faint paper noise to zero so edges stay clean on transparent backgrounds.
    return mask.point(lambda v: 0 if v < 8 else v)


def solid(size, color, mask: Image.Image) -> Image.Image:
    layer = Image.new("RGBA", size, color + (255,))
    layer.putalpha(mask)
    return layer


def ios_variants() -> None:
    mask = ink_mask(IOS_SOURCE)
    dark = Image.new("RGBA", mask.size, NEAR_BLACK + (255,))
    dark.alpha_composite(solid(mask.size, DARK_INK, mask))
    dark.convert("RGB").save(IOS_SET / "Icon-App-1024x1024-dark.png", optimize=True)
    solid(mask.size, (255, 255, 255), mask).save(IOS_SET / "Icon-App-1024x1024-tinted.png", optimize=True)

    contents_path = IOS_SET / "Contents.json"
    contents = json.loads(contents_path.read_text())
    images = [i for i in contents["images"] if i.get("idiom") != "universal"]
    base = {"idiom": "universal", "platform": "ios", "size": "1024x1024"}
    images += [
        {**base, "filename": IOS_SOURCE.name},
        {**base, "filename": "Icon-App-1024x1024-dark.png", "appearances": [{"appearance": "luminosity", "value": "dark"}]},
        {**base, "filename": "Icon-App-1024x1024-tinted.png", "appearances": [{"appearance": "luminosity", "value": "tinted"}]},
    ]
    contents["images"] = images
    contents_path.write_text(json.dumps(contents, indent=2) + "\n")


def android_monochrome() -> None:
    mask = ink_mask(ANDROID_SOURCE)
    for density, px in DENSITIES.items():
        m = mask.resize((px, px), Image.LANCZOS)
        out = ANDROID_RES / f"drawable-{density}/ic_launcher_monochrome.png"
        solid(m.size, (255, 255, 255), m).save(out, optimize=True)
    xml = ADAPTIVE_XML.read_text()
    if "<monochrome>" not in xml:
        layer = (
            "  <monochrome>\n"
            "      <inset\n"
            '          android:drawable="@drawable/ic_launcher_monochrome"\n'
            '          android:inset="16%" />\n'
            "  </monochrome>\n"
        )
        xml = xml.replace("</adaptive-icon>", layer + "</adaptive-icon>")
        ADAPTIVE_XML.write_text(xml)


if __name__ == "__main__":
    ios_variants()
    android_monochrome()
    print("icon variants written")
