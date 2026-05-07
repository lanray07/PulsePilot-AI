from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "AppStore" / "Screenshots" / "iPhone-6.5"

W, H = 1284, 2778
TAB_TOP = 2506

BG_TOP = (8, 12, 18)
BG_BOTTOM = (15, 22, 32)
SURFACE = (25, 31, 43)
SURFACE_2 = (34, 41, 56)
TEXT = (246, 248, 252)
MUTED = (151, 160, 174)
SUBTLE = (71, 81, 98)
ACCENT = (91, 227, 138)
MINT = (97, 231, 192)
CORAL = (255, 122, 102)
AMBER = (245, 200, 91)
SKY = (99, 167, 255)
VIOLET = (155, 140, 255)


def font(size: int, weight: str = "regular") -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    font_dir = Path("C:/Windows/Fonts")
    candidates = {
        "regular": ["segoeui.ttf", "arial.ttf"],
        "semibold": ["seguisb.ttf", "arialbd.ttf"],
        "bold": ["segoeuib.ttf", "arialbd.ttf"],
    }

    for name in candidates.get(weight, candidates["regular"]):
        path = font_dir / name
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


F = {
    "nav": font(70, "bold"),
    "title": font(56, "bold"),
    "h1": font(48, "bold"),
    "h2": font(38, "bold"),
    "h3": font(32, "semibold"),
    "body": font(30),
    "body_bold": font(30, "semibold"),
    "small": font(25),
    "small_bold": font(25, "semibold"),
    "tiny": font(22, "semibold"),
    "score": font(78, "bold"),
    "score_small": font(52, "bold"),
}


def lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def blend(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(lerp(a, b, t) for a, b in zip(c1, c2))


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    image = Image.new("RGB", (w, h), top)
    px = image.load()
    for y in range(h):
        c = blend(top, bottom, y / max(1, h - 1))
        for x in range(w):
            px[x, y] = c
    return image


def horizontal_gradient(size: tuple[int, int], left: tuple[int, int, int], right: tuple[int, int, int]) -> Image.Image:
    w, h = size
    image = Image.new("RGB", (w, h), left)
    px = image.load()
    for x in range(w):
        c = blend(left, right, x / max(1, w - 1))
        for y in range(h):
            px[x, y] = c
    return image


def paste_rounded(img: Image.Image, box: tuple[int, int, int, int], fill: Image.Image | tuple[int, int, int], radius: int) -> None:
    x1, y1, x2, y2 = box
    w, h = x2 - x1, y2 - y1
    patch = fill if isinstance(fill, Image.Image) else Image.new("RGB", (w, h), fill)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w, h), radius=radius, fill=255)
    img.paste(patch, (x1, y1), mask)


def card(img: Image.Image, box: tuple[int, int, int, int], fill: tuple[int, int, int] = SURFACE, radius: int = 42) -> None:
    paste_rounded(img, box, fill, radius)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(box, radius=radius, outline=(44, 52, 68), width=2)


def gradient_card(img: Image.Image, box: tuple[int, int, int, int], left: tuple[int, int, int], right: tuple[int, int, int], radius: int = 46) -> None:
    x1, y1, x2, y2 = box
    grad = horizontal_gradient((x2 - x1, y2 - y1), left, right)
    overlay = Image.new("RGB", grad.size, (11, 16, 24))
    grad = Image.blend(grad, overlay, 0.68)
    paste_rounded(img, box, grad, radius)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(box, radius=radius, outline=(255, 255, 255, 38), width=2)


def text_width(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.ImageFont) -> int:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0]


def draw_wrapped(
    draw: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    fnt: ImageFont.ImageFont,
    fill: tuple[int, int, int],
    max_width: int,
    line_gap: int = 8,
) -> int:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = word if not current else f"{current} {word}"
        if text_width(draw, trial, fnt) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)

    x, y = xy
    line_height = draw.textbbox((0, 0), "Ag", font=fnt)[3] + line_gap
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill)
        y += line_height
    return y


