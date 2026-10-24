#!/usr/bin/env bash
# Before/after visual diff of the overhaul golden matrix between two git revisions.
#
# Usage: tool/visual_diff.sh <rev-a> <rev-b> [out-dir]
#   rev-b may be WORKTREE to compare against uncommitted goldens on disk.
#   Default out-dir: /workplace/jainnam/AgentResearch/PointerOptimize/visual/<rev-a>..<rev-b>/
#
# Writes into out-dir:
#   a/ b/                 extracted goldens at each revision
#   diff/<name>.png       per-image diff heatmap (changed pixels in red over a dimmed "after")
#   sheets/<screen>.png   contact sheet per screen: rows of before | after | diff heatmap
#   report.tsv            name, status (same|changed|added|removed|resized), diff_pct, changed_px, total_px
#   summary.txt           counts per status and the largest changes
set -euo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '2,13p' "$0"
  exit 2
fi

REV_A=$1
REV_B=$2
GOLDEN_DIR=test/golden/overhaul/goldens
REPO=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
OUT=${3:-/workplace/jainnam/AgentResearch/PointerOptimize/visual/${REV_A}..${REV_B}}

rm -rf "$OUT/a" "$OUT/b" "$OUT/diff" "$OUT/sheets"
mkdir -p "$OUT/a" "$OUT/b" "$OUT/diff" "$OUT/sheets"

extract() {
  local rev=$1 dest=$2
  if [[ $rev == WORKTREE ]]; then
    if [[ -d $REPO/$GOLDEN_DIR ]]; then cp "$REPO/$GOLDEN_DIR"/*.png "$dest"/ 2>/dev/null || true; fi
    return
  fi
  git -C "$REPO" rev-parse --verify --quiet "$rev^{commit}" >/dev/null || {
    echo "unknown revision: $rev" >&2
    exit 2
  }
  # Missing directory at this revision means no goldens yet (every image counts as added/removed).
  git -C "$REPO" ls-tree --name-only "$rev" "$GOLDEN_DIR/" 2>/dev/null | while read -r path; do
    [[ $path == *.png ]] || continue
    git -C "$REPO" show "$rev:$path" >"$dest/$(basename "$path")"
  done
}

extract "$REV_A" "$OUT/a"
extract "$REV_B" "$OUT/b"

SCRIPT=$(mktemp --suffix=.py)
trap 'rm -f "$SCRIPT"' EXIT
cat >"$SCRIPT" <<'PY'
#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow>=10"]
# ///
"""Pixel diff + contact sheets for the overhaul golden matrix."""
import sys
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

out = Path(sys.argv[1])
rev_a, rev_b = sys.argv[2], sys.argv[3]
a_dir, b_dir, diff_dir, sheet_dir = out / "a", out / "b", out / "diff", out / "sheets"
THUMB_H = 640  # contact sheet row height in pixels

names = sorted({p.name for p in a_dir.glob("*.png")} | {p.name for p in b_dir.glob("*.png")})
rows = []
per_screen = defaultdict(list)


def placeholder(size, label):
    img = Image.new("RGB", size, (40, 40, 40))
    ImageDraw.Draw(img).text((10, 10), label, fill=(220, 220, 220))
    return img


for name in names:
    pa, pb = a_dir / name, b_dir / name
    a = Image.open(pa).convert("RGBA") if pa.exists() else None
    b = Image.open(pb).convert("RGBA") if pb.exists() else None
    if a is None or b is None:
        status = "added" if a is None else "removed"
        ref = b if b is not None else a
        total = ref.width * ref.height
        rows.append((name, status, 100.0, total, total))
        heat = placeholder(ref.size, status)
    elif a.size != b.size:
        total = b.width * b.height
        rows.append((name, "resized", 100.0, total, total))
        heat = placeholder(b.size, f"resized {a.size} -> {b.size}")
    else:
        delta = ImageChops.difference(a, b)
        mask = delta.convert("L").point(lambda v: 255 if v > 0 else 0)
        changed = sum(1 for v in mask.getdata() if v)
        total = a.width * a.height
        pct = 100.0 * changed / total
        rows.append((name, "changed" if changed else "same", pct, changed, total))
        dim = Image.blend(b.convert("RGB"), Image.new("RGB", b.size, (0, 0, 0)), 0.7)
        heat = Image.composite(Image.new("RGB", b.size, (255, 0, 0)), dim, mask)
    heat.save(diff_dir / name)
    per_screen[name.split("_", 1)[0]].append((name, a, b, heat))

for screen, items in per_screen.items():
    tiles = []
    for name, a, b, heat in items:
        ref = b if b is not None else a
        scale = THUMB_H / ref.height
        w = max(1, int(ref.width * scale))
        cells = []
        for img, label in ((a, "before"), (b, "after"), (heat, "diff")):
            img = placeholder(ref.size, f"{label}: missing") if img is None else img.convert("RGB")
            cells.append(img.resize((w, THUMB_H)))
        tiles.append((name, cells, w))
    width = max(3 * w + 40 for _, _, w in tiles)
    sheet = Image.new("RGB", (width, len(tiles) * (THUMB_H + 30) + 30), (24, 24, 24))
    draw = ImageDraw.Draw(sheet)
    draw.text((10, 8), f"{screen}: {rev_a} (before) | {rev_b} (after) | diff (red = changed)", fill=(255, 255, 255))
    y = 30
    for name, cells, w in tiles:
        status = next(r for r in rows if r[0] == name)
        draw.text((10, y), f"{name}  {status[1]}  {status[2]:.3f}%", fill=(230, 230, 120))
        for i, cell in enumerate(cells):
            sheet.paste(cell, (10 + i * (w + 10), y + 14))
        y += THUMB_H + 30
    sheet.save(sheet_dir / f"{screen}.png")

with open(out / "report.tsv", "w") as f:
    f.write("name\tstatus\tdiff_pct\tchanged_px\ttotal_px\n")
    for r in rows:
        f.write(f"{r[0]}\t{r[1]}\t{r[2]:.4f}\t{r[3]}\t{r[4]}\n")

counts = defaultdict(int)
for r in rows:
    counts[r[1]] += 1
top = sorted((r for r in rows if r[1] == "changed"), key=lambda r: -r[2])[:15]
summary = [f"{rev_a}..{rev_b}: {len(rows)} images", *(f"  {k}: {v}" for k, v in sorted(counts.items()))]
if top:
    summary.append("largest changes:")
    summary += [f"  {r[2]:8.4f}%  {r[0]}" for r in top]
summary.append(f"sheets: {sheet_dir}")
(out / "summary.txt").write_text("\n".join(summary) + "\n")
print("\n".join(summary))
PY

uv run --script --quiet "$SCRIPT" "$OUT" "$REV_A" "$REV_B"
