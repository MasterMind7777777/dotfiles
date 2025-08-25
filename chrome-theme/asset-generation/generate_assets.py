#!/usr/bin/env python3
import os
import random
import re
from pathlib import Path
from typing import Dict, Tuple

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
THEME_DIR = ROOT.parent / "cyberpunk-theme"
OUT = THEME_DIR / "images"
CSS_PALETTE = Path.home() / ".config/waybar/cyberpank.css"


def parse_palette(css_path: Path) -> Dict[str, Tuple[int, int, int]]:
    palette: Dict[str, Tuple[int, int, int]] = {}
    if not css_path.exists():
        raise FileNotFoundError(f"Palette CSS not found: {css_path}")
    pat = re.compile(r"@define-color\s+(\S+)\s+#([0-9a-fA-F]{6})")
    for line in css_path.read_text().splitlines():
        m = pat.search(line)
        if m:
            name = m.group(1)
            hexv = m.group(2)
            palette[name] = tuple(int(hexv[i : i + 2], 16) for i in (0, 2, 4))
    required = [
        "base","mantle","crust","surface0","surface1","surface2",
        "overlay0","overlay1","overlay2","neon-cyan","neon-magenta",
        "neon-blue","neon-yellow"
    ]
    missing = [k for k in required if k not in palette]
    if missing:
        raise KeyError(f"Missing palette keys in CSS: {missing}")
    return palette


def lerp(a: int, b: int, t: float) -> int:
    return int(round(a + (b - a) * t))


def vertical_gradient(size: Tuple[int, int], top: Tuple[int, int, int], bottom: Tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    pix = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = lerp(top[0], bottom[0], t)
        g = lerp(top[1], bottom[1], t)
        b = lerp(top[2], bottom[2], t)
        for x in range(w):
            pix[x, y] = (r, g, b)
    return img


def flat_fill(size: Tuple[int, int], color: Tuple[int, int, int]) -> Image.Image:
    return Image.new("RGB", size, color)


def add_fine_noise(img: Image.Image, amount: float = 0.02) -> Image.Image:
    w, h = img.size
    base = img.convert("RGB")
    noisy = Image.new("RGB", base.size)
    bp = base.load()
    npix = noisy.load()
    delta = int(255 * amount)
    for y in range(h):
        for x in range(w):
            r, g, b = bp[x, y]
            nr = max(0, min(255, r + random.randint(-delta, delta)))
            ng = max(0, min(255, g + random.randint(-delta, delta)))
            nb = max(0, min(255, b + random.randint(-delta, delta)))
            npix[x, y] = (nr, ng, nb)
    return Image.blend(base, noisy, 0.15)


def make_overlay(size: Tuple[int, int], color: Tuple[int, int, int], alpha: int = 96, height_px: int = 2) -> Image.Image:
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, w, max(0, height_px - 1)], fill=(*color, alpha))
    return img


def save(img: Image.Image, name: str):
    OUT.mkdir(parents=True, exist_ok=True)
    p = OUT / name
    img.save(p, format="PNG")
    print(f"wrote {p}")


def generate_all():
    palette = parse_palette(CSS_PALETTE)

    FRAME_W, FRAME_H = 1920, 60
    TAB_W, TAB_H = 1920, 96
    TOOLBAR_W, TOOLBAR_H = 1920, 160
    BUTTON_W, BUTTON_H = 1920, 48
    WINCTL_W, WINCTL_H = 400, 50
    ATTR_W, ATTR_H = 256, 64

    save(add_fine_noise(vertical_gradient((FRAME_W, FRAME_H), palette["mantle"], palette["base"]), 0.02),
         "theme_frame.png")
    save(add_fine_noise(vertical_gradient((FRAME_W, FRAME_H), palette["crust"], palette["base"]), 0.02),
         "theme_frame_inactive.png")
    save(add_fine_noise(vertical_gradient((FRAME_W, FRAME_H), palette["mantle"], palette["surface1"]), 0.02),
         "theme_frame_incognito.png")
    save(add_fine_noise(vertical_gradient((FRAME_W, FRAME_H), palette["crust"], palette["surface0"]), 0.02),
         "theme_frame_incognito_inactive.png")

    save(make_overlay((FRAME_W, FRAME_H), palette["neon-cyan"], alpha=88, height_px=2),
         "theme_frame_overlay.png")
    save(make_overlay((FRAME_W, FRAME_H), palette["overlay1"], alpha=64, height_px=2),
         "theme_frame_overlay_inactive.png")

    save(add_fine_noise(flat_fill((TAB_W, TAB_H), palette["surface1"]), 0.015),
         "theme_tab_background.png")
    save(add_fine_noise(flat_fill((TAB_W, TAB_H), palette["surface0"]), 0.015),
         "theme_tab_background_inactive.png")
    save(add_fine_noise(flat_fill((TAB_W, TAB_H), palette["surface2"]), 0.015),
         "theme_tab_background_incognito.png")
    save(add_fine_noise(flat_fill((TAB_W, TAB_H), palette["surface1"]), 0.015),
         "theme_tab_background_incognito_inactive.png")

    toolbar = add_fine_noise(vertical_gradient((TOOLBAR_W, TOOLBAR_H), palette["mantle"], palette["surface1"]), 0.01)
    save(toolbar, "theme_toolbar.png")

    btn = flat_fill((BUTTON_W, BUTTON_H), palette["mantle"]).convert("RGBA")
    glow = Image.new("RGBA", (BUTTON_W, BUTTON_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    draw.rectangle([0, 0, BUTTON_W, int(BUTTON_H * 0.25)], fill=(*palette["neon-cyan"], 26))
    btn = Image.alpha_composite(btn, glow)
    save(btn, "theme_button_background.png")

    wc = flat_fill((WINCTL_W, WINCTL_H), palette["mantle"]).convert("RGBA")
    vignette = Image.new("RGBA", (WINCTL_W, WINCTL_H), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    vd.rectangle([0, 0, WINCTL_W, WINCTL_H], outline=None, fill=(*palette["overlay0"], 20))
    wc = Image.alpha_composite(wc, vignette)
    save(wc, "theme_window_control_background.png")

    attr = Image.new("RGBA", (ATTR_W, ATTR_H), (0, 0, 0, 0))
    save(attr, "attribution.png")


if __name__ == "__main__":
    generate_all()