def draw_status(draw: ImageDraw.ImageDraw) -> None:
    draw.text((72, 42), "9:41", font=F["small_bold"], fill=TEXT)
    x = 1058
    for i, h in enumerate([14, 20, 27, 34]):
        draw.rounded_rectangle((x + i * 14, 72 - h, x + 8 + i * 14, 72), radius=4, fill=TEXT)
    draw.arc((1132, 44, 1182, 82), 205, 335, fill=TEXT, width=6)
    draw.arc((1145, 56, 1169, 84), 205, 335, fill=TEXT, width=6)
    draw.rounded_rectangle((1200, 48, 1260, 78), radius=8, outline=TEXT, width=3)
    draw.rounded_rectangle((1262, 58, 1268, 68), radius=2, fill=TEXT)
    draw.rounded_rectangle((1206, 54, 1248, 72), radius=5, fill=TEXT)


def draw_nav(draw: ImageDraw.ImageDraw, title: str) -> None:
    draw.text((72, 128), title, font=F["nav"], fill=TEXT)


def draw_tab_bar(draw: ImageDraw.ImageDraw, selected: str) -> None:
    draw.rounded_rectangle((0, TAB_TOP, W, H), radius=46, fill=(13, 18, 27))
    draw.line((0, TAB_TOP, W, TAB_TOP), fill=(39, 47, 61), width=2)
    tabs = [("Today", "T"), ("Missions", "M"), ("Coach", "C"), ("Weekly", "W"), ("Settings", "S")]
    step = W // len(tabs)
    for index, (label, icon) in enumerate(tabs):
        cx = step * index + step // 2
        active = label == selected
        color = ACCENT if active else MUTED
        bg = (32, 55, 45) if active else (29, 35, 47)
        draw.ellipse((cx - 32, TAB_TOP + 38, cx + 32, TAB_TOP + 102), fill=bg)
        tw = text_width(draw, icon, F["small_bold"])
        draw.text((cx - tw // 2, TAB_TOP + 54), icon, font=F["small_bold"], fill=color)
        tw = text_width(draw, label, F["tiny"])
        draw.text((cx - tw // 2, TAB_TOP + 118), label, font=F["tiny"], fill=color)
    draw.rounded_rectangle((492, H - 48, 792, H - 34), radius=7, fill=(231, 236, 244))


def base(title: str, selected: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = vertical_gradient((W, H), BG_TOP, BG_BOTTOM)
    draw = ImageDraw.Draw(img)
    draw_status(draw)
    draw_nav(draw, title)
    draw_tab_bar(draw, selected)
    return img, draw


def draw_score(draw: ImageDraw.ImageDraw, center: tuple[int, int], radius: int, score: int, label: str, color: tuple[int, int, int]) -> None:
    x, y = center
    box = (x - radius, y - radius, x + radius, y + radius)
    draw.ellipse(box, outline=(62, 70, 84), width=22)
    draw.arc(box, start=-90, end=-90 + int(score * 3.6), fill=color, width=22)
    score_text = str(score)
    tw = text_width(draw, score_text, F["score"])
    draw.text((x - tw // 2, y - 58), score_text, font=F["score"], fill=TEXT)
    tw = text_width(draw, label, F["small_bold"])
    draw.text((x - tw // 2, y + 30), label, font=F["small_bold"], fill=MUTED)


def metric(draw: ImageDraw.ImageDraw, img: Image.Image, box: tuple[int, int, int, int], title: str, value: str, subtitle: str, color: tuple[int, int, int]) -> None:
    card(img, box, SURFACE_2, radius=36)
    x1, y1, _, _ = box
    draw.ellipse((x1 + 36, y1 + 36, x1 + 92, y1 + 92), fill=tuple(max(0, c // 4) for c in color))
    draw.text((x1 + 54, y1 + 47), "•", font=F["h2"], fill=color)
    draw.text((x1 + 36, y1 + 114), title, font=F["small_bold"], fill=MUTED)
    draw.text((x1 + 36, y1 + 156), value, font=F["h2"], fill=TEXT)
    draw.text((x1 + 36, y1 + 212), subtitle, font=F["small"], fill=MUTED)


def dashboard() -> Image.Image:
    img, draw = base("Today", "Today")
    draw.text((72, 252), "Thu, 7 May", font=F["small_bold"], fill=MUTED)
    draw.text((72, 294), "Your adaptive health plan is ready.", font=F["h2"], fill=TEXT)

    gradient_card(img, (72, 370, 1212, 914), ACCENT, SKY)
    draw_score(draw, (260, 642), 120, 82, "Recovery", ACCENT)
    draw.text((454, 462), "Recovery Score", font=F["h2"], fill=TEXT)
    draw_wrapped(draw, "Strong baseline today. Keep training moderate and protect your sleep window tonight.", (454, 524), F["body"], MUTED, 650)
    draw.rounded_rectangle((454, 718, 838, 782), radius=32, fill=(27, 58, 43))
    draw.text((490, 732), "Low burnout risk", font=F["small_bold"], fill=ACCENT)

    metric(draw, img, (72, 960, 624, 1238), "Burnout Risk", "Low", "Score 18/100", ACCENT)
    metric(draw, img, (660, 960, 1212, 1238), "Sleep Debt", "0.8h", "7.2h slept", VIOLET)
    metric(draw, img, (72, 1274, 624, 1552), "Hydration Target", "2.4L", "0.6L logged", MINT)
    metric(draw, img, (660, 1274, 1212, 1552), "Active Energy", "640 kcal", "8,430 steps", AMBER)

    gradient_card(img, (72, 1594, 1212, 2034), SKY, MINT)
    draw.text((116, 1644), "Energy Forecast", font=F["h2"], fill=TEXT)
    bars = [72, 88, 64]
    labels = [("Morning", "Peak"), ("Afternoon", "Steady"), ("Evening", "Ease off")]
    for i, val in enumerate(bars):
        x = 150 + i * 340
        draw.text((x, 1718), labels[i][0], font=F["small_bold"], fill=MUTED)
        draw.rounded_rectangle((x, 1900 - val * 2, x + 110, 1900), radius=24, fill=SKY if i != 2 else ACCENT)
        draw.text((x, 1934), str(val), font=F["h2"], fill=TEXT)
        draw.text((x, 1988), labels[i][1], font=F["small"], fill=MUTED)

    gradient_card(img, (72, 2074, 1212, 2448), ACCENT, AMBER)
    draw.text((116, 2126), "Today's AI Health Plan", font=F["h2"], fill=TEXT)
    plan = ["Walk 6,000 steps before dinner", "Drink 1L before lunch", "Stretch for 8 minutes after work"]
    for i, item in enumerate(plan):
        y = 2208 + i * 68
        draw.ellipse((116, y + 7, 148, y + 39), fill=ACCENT)
        draw.text((170, y), item, font=F["body"], fill=TEXT)
    return img


def missions() -> Image.Image:
    img, draw = base("Daily Missions", "Missions")
    gradient_card(img, (72, 292, 1212, 784), ACCENT, CORAL)
    draw_score(draw, (260, 538), 102, 60, "Done", ACCENT)
    draw.text((432, 400), "3 of 5 complete", font=F["h2"], fill=TEXT)
    draw_wrapped(draw, "Keep the chain alive with small actions that protect recovery and energy.", (432, 462), F["body"], MUTED, 650)
    draw.rounded_rectangle((432, 638, 780, 696), radius=29, fill=(61, 41, 33))
    draw.text((466, 650), "12 day streak", font=F["small_bold"], fill=AMBER)

    draw.text((72, 842), "Today's Focus", font=F["h2"], fill=TEXT)
    items = [
        ("Walk 6,000 steps", "Movement", True, SKY),
        ("Drink 1L before lunch", "Hydration", True, MINT),
        ("Stretch 8 minutes", "Recovery", True, ACCENT),
        ("Avoid caffeine after 3PM", "Sleep", False, VIOLET),
        ("Take a 5-minute reset", "Mindfulness", False, CORAL),
    ]
    y = 914
    for title, cat, done, color in items:
        card(img, (72, y, 1212, y + 220), SURFACE_2, radius=36)
        draw.ellipse((118, y + 70, 194, y + 146), outline=color, width=6, fill=(18, 24, 34))
        if done:
            draw.line((140, y + 108, 158, y + 128, 180, y + 90), fill=color, width=9)
        draw.text((232, y + 58), title, font=F["h3"], fill=TEXT)
        draw.text((232, y + 112), cat, font=F["small_bold"], fill=color)
        draw.text((232, y + 154), "Tap to update completion", font=F["small"], fill=MUTED)
        y += 250
    return img


def coach() -> Image.Image:
    img, draw = base("AI Coach", "Coach")
    gradient_card(img, (72, 292, 1212, 616), VIOLET, ACCENT)
    draw.text((116, 344), "AI Coach Preview", font=F["h2"], fill=TEXT)
    draw_wrapped(draw, "Ask PulsePilot how to adjust your plan when sleep, stress, or energy changes.", (116, 408), F["body"], MUTED, 980)
    draw.rounded_rectangle((116, 530, 488, 590), radius=30, fill=(31, 61, 45))
    draw.text((150, 542), "Adaptive guidance", font=F["small_bold"], fill=ACCENT)

    bubbles = [
        ("I slept badly and feel tired today.", True),
        ("Scale training down today. Keep the walk, hydrate early, and swap intense cardio for 8 minutes of mobility.", False),
        ("Should I still close my rings?", True),
        ("Aim for consistency, not intensity. A lighter day protects recovery and keeps your streak intact.", False),
    ]
    y = 682
    for text, is_user in bubbles:
        max_width = 760 if is_user else 900
        lines = []
        words = text.split()
        current = ""
        for word in words:
            trial = word if not current else f"{current} {word}"
            if text_width(draw, trial, F["body"]) <= max_width:
                current = trial
            else:
                lines.append(current)
                current = word
        if current:
            lines.append(current)
        height = 64 + len(lines) * 43
        if is_user:
            x1, x2 = W - 96 - max_width, W - 72
            fill = (53, 126, 82)
            text_fill = (255, 255, 255)
        else:
            x1, x2 = 72, 72 + max_width + 80
            fill = SURFACE_2
            text_fill = TEXT
        draw.rounded_rectangle((x1, y, x2, y + height), radius=36, fill=fill)
        ty = y + 30
        for line in lines:
            draw.text((x1 + 34, ty), line, font=F["body"], fill=text_fill)
            ty += 43
        y += height + 34

    chip_y = 2142
    chips = ["I'm tired today", "I slept badly", "I missed my workout"]
    x = 72
    for chip in chips:
        tw = text_width(draw, chip, F["small_bold"])
        draw.rounded_rectangle((x, chip_y, x + tw + 50, chip_y + 66), radius=33, fill=SURFACE_2)
        draw.text((x + 25, chip_y + 17), chip, font=F["small_bold"], fill=TEXT)
        x += tw + 74
    draw.rounded_rectangle((72, 2250, 1212, 2360), radius=36, fill=SURFACE_2)
    draw.text((108, 2282), "Tell PulsePilot how you feel", font=F["body"], fill=MUTED)
    draw.ellipse((1120, 2265, 1190, 2335), fill=ACCENT)
    draw.text((1144, 2276), "^", font=F["h2"], fill=(255, 255, 255))
    return img


def recovery() -> Image.Image:
    img, draw = base("Recovery", "Today")
    gradient_card(img, (72, 292, 1212, 1030), ACCENT, SKY)
    draw_score(draw, (642, 564), 150, 82, "Recovery", ACCENT)
    draw.text((392, 792), "Low burnout risk", font=F["h1"], fill=TEXT)
    draw_wrapped(draw, "Your sleep and HRV are stable. Keep effort moderate and avoid stacking late intensity.", (196, 864), F["body"], MUTED, 900)

    metric(draw, img, (72, 1078, 624, 1356), "Sleep", "7.2h", "0.8h debt", VIOLET)
    metric(draw, img, (660, 1078, 1212, 1356), "HRV", "62 ms", "Above baseline", ACCENT)
    metric(draw, img, (72, 1392, 624, 1670), "Steps", "8,430", "Healthy load", SKY)
    metric(draw, img, (660, 1392, 1212, 1670), "Workouts", "38 min", "Moderate", CORAL)

    gradient_card(img, (72, 1712, 1212, 2090), AMBER, ACCENT)
    draw.text((116, 1764), "Why this score", font=F["h2"], fill=TEXT)
    factors = ["Sleep duration supports recovery", "HRV is close to baseline", "Recent activity load is manageable"]
    for i, factor in enumerate(factors):
        y = 1846 + i * 72
        draw.ellipse((116, y + 7, 146, y + 37), fill=ACCENT)
        draw.text((170, y), factor, font=F["body"], fill=TEXT)

    gradient_card(img, (72, 2132, 1212, 2448), SKY, VIOLET)
    draw.text((116, 2182), "7-day recovery trend", font=F["h2"], fill=TEXT)
    vals = [68, 72, 64, 78, 82, 76, 84]
    for i, val in enumerate(vals):
        x = 134 + i * 140
        draw.rounded_rectangle((x, 2388 - val * 2, x + 72, 2406), radius=18, fill=ACCENT if val >= 70 else AMBER)
    return img


def weekly() -> Image.Image:
    img, draw = base("Weekly Report", "Weekly")
    gradient_card(img, (72, 292, 1212, 822), ACCENT, SKY)
    draw_score(draw, (260, 556), 108, 86, "Score", ACCENT)
    draw.text((432, 406), "Weekly Summary", font=F["h2"], fill=TEXT)
    draw_wrapped(draw, "You completed most daily missions and recovery is trending up. Keep workouts consistent and protect bedtime.", (432, 468), F["body"], MUTED, 650)

    metric(draw, img, (72, 872, 624, 1150), "Avg Sleep", "7.1h", "Consistent", VIOLET)
    metric(draw, img, (660, 872, 1212, 1150), "Avg Steps", "8,920", "Strong week", SKY)
    metric(draw, img, (72, 1186, 624, 1464), "Completed", "24", "Missions", ACCENT)
    metric(draw, img, (660, 1186, 1212, 1464), "Recovery", "Improving", "Trend", AMBER)

    gradient_card(img, (72, 1510, 1212, 2048), VIOLET, MINT)
    draw.text((116, 1562), "Recovery Trend", font=F["h2"], fill=TEXT)
    vals = [62, 68, 72, 71, 78, 82, 86]
    labels = ["M", "T", "W", "T", "F", "S", "S"]
    for i, val in enumerate(vals):
        x = 130 + i * 142
        y2 = 1908
        y1 = y2 - val * 4
        draw.rounded_rectangle((x, y1, x + 82, y2), radius=24, fill=ACCENT if val >= 70 else AMBER)
        draw.text((x + 28, y2 + 34), labels[i], font=F["small_bold"], fill=MUTED)

    gradient_card(img, (72, 2090, 1212, 2448), ACCENT, AMBER)
    draw.text((116, 2142), "Next best actions", font=F["h2"], fill=TEXT)
    actions = ["Schedule two lighter recovery blocks", "Keep caffeine before 3PM", "Target 2.4L hydration daily"]
    for i, action in enumerate(actions):
        y = 2224 + i * 64
        draw.ellipse((116, y + 7, 146, y + 37), fill=ACCENT)
        draw.text((170, y), action, font=F["body"], fill=TEXT)
    return img


def save_all() -> list[Path]:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    screenshots: Iterable[tuple[str, Image.Image]] = [
        ("01-dashboard-iphone-6-5.png", dashboard()),
        ("02-daily-missions-iphone-6-5.png", missions()),
        ("03-ai-coach-iphone-6-5.png", coach()),
        ("04-recovery-details-iphone-6-5.png", recovery()),
        ("05-weekly-report-iphone-6-5.png", weekly()),
    ]
    paths: list[Path] = []
    for name, image in screenshots:
        path = OUT_DIR / name
        image.save(path, format="PNG", optimize=True)
        paths.append(path)
    return paths


if __name__ == "__main__":
    for output in save_all():
        print(output)
