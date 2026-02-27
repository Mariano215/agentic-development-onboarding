#!/usr/bin/env python3
"""
Generate an Open Graph image (1200x630) for social media previews.
Uses pure SVG converted to PNG — no external dependencies beyond pillow.
"""

import os
import sys
from pathlib import Path


def main():
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("Installing pillow...")
        os.system(f"{sys.executable} -m pip install pillow")
        from PIL import Image, ImageDraw, ImageFont

    W, H = 1200, 630
    img = Image.new("RGB", (W, H), (10, 14, 26))
    draw = ImageDraw.Draw(img)

    # Grid lines (subtle)
    for x in range(0, W, 60):
        draw.line([(x, 0), (x, H)], fill=(255, 255, 255, 8), width=1)
    for y in range(0, H, 60):
        draw.line([(0, y), (W, y)], fill=(255, 255, 255, 8), width=1)

    # Gradient accent bar at top
    for x in range(W):
        r = int(0 + (139 - 0) * x / W)
        g = int(212 + (92 - 212) * x / W)
        b = int(255 + (246 - 255) * x / W)
        draw.line([(x, 0), (x, 4)], fill=(r, g, b))

    # Try to load a nice font, fall back to default
    title_font = None
    subtitle_font = None
    tag_font = None
    bold_candidates = [
        "/usr/share/fonts/truetype/ubuntu/Ubuntu-B.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    ]
    regular_candidates = [
        "/usr/share/fonts/truetype/ubuntu/Ubuntu-L.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    ]
    bold_path = next((p for p in bold_candidates if os.path.exists(p)), None)
    regular_path = next((p for p in regular_candidates if os.path.exists(p)), None)

    if bold_path and regular_path:
        title_font = ImageFont.truetype(bold_path, 72)
        subtitle_font = ImageFont.truetype(regular_path, 24)
        tag_font = ImageFont.truetype(regular_path, 18)
    elif bold_path:
        title_font = ImageFont.truetype(bold_path, 72)
        subtitle_font = ImageFont.truetype(bold_path, 24)
        tag_font = ImageFont.truetype(bold_path, 18)

    if not title_font:
        title_font = ImageFont.load_default()
        subtitle_font = title_font
        tag_font = title_font

    # Tag line
    draw.text((W // 2, 180), "AGENTIC DEVELOPMENT ONBOARDING", fill=(0, 212, 255),
              font=tag_font, anchor="mm")

    # Title
    draw.text((W // 2, 270), "VibeOps", fill=(240, 244, 255),
              font=title_font, anchor="mm")

    # Subtitle
    draw.text((W // 2, 370), '"We are not building AI to replace developers.', fill=(136, 146, 176),
              font=subtitle_font, anchor="mm")
    draw.text((W // 2, 405), 'We are building AI to make developers superhuman."', fill=(136, 146, 176),
              font=subtitle_font, anchor="mm")

    # Bottom bar
    draw.text((W // 2, 520), "5-Phase Methodology  |  Voice-Over Narration  |  Interactive Presentation",
              fill=(90, 99, 128), font=tag_font, anchor="mm")

    draw.text((W // 2, 570), "matteisystems.com/vibeops", fill=(0, 212, 255),
              font=tag_font, anchor="mm")

    # Gradient accent bar at bottom
    for x in range(W):
        r = int(139 + (0 - 139) * x / W)
        g = int(92 + (212 - 92) * x / W)
        b = int(246 + (255 - 246) * x / W)
        draw.line([(x, H - 4), (x, H)], fill=(r, g, b))

    output = Path(__file__).parent / "og-image.png"
    img.save(output, "PNG")
    print(f"OG image saved: {output} ({W}x{H})")


if __name__ == "__main__":
    main()
