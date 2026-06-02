"""
Budjit – Google Play Store Asset Generator
Produces: feature graphic (1024×500) + 8 phone screenshots (1080×1920)
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math, os

OUT = os.path.dirname(__file__)

# ── Brand palette ─────────────────────────────────────────────────────────────
NAVY        = (15,  30,  60)
NAVY_LIGHT  = (30,  58, 111)
EMERALD     = (16, 185, 129)
EMERALD_L   = (52, 211, 153)
AMBER       = (245, 158, 11)
ROSE        = (239, 68,  68)
VIOLET      = (139, 92, 246)
SKY         = (14, 165, 233)
CREAM       = (250, 248, 244)
WHITE       = (255, 255, 255)
LIGHT_BG    = (244, 246, 250)
DARK_CARD   = (26,  37,  64)
DARK_BG     = (6,   15,  30)
DARK_BORDER = (42,  58,  92)
GREY        = (160, 160, 170)
GREY_L      = (220, 224, 232)
BUDJIT_BG   = (DARK_BG[0], DARK_BG[1], DARK_BG[2], 255)

# ── Font helpers ──────────────────────────────────────────────────────────────
ARIAL        = "/System/Library/Fonts/Supplemental/Arial.ttf"
ARIAL_BOLD   = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
ARIAL_NARROW = "/System/Library/Fonts/Supplemental/Arial Narrow.ttf"
HELVETICA    = "/System/Library/Fonts/Helvetica.ttc"

def font(size, bold=False):
    try:
        path = ARIAL_BOLD if bold else ARIAL
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

def text_w(draw, txt, fnt):
    bb = draw.textbbox((0, 0), txt, font=fnt)
    return bb[2] - bb[0]

def centered(draw, txt, fnt, y, color, W):
    w = text_w(draw, txt, fnt)
    draw.text(((W - w) // 2, y), txt, fill=color, font=fnt)

# ── Gradient helpers ──────────────────────────────────────────────────────────
def v_gradient(img, top, bottom):
    """Fill image top→bottom colour gradient."""
    W, H = img.size
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b))
    return img

def h_gradient(img, left, right, x0=0, x1=None):
    W, H = img.size
    if x1 is None:
        x1 = W
    draw = ImageDraw.Draw(img)
    span = x1 - x0
    for x in range(x0, x1):
        t = (x - x0) / max(span, 1)
        r = int(left[0] + (right[0] - left[0]) * t)
        g = int(left[1] + (right[1] - left[1]) * t)
        b = int(left[2] + (right[2] - left[2]) * t)
        draw.line([(x, 0), (x, H)], fill=(r, g, b))
    return img

# ── Rounded rectangle ─────────────────────────────────────────────────────────
def rounded_rect(draw, box, radius, fill, outline=None, outline_width=2):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill,
                           outline=outline, width=outline_width)

# ── Mini progress bar ─────────────────────────────────────────────────────────
def progress_bar(draw, x, y, w, h, ratio, bg, fg, radius=4):
    rounded_rect(draw, [x, y, x+w, y+h], radius, bg)
    fill_w = max(int(w * ratio), radius * 2)
    rounded_rect(draw, [x, y, x+fill_w, y+h], radius, fg)

# ══════════════════════════════════════════════════════════════════════════════
#  FEATURE GRAPHIC  1024 × 500
# ══════════════════════════════════════════════════════════════════════════════
def make_feature_graphic():
    W, H = 1024, 500
    img = Image.new("RGB", (W, H))
    # Background gradient: dark navy left → lighter navy right
    h_gradient(img, NAVY, NAVY_LIGHT, 0, W // 2)
    h_gradient(img, NAVY_LIGHT, (20, 45, 90), W // 2, W)
    draw = ImageDraw.Draw(img)

    # ── Decorative circles ──
    for cx, cy, r, alpha in [(760, 80, 220, 18), (820, 400, 150, 12), (200, 420, 100, 10)]:
        circle = Image.new("RGBA", (r*2, r*2), (0, 0, 0, 0))
        cd = ImageDraw.Draw(circle)
        cd.ellipse([0, 0, r*2-1, r*2-1], fill=(255, 255, 255, alpha))
        img.paste(circle, (cx - r, cy - r), circle)

    # ── Emerald accent line ──
    draw.rectangle([60, 240, 60 + 4, 310], fill=EMERALD)

    # ── App icon (rounded square) ──
    icon_x, icon_y, icon_sz = 68, 90, 90
    rounded_rect(draw, [icon_x, icon_y, icon_x+icon_sz, icon_y+icon_sz],
                 20, EMERALD)
    # Chart bars inside icon
    for i, (bx, bh) in enumerate([(78, 28), (92, 42), (106, 20), (120, 52)]):
        bar_x = icon_x + 10 + i * 17
        draw.rectangle([bar_x, icon_y + icon_sz - 14 - bh,
                        bar_x + 10, icon_y + icon_sz - 14],
                       fill=WHITE)

    # ── App name ──
    draw.text((68, 198), "budjit", fill=WHITE, font=font(52, bold=True))
    draw.text((68, 258), "Personal Finance & Budget Planner", fill=EMERALD, font=font(18))

    # ── Tagline ──
    draw.text((68, 310), "Finally understand your money.", fill=WHITE,
              font=font(26, bold=True))
    draw.text((68, 348), "Track every shilling. Build every goal.", fill=(180, 200, 230),
              font=font(17))

    # ── Feature pills ──
    pills = [("💰 Expense Tracking", EMERALD), ("📊 Smart Analytics", SKY),
             ("🎯 Savings Goals", VIOLET), ("🤖 AI Coach", AMBER)]
    px, py = 68, 398
    for label, color in pills:
        pw = text_w(draw, label, font(14)) + 24
        rounded_rect(draw, [px, py, px+pw, py+28], 14,
                     (*color, 30) if False else color)
        draw.text((px + 12, py + 6), label, fill=WHITE, font=font(14, bold=True))
        px += pw + 12
        if px > 430:
            px, py = 68, py + 38

    # ── Right: simulated phone screens ──
    # Phone 1 (dashboard preview)
    _draw_mini_phone(img, draw, 530, 50, 200, 360)
    # Phone 2 (tabbed mode)
    _draw_mini_phone_tabbed(img, draw, 755, 110, 200, 340)

    img.save(os.path.join(OUT, "feature_graphic.png"))
    print("✓ feature_graphic.png")


def _draw_mini_phone(img, draw, x, y, w, h):
    """Draw a small phone mockup showing the dashboard."""
    # Phone frame
    rounded_rect(draw, [x-3, y-3, x+w+3, y+h+3], 18, (40, 55, 90))
    rounded_rect(draw, [x, y, x+w, y+h], 16, DARK_CARD)

    # Status bar
    draw.rectangle([x, y, x+w, y+18], fill=(20, 32, 56))

    # App bar
    draw.rectangle([x, y+18, x+w, y+44], fill=(20, 32, 56))
    draw.text((x+10, y+24), "Budjit", fill=WHITE, font=font(13, bold=True))

    # Balance card
    rounded_rect(draw, [x+8, y+50, x+w-8, y+130], 12, NAVY)
    draw.text((x+14, y+58), "Monthly Balance", fill=(180, 200, 230), font=font(9))
    draw.text((x+14, y+72), "UGX 2,450,000", fill=WHITE, font=font(14, bold=True))
    draw.text((x+14, y+92), "22.5% savings", fill=EMERALD, font=font(9))
    progress_bar(draw, x+14, y+108, w-28, 6, 0.55, (255,255,255,30), EMERALD)

    # Income / expense pills
    rounded_rect(draw, [x+8, y+136, x+w//2-4, y+158], 8, (26, 40, 70))
    draw.text((x+12, y+141), "↓ Income", fill=EMERALD, font=font(9, bold=True))
    draw.text((x+12, y+153), "UGX 3.2M", fill=WHITE, font=font(8))
    rounded_rect(draw, [x+w//2+4, y+136, x+w-8, y+158], 8, (26, 40, 70))
    draw.text((x+w//2+8, y+141), "↑ Expenses", fill=ROSE, font=font(9, bold=True))
    draw.text((x+w//2+8, y+153), "UGX 0.8M", fill=WHITE, font=font(8))

    # Category bars
    cats = [("🛒 Groceries", EMERALD, 0.4), ("🚗 Transport", SKY, 0.6),
            ("🏠 Housing", AMBER, 0.8)]
    cy = y + 168
    for label, color, ratio in cats:
        draw.text((x+8, cy), label, fill=(200, 210, 230), font=font(8))
        progress_bar(draw, x+8, cy+12, w-16, 5, ratio,
                     (*color[:3],40) if False else DARK_BG, color)
        cy += 24

    # Bottom nav
    draw.rectangle([x, y+h-28, x+w, y+h], fill=(20, 32, 56))
    nav_icons = ["⌂", "₿", "◎", "↑", "☰"]
    for i, ic in enumerate(nav_icons):
        nx = x + 8 + i * (w//5)
        col = EMERALD if i == 0 else GREY
        draw.text((nx+2, y+h-22), ic, fill=col, font=font(10))


def _draw_mini_phone_tabbed(img, draw, x, y, w, h):
    """Draw a small phone showing tabbed mode."""
    rounded_rect(draw, [x-3, y-3, x+w+3, y+h+3], 18, (40, 55, 90))
    rounded_rect(draw, [x, y, x+w, y+h], 16, (250, 245, 238))

    # App bar
    draw.rectangle([x, y, x+w, y+44], fill=WHITE)
    draw.text((x+10, y+14), "Budget Planner", fill=(139, 48, 48), font=font(12, bold=True))

    # Tab bar
    draw.rectangle([x, y+44, x+w, y+72], fill=WHITE)
    for i, (lbl, active) in enumerate([("Actual", False), ("Budget", True), ("Reports", False)]):
        tx = x + i * (w//3) + 4
        col = (139, 48, 48) if active else (120, 100, 90)
        draw.text((tx, y+52), lbl, fill=col, font=font(10, bold=active))
        if active:
            draw.rectangle([tx-2, y+70, tx + w//3 - 8, y+72], fill=(139, 48, 48))

    # Form card
    rounded_rect(draw, [x+8, y+78, x+w-8, y+h-50], 10, WHITE)
    draw.text((x+14, y+86), "Budgeted income", fill=(15, 30, 60), font=font(11, bold=True))
    # Fields
    for fy, lbl in [(y+104, "Label (optional)"), (y+126, "Amount")]:
        rounded_rect(draw, [x+12, fy, x+w-12, fy+18], 6, (248, 245, 240))
        draw.text((x+16, fy+4), lbl, fill=(150, 130, 110), font=font(8))
    # Button
    rounded_rect(draw, [x+12, y+152, x+w-12, y+172], 8, (139, 48, 48))
    draw.text((x+w//2 - 22, y+157), "+ Add income", fill=WHITE, font=font(9, bold=True))

    # Income line
    rounded_rect(draw, [x+8, y+180, x+w-8, y+h-10], 8, WHITE)
    draw.text((x+14, y+186), "Income lines (1)", fill=(15, 30, 60), font=font(9, bold=True))
    draw.text((x+14, y+202), "💼 Salary", fill=(80, 60, 50), font=font(9))
    draw.text((x+w-60, y+202), "13.8M", fill=(15, 30, 60), font=font(9, bold=True))


# ══════════════════════════════════════════════════════════════════════════════
#  PHONE SCREENSHOT BASE  1080 × 1920
# ══════════════════════════════════════════════════════════════════════════════
PW, PH = 1080, 1920

def new_screen(bg=LIGHT_BG):
    img = Image.new("RGB", (PW, PH), bg)
    return img

def status_bar(draw, dark=True):
    col = WHITE if dark else NAVY
    draw.text((60, 44), "9:41", fill=col, font=font(38, bold=True))
    # Signal dots
    for i in range(4):
        h = 16 + i * 8
        draw.rectangle([PW-200+i*22, 68-h, PW-200+i*22+14, 68], fill=col)
    draw.text((PW-140, 40), "WiFi", fill=col, font=font(30))
    draw.text((PW-80, 40), "🔋", fill=col, font=font(30))

def app_bar(draw, title, dark=True, bg=None, primary=None):
    if bg:
        draw.rectangle([0, 100, PW, 200], fill=bg)
    col = primary or (WHITE if dark else NAVY)
    draw.text((60, 130), title, fill=col, font=font(52, bold=True))

def pill_badge(draw, x, y, text, bg, text_col=WHITE):
    w = text_w(draw, text, font(28, bold=True)) + 40
    rounded_rect(draw, [x, y, x+w, y+52], 26, bg)
    draw.text((x+20, y+12), text, fill=text_col, font=font(28, bold=True))
    return x + w + 16

def bottom_label(draw, text, sub=None):
    """Marketing copy at the bottom of each screenshot."""
    draw.rectangle([0, PH-220, PW, PH], fill=NAVY)
    draw.line([(0, PH-220), (PW, PH-220)], fill=EMERALD, width=4)
    y = PH - 190
    centered(draw, text, font(52, bold=True), y, WHITE, PW)
    if sub:
        centered(draw, sub, font(36), y+70, (180, 200, 230), PW)
    # budjit label bottom right
    draw.text((PW-200, PH-50), "budjit", fill=EMERALD, font=font(36, bold=True))


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 1 – Welcome / Onboarding
# ══════════════════════════════════════════════════════════════════════════════
def make_ss1():
    img = new_screen()
    v_gradient(img, NAVY, (25, 50, 100))
    draw = ImageDraw.Draw(img)
    status_bar(draw, dark=True)

    # App icon
    rounded_rect(draw, [PW//2-80, 260, PW//2+80, 420], 40, EMERALD)
    for i, (bx, bh) in enumerate([(PW//2-52, 48), (PW//2-22, 70), (PW//2+8, 36), (PW//2+38, 88)]):
        draw.rectangle([bx, 380-bh, bx+26, 380], fill=WHITE)

    centered(draw, "budjit", font(110, bold=True), 460, WHITE, PW)
    centered(draw, "Personal Finance & Budget Planner", font(40), 590, EMERALD, PW)

    # Feature highlights
    features = [
        ("💰", "Track every expense instantly"),
        ("📊", "Beautiful spending insights"),
        ("🎯", "Build real savings goals"),
        ("🤖", "AI-powered money coach"),
        ("🔒", "Private & works offline"),
    ]
    y = 720
    for emoji, text in features:
        draw.text((180, y), emoji, fill=WHITE, font=font(52))
        draw.text((270, y+4), text, fill=(200, 215, 240), font=font(44))
        y += 100

    # CTA
    rounded_rect(draw, [120, 1500, PW-120, 1620], 32, EMERALD)
    centered(draw, "Get Started Free →", font(52, bold=True), 1530, WHITE, PW)
    draw.text((240, 1650), "No credit card required · Works offline",
              fill=(160, 190, 220), font=font(36))

    bottom_label(draw, "Finally understand your money",
                 "Africa's #1 budget planner")
    img.save(os.path.join(OUT, "screenshot_1_welcome.png"))
    print("✓ screenshot_1_welcome.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 2 – Dashboard
# ══════════════════════════════════════════════════════════════════════════════
def make_ss2():
    img = new_screen(LIGHT_BG)
    draw = ImageDraw.Draw(img)

    # Status bar region
    draw.rectangle([0, 0, PW, 100], fill=WHITE)
    status_bar(draw, dark=False)

    # App bar
    draw.rectangle([0, 100, PW, 220], fill=WHITE)
    draw.text((60, 130), "Good morning, Patrick 👋", fill=GREY, font=font(36))
    draw.text((60, 170), "June 2026", fill=NAVY, font=font(56, bold=True))

    # Balance card
    card = Image.new("RGB", (PW-120, 420))
    v_gradient(card, NAVY, NAVY_LIGHT)
    img.paste(card, (60, 240))
    draw.rounded_rectangle([60, 240, PW-60, 660], radius=36, outline=None, fill=None)
    # Redraw gradient with rounding (approximate)
    rounded_rect(draw, [60, 240, PW-60, 660], 36, NAVY)

    draw.text((120, 280), "Monthly Balance", fill=(180, 200, 235), font=font(36))
    draw.text((120, 330), "UGX 2,450,000", fill=WHITE, font=font(80, bold=True))
    draw.text((120, 430), "✓  22.5% savings rate this month", fill=EMERALD, font=font(36))

    # Income / Expense mini cards
    rounded_rect(draw, [120, 490, 520, 620], 20, (255,255,255,25))
    draw.text((140, 510), "Income", fill=(200, 220, 240), font=font(30))
    draw.text((140, 550), "UGX 3,200,000", fill=WHITE, font=font(38, bold=True))
    rounded_rect(draw, [540, 490, 940, 620], 20, (255,255,255,25))
    draw.text((560, 510), "Expenses", fill=(200, 220, 240), font=font(30))
    draw.text((560, 550), "UGX 750,000", fill=ROSE, font=font(38, bold=True))

    # Progress bar
    progress_bar(draw, 120, 640, PW-240, 10, 0.23,
                 (255,255,255,40), EMERALD, radius=5)

    # Safe to spend card
    rounded_rect(draw, [60, 680, PW-60, 800], 24, WHITE)
    draw.text((120, 706), "🗓", fill=EMERALD, font=font(52))
    draw.text((220, 706), "Safe to spend today", fill=GREY, font=font(34))
    draw.text((220, 748), "UGX 82,000", fill=NAVY, font=font(48, bold=True))

    # This Month stats
    draw.text((60, 830), "This Month", fill=NAVY, font=font(48, bold=True))
    for i, (lbl, val, col) in enumerate([
        ("Income",   "UGX 3.2M", EMERALD),
        ("Expenses", "UGX 750K", ROSE),
        ("Entries",  "24",       VIOLET),
    ]):
        sx = 60 + i * 330
        rounded_rect(draw, [sx, 890, sx+310, 1030], 24, WHITE)
        rounded_rect(draw, [sx+20, 910, sx+60, 950], 12,
                     col[:3] + ((40,) if False else ()))
        draw.rectangle([sx+20, 910, sx+60, 950], fill=(*col[:3], 255))
        # Use solid color for icon bg
        rounded_rect(draw, [sx+20, 910, sx+60, 950], 12, (*col, 255) if len(col)==3 else col)
        draw.text((sx+20, 970), val, fill=NAVY, font=font(38, bold=True))
        draw.text((sx+20, 1010), lbl, fill=GREY, font=font(30))

    # Recent transactions header
    draw.text((60, 1070), "Recent Transactions", fill=NAVY, font=font(48, bold=True))

    txs = [
        ("🛒", "Groceries — Nakumatt", "Food & Dining",   "−UGX 85,000",  ROSE),
        ("🚗", "Bodaboda fare",         "Transport",        "−UGX 12,000",  ROSE),
        ("💼", "Monthly Salary",         "Income",           "+UGX 3,200,000", EMERALD),
        ("💡", "UMEME Electricity",      "Utility Bills",   "−UGX 120,000", ROSE),
    ]
    ty = 1140
    for emoji, title, cat, amt, col in txs:
        rounded_rect(draw, [60, ty, PW-60, ty+110], 20, WHITE)
        draw.text((90, ty+22), emoji, fill=WHITE, font=font(52))
        draw.text((180, ty+20), title, fill=NAVY, font=font(38, bold=True))
        draw.text((180, ty+64), cat,   fill=GREY, font=font(32))
        tw = text_w(draw, amt, font(38, bold=True))
        draw.text((PW-80-tw, ty+44), amt, fill=col, font=font(38, bold=True))
        ty += 128

    bottom_label(draw, "Your money at a glance", "Dashboard that updates in real-time")
    img.save(os.path.join(OUT, "screenshot_2_dashboard.png"))
    print("✓ screenshot_2_dashboard.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 3 – Add Transaction
# ══════════════════════════════════════════════════════════════════════════════
def make_ss3():
    img = new_screen(LIGHT_BG)
    draw = ImageDraw.Draw(img)

    # Dimmed background (simulate modal)
    draw.rectangle([0, 0, PW, PH], fill=(0, 0, 0))
    bg = Image.new("RGB", (PW, PH), LIGHT_BG)
    bg_arr = bg.load()
    overlay = Image.new("RGBA", (PW, PH), (0, 0, 0, 140))
    img.paste(bg)
    img.paste(overlay, mask=overlay)

    # Sheet
    sheet_y = 280
    rounded_rect(draw, [0, sheet_y, PW, PH], 56, WHITE)

    # Drag handle
    rounded_rect(draw, [PW//2-60, sheet_y+24, PW//2+60, sheet_y+36], 6, GREY_L)

    # Expense / Income toggle
    draw.rectangle([60, sheet_y+70, PW-60, sheet_y+160], fill=LIGHT_BG,
                   outline=None)
    draw.rounded_rectangle([60, sheet_y+70, PW-60, sheet_y+160], radius=20,
                            fill=LIGHT_BG)
    rounded_rect(draw, [64, sheet_y+74, 536, sheet_y+156], 18, ROSE)
    centered(draw, "Expense", font(48, bold=True), sheet_y+92, WHITE, 540//2 + 30)
    draw.text((620, sheet_y+92), "Income", fill=GREY, font=font(48))

    # Amount
    rounded_rect(draw, [60, sheet_y+180, PW-60, sheet_y+340], 24, LIGHT_BG)
    centered(draw, "UGX", font(36), sheet_y+210, GREY, PW)
    centered(draw, "0", font(140, bold=True), sheet_y+240, ROSE, PW)

    # Category chips
    draw.text((60, sheet_y+370), "Category", fill=GREY, font=font(34))
    cats = [("🍽️", "Food", True), ("🛒", "Groceries", False), ("🚗", "Transport", False),
            ("🏠", "Housing", False), ("💡", "Utilities", False)]
    cx, cy = 60, sheet_y + 420
    for emoji, lbl, sel in cats:
        cw = text_w(draw, f"{emoji} {lbl}", font(32)) + 40
        bg_c = ROSE if sel else LIGHT_BG
        rounded_rect(draw, [cx, cy, cx+cw, cy+72], 16, bg_c)
        draw.text((cx+16, cy+16), f"{emoji} {lbl}",
                  fill=WHITE if sel else GREY, font=font(32))
        cx += cw + 16
        if cx > PW - 200:
            cx, cy = 60, cy + 92

    # Label field
    rounded_rect(draw, [60, sheet_y+640, PW-60, sheet_y+740], 20, LIGHT_BG)
    draw.text((110, sheet_y+672), "Description (optional)", fill=GREY, font=font(36))
    draw.text((80, sheet_y+680), "✏", fill=GREY, font=font(40))

    # Date field
    rounded_rect(draw, [60, sheet_y+760, PW-60, sheet_y+860], 20, LIGHT_BG)
    draw.text((80, sheet_y+792), "📅", fill=GREY, font=font(40))
    draw.text((150, sheet_y+800), "2 Jun 2026", fill=NAVY, font=font(38, bold=True))

    # Submit button
    rounded_rect(draw, [60, sheet_y+900, PW-60, sheet_y+1020], 28, ROSE)
    centered(draw, "Add Expense", font(52, bold=True), sheet_y+930, WHITE, PW)

    bottom_label(draw, "Add expenses in seconds",
                 "Smart categories · Offline-first")
    img.save(os.path.join(OUT, "screenshot_3_add_expense.png"))
    print("✓ screenshot_3_add_expense.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 4 – Budgets
# ══════════════════════════════════════════════════════════════════════════════
def make_ss4():
    img = new_screen(LIGHT_BG)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, PW, 220], fill=WHITE)
    status_bar(draw, dark=False)
    draw.text((60, 130), "Budgets", fill=NAVY, font=font(72, bold=True))

    # Overall budget card
    rounded_rect(draw, [60, 240, PW-60, 540], 36, NAVY)
    draw.text((120, 278), "Monthly Budget", fill=(180, 200, 235), font=font(36))
    draw.text((120, 326), "UGX 480,000", fill=WHITE, font=font(70, bold=True))
    draw.text((120, 408), "of UGX 2,000,000", fill=(160, 185, 220), font=font(36))
    rounded_rect(draw, [PW-260, 300, PW-100, 370], 20, (16, 185, 129, 40))
    draw.text((PW-245, 318), "UGX 1.52M", fill=EMERALD, font=font(36, bold=True))
    draw.text((PW-245, 358), "remaining", fill=(160, 200, 180), font=font(28))
    progress_bar(draw, 120, 458, PW-240, 14, 0.24, (255,255,255,40), EMERALD, 7)
    draw.text((120, 486), "24% of budget used this month", fill=(160, 185, 220), font=font(30))

    # Category budgets
    budgets = [
        ("🛒", "Groceries",   180_000, 400_000, EMERALD),
        ("🚗", "Transport",    95_000, 150_000, SKY),
        ("🏠", "Housing",    500_000, 600_000, AMBER),
        ("💡", "Utility Bills", 80_000, 100_000, VIOLET),
        ("🍽️", "Food & Dining", 210_000, 200_000, ROSE),
    ]
    by = 580
    draw.text((60, by), "Category Budgets", fill=NAVY, font=font(48, bold=True))
    by += 70

    for emoji, cat, spent, limit, col in budgets:
        rounded_rect(draw, [60, by, PW-60, by+180], 24, WHITE)
        draw.text((100, by+24), emoji, fill=WHITE, font=font(60))
        draw.text((200, by+22), cat, fill=NAVY, font=font(42, bold=True))
        draw.text((200, by+72), f"Budget: UGX {limit//1000}K", fill=GREY, font=font(32))

        ratio = min(spent / limit, 1.0)
        over = spent > limit
        bar_col = ROSE if over else col
        progress_bar(draw, 100, by+116, PW-220, 12, ratio,
                     (*bar_col, 30), bar_col, 6)

        spent_str = f"UGX {spent//1000:,}K"
        lim_str   = f"/ {limit//1000:,}K"
        tw = text_w(draw, spent_str, font(40, bold=True))
        draw.text((PW-80-tw-text_w(draw, lim_str, font(32))-10, by+138),
                  spent_str, fill=bar_col, font=font(40, bold=True))
        draw.text((PW-80-text_w(draw, lim_str, font(32)), by+146),
                  lim_str, fill=GREY, font=font(32))
        if over:
            ow = text_w(draw, "Over budget !", font(28, bold=True)) + 28
            rounded_rect(draw, [PW-80-ow, by+24, PW-60, by+66], 12, (*ROSE, 40))
            draw.rectangle([PW-80-ow, by+24, PW-60, by+66], fill=(255, 80, 80, 40))
            rounded_rect(draw, [PW-80-ow, by+24, PW-60, by+66], 12, ROSE)
            draw.text((PW-80-ow+8, by+34), "Over budget !", fill=WHITE, font=font(28, bold=True))
        by += 200

    bottom_label(draw, "Stay on budget every month",
                 "Visual progress per category")
    img.save(os.path.join(OUT, "screenshot_4_budgets.png"))
    print("✓ screenshot_4_budgets.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 5 – Savings Goals
# ══════════════════════════════════════════════════════════════════════════════
def make_ss5():
    img = new_screen(LIGHT_BG)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, PW, 220], fill=WHITE)
    status_bar(draw, dark=False)
    draw.text((60, 130), "Savings Goals", fill=NAVY, font=font(72, bold=True))

    # Summary card
    rounded_rect(draw, [60, 240, PW-60, 460], 36, EMERALD)
    draw.text((120, 276), "Total Saved", fill=(200, 240, 220), font=font(36))
    draw.text((120, 322), "UGX 4,850,000", fill=WHITE, font=font(72, bold=True))
    draw.text((120, 406), "of UGX 12,500,000 target", fill=(210, 245, 230), font=font(36))
    progress_bar(draw, 120, 438, PW-240, 10, 0.388, (255,255,255,40), WHITE, 5)

    # Active goals
    goals = [
        ("✈️", "Dream Vacation",   2_500_000,  5_000_000, "#0EA5E9", "By Dec 2026"),
        ("🚗", "New Car Fund",      1_200_000,  4_500_000, "#8B5CF6", "By Jun 2027"),
        ("🏠", "Home Deposit",      800_000,    8_000_000, "#F59E0B", None),
        ("🎓", "School Fees",        350_000,    800_000,  "#10B981", "By Jan 2027"),
    ]
    gy = 500
    draw.text((60, gy), "Active Goals", fill=NAVY, font=font(48, bold=True))
    gy += 70

    for emoji, name, saved, target, hex_col, deadline in goals:
        hx = int(hex_col[1:3], 16)
        hy = int(hex_col[3:5], 16)
        hz = int(hex_col[5:7], 16)
        col = (hx, hy, hz)
        ratio = saved / target

        rounded_rect(draw, [60, gy, PW-60, gy+230], 24, WHITE)
        # Emoji circle
        rounded_rect(draw, [90, gy+28, 190, gy+128], 20, (*col, 40))
        draw.rectangle([90, gy+28, 190, gy+128], fill=(*col[:3], 255) if False else col)
        rounded_rect(draw, [90, gy+28, 190, gy+128], 20, col)
        draw.text((112, gy+42), emoji, fill=WHITE, font=font(60))

        draw.text((210, gy+28), name, fill=NAVY, font=font(44, bold=True))
        if deadline:
            draw.text((210, gy+82), f"📅 {deadline}", fill=GREY, font=font(32))

        pct = f"{ratio*100:.0f}%"
        pw2 = text_w(draw, pct, font(52, bold=True))
        draw.text((PW-80-pw2, gy+50), pct, fill=col, font=font(52, bold=True))

        progress_bar(draw, 90, gy+136, PW-180, 16, ratio, (*col, 40), col, 8)

        saved_s = f"UGX {saved//1000:,}K saved"
        tgt_s   = f"UGX {target//1000:,}K target"
        draw.text((90, gy+168), saved_s, fill=col, font=font(32, bold=True))
        tw2 = text_w(draw, tgt_s, font(30))
        draw.text((PW-80-tw2, gy+172), tgt_s, fill=GREY, font=font(30))

        gy += 252

    bottom_label(draw, "Build savings that matter",
                 "Visual goals · Milestone tracking")
    img.save(os.path.join(OUT, "screenshot_5_goals.png"))
    print("✓ screenshot_5_goals.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 6 – Analytics
# ══════════════════════════════════════════════════════════════════════════════
def make_ss6():
    img = new_screen(LIGHT_BG)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, PW, 220], fill=WHITE)
    status_bar(draw, dark=False)
    draw.text((60, 130), "Analytics", fill=NAVY, font=font(72, bold=True))

    # Income vs Expense card
    rounded_rect(draw, [60, 240, PW-60, 620], 30, WHITE)
    draw.text((100, 270), "Income vs Expenses", fill=NAVY, font=font(44, bold=True))

    # Bar chart
    bars = [
        ("Income",   3_200_000, EMERALD),
        ("Expenses",   750_000, ROSE),
    ]
    max_v = max(b[1] for b in bars)
    bx = 160
    for label, value, col in bars:
        bh = int(240 * value / max_v)
        draw.rectangle([bx, 540-bh, bx+240, 540], fill=col)
        draw.rounded_rectangle([bx, 540-bh, bx+240, 540], radius=12, fill=col)
        centered(draw, label, font(32), 556, GREY, bx*2+120)
        draw.text((bx+20, 540-bh-50), f"UGX {value//1_000_000:.1f}M",
                  fill=NAVY, font=font(32, bold=True))
        bx += 360

    draw.text((820, 300), "Savings", fill=GREY, font=font(32))
    draw.text((820, 340), "22.5%", fill=EMERALD, font=font(60, bold=True))

    # Daily trend
    rounded_rect(draw, [60, 640, PW-60, 960], 30, WHITE)
    draw.text((100, 668), "Daily Spending", fill=NAVY, font=font(44, bold=True))

    import random
    random.seed(42)
    points = []
    for i in range(28):
        v = random.randint(10_000, 180_000) if i % 3 != 0 else 0
        points.append(v)
    max_p = max(points) or 1
    chart_x0, chart_x1 = 100, PW-100
    chart_y0, chart_y1 = 720, 930
    cw = chart_x1 - chart_x0
    pts = []
    for i, v in enumerate(points):
        x = chart_x0 + int(cw * i / (len(points)-1))
        y = chart_y1 - int((chart_y1-chart_y0) * v / max_p)
        pts.append((x, y))
    # Fill area
    fill_pts = [(chart_x0, chart_y1)] + pts + [(chart_x1, chart_y1)]
    draw.polygon(fill_pts, fill=(*ROSE, 40))
    draw.polygon(fill_pts, fill=(239, 68, 68, 40))
    # Line
    for i in range(len(pts)-1):
        draw.line([pts[i], pts[i+1]], fill=ROSE, width=5)

    # Category breakdown
    rounded_rect(draw, [60, 980, PW-60, 1500], 30, WHITE)
    draw.text((100, 1008), "By Category", fill=NAVY, font=font(44, bold=True))

    cat_data = [
        ("🛒", "Groceries",    180_000, EMERALD, 0.45),
        ("🚗", "Transport",     95_000, SKY,     0.24),
        ("🏠", "Housing",      500_000, AMBER,   0.80),
        ("💡", "Utilities",     80_000, VIOLET,  0.72),
        ("🍽️", "Food & Dining", 210_000, ROSE,   1.05),
    ]
    cy2 = 1070
    for emoji, cat, val, col, ratio in cat_data:
        draw.text((90, cy2), emoji, fill=WHITE, font=font(46))
        draw.text((180, cy2+2), cat, fill=NAVY, font=font(38, bold=True))
        vs = f"UGX {val//1000:,}K"
        vw = text_w(draw, vs, font(38, bold=True))
        draw.text((PW-90-vw, cy2+2), vs, fill=ROSE if ratio > 1 else col,
                  font=font(38, bold=True))
        progress_bar(draw, 90, cy2+52, PW-180, 12, min(ratio, 1.0),
                     (*col, 30), ROSE if ratio > 1 else col, 6)
        if ratio > 1:
            draw.text((90, cy2+76), "⚠ Over budget",
                      fill=ROSE, font=font(28, bold=True))
        cy2 += 86 + (30 if ratio > 1 else 0)

    bottom_label(draw, "Know exactly where you spend",
                 "Beautiful charts · Smart insights")
    img.save(os.path.join(OUT, "screenshot_6_analytics.png"))
    print("✓ screenshot_6_analytics.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 7 – Tabbed Mode (Budget Planner)
# ══════════════════════════════════════════════════════════════════════════════
BURGUNDY  = (139, 48, 48)
CREAM     = (245, 237, 224)
CREAM_D   = (240, 232, 218)

def make_ss7():
    img = new_screen(CREAM)
    draw = ImageDraw.Draw(img)

    # Status bar
    draw.rectangle([0, 0, PW, 100], fill=WHITE)
    status_bar(draw, dark=False)

    # App bar
    draw.rectangle([0, 100, PW, 230], fill=WHITE)
    draw.text((60, 140), "Budget Planner", fill=BURGUNDY, font=font(64, bold=True))

    # Main tabs
    draw.rectangle([0, 230, PW, 360], fill=WHITE)
    for i, (lbl, active) in enumerate([("Actual", False), ("Budget", True), ("Reports", False)]):
        tx = 60 + i * 320
        col = BURGUNDY if active else (160, 130, 110)
        draw.text((tx+60, 270), lbl, fill=col, font=font(44, bold=active))
        if active:
            draw.rectangle([tx+20, 348, tx+280, 360], fill=BURGUNDY)

    # Sub-tabs
    draw.rectangle([0, 360, PW, 460], fill=WHITE)
    draw.line([(0, 460), (PW, 460)], fill=(220, 210, 195), width=2)
    for i, (lbl, active) in enumerate([("Income", True), ("Planned expense", False)]):
        tx = 60 + i * 440
        col = BURGUNDY if active else (160, 130, 110)
        draw.text((tx+30, 395), lbl, fill=col, font=font(40, bold=active))
        if active:
            draw.rectangle([tx, 448, tx+350, 460], fill=BURGUNDY)

    # Form card
    rounded_rect(draw, [40, 480, PW-40, 1100], 32, WHITE)
    draw.text((90, 520), "Budgeted income", fill=(15, 30, 60), font=font(60, bold=True))

    # Fields
    for fy, lbl, icon in [(600, "Label (optional)", "🏷"), (700, "Amount", "💵"),]:
        rounded_rect(draw, [80, fy, PW-80, fy+88], 20, CREAM)
        draw.text((100, fy+20), icon, fill=(160, 130, 110), font=font(46))
        draw.text((168, fy+24), lbl, fill=(160, 130, 110), font=font(40))

    # Category dropdown
    rounded_rect(draw, [80, 800, PW-80, 960], 20, CREAM)
    draw.text((100, 808), "Income category", fill=(140, 110, 90), font=font(32))
    draw.text((100, 848), "💼  Salary", fill=(15, 30, 60), font=font(52, bold=True))
    draw.text((PW-130, 868), "▾", fill=(140, 110, 90), font=font(48))

    # Button
    rounded_rect(draw, [80, 980, PW-80, 1080], 24, BURGUNDY)
    centered(draw, "+ Add income", font(52, bold=True), 1006, WHITE, PW)

    # Income lines card
    rounded_rect(draw, [40, 1120, PW-40, 1520], 32, WHITE)
    draw.text((90, 1156), "Income lines (2)", fill=(15, 30, 60), font=font(52, bold=True))
    draw.line([(80, 1220), (PW-80, 1220)], fill=CREAM_D, width=2)

    lines = [
        ("💼", "Monthly Salary", "Salary",  "UGX 13,782,126"),
        ("⚡", "Freelance gig",  "Freelance","UGX 400,000"),
    ]
    ly = 1240
    for emoji, label, sub, amount in lines:
        rounded_rect(draw, [80, ly, 180, ly+90], 16, (*BURGUNDY, 20))
        draw.rectangle([80, ly, 180, ly+90], fill=(139, 48, 48, 20))
        rounded_rect(draw, [80, ly, 180, ly+90], 16, (200, 150, 150))
        draw.text((105, ly+16), emoji, fill=WHITE, font=font(52))
        draw.text((200, ly+6),  label,  fill=(15, 30, 60), font=font(42, bold=True))
        draw.text((200, ly+56), sub,    fill=(160, 130, 110), font=font(34))
        tw3 = text_w(draw, amount, font(42, bold=True))
        draw.text((PW-100-tw3, ly+26), amount, fill=(15, 30, 60), font=font(42, bold=True))
        draw.text((PW-80, ly+30), "🗑", fill=(180, 150, 140), font=font(44))
        ly += 130

    bottom_label(draw, "Budget Planner Mode",
                 "Actual · Budget · Reports — in one view")
    img.save(os.path.join(OUT, "screenshot_7_tabbed_mode.png"))
    print("✓ screenshot_7_tabbed_mode.png")


# ══════════════════════════════════════════════════════════════════════════════
#  SCREENSHOT 8 – Reports (dark hero card)
# ══════════════════════════════════════════════════════════════════════════════
def make_ss8():
    img = new_screen(CREAM)
    draw = ImageDraw.Draw(img)

    # App bar
    draw.rectangle([0, 0, PW, 100], fill=WHITE)
    status_bar(draw, dark=False)
    draw.rectangle([0, 100, PW, 230], fill=WHITE)
    draw.text((60, 140), "Budget Planner", fill=BURGUNDY, font=font(64, bold=True))

    # Tabs
    draw.rectangle([0, 230, PW, 360], fill=WHITE)
    for i, (lbl, active) in enumerate([("Actual", False), ("Budget", False), ("Reports", True)]):
        tx = 60 + i * 320
        col = BURGUNDY if active else (160, 130, 110)
        draw.text((tx+60, 270), lbl, fill=col, font=font(44, bold=active))
        if active:
            draw.rectangle([tx+20, 348, tx+280, 360], fill=BURGUNDY)

    # Period selector card
    rounded_rect(draw, [40, 380, PW-40, 540], 24, WHITE)
    draw.text((90, 406), "Report period", fill=(15, 30, 60), font=font(44, bold=True))
    for i, (lbl, active) in enumerate([("Weekly", False), ("Monthly", True),
                                        ("Quarterly", False), ("Annual", False)]):
        px = 80 + i * 235
        bc = (*BURGUNDY, 20) if active else None
        if active:
            rounded_rect(draw, [px, 456, px+220, 522], 14, (200, 150, 150))
        col = BURGUNDY if active else (160, 130, 110)
        centered(draw, lbl, font(36, bold=active), 466, col, px*2+100)

    draw.text((90, 530), "1 Jun 2026 – 30 Jun 2026", fill=(160, 130, 110), font=font(30))

    # Unassigned cash (dark hero)
    rounded_rect(draw, [40, 560, PW-40, 1030], 32, (28, 26, 24))
    draw.text((90, 598), "UNASSIGNED CASH", fill=(160, 150, 140), font=font(30, bold=True))
    draw.text((90, 644), "UGX 12,612,126", fill=WHITE, font=font(80, bold=True))
    progress_bar(draw, 90, 744, PW-180, 10, 0.111, (80, 70, 60), AMBER, 5)

    draw.line([(80, 786), (PW-80, 786)], fill=(60, 55, 50), width=2)

    rows = [
        ("Income",          "UGX 14,182,126", True),
        ("Budgeted",        "UGX 1,570,000",  False),
        ("Monthly actual",  "UGX 0",          True),
        ("Actual left",     "UGX 14,182,126", True),
    ]
    ry = 820
    for lbl, val, bold in rows:
        lc = (180, 170, 160) if not bold else (220, 215, 210)
        draw.text((90, ry), lbl, fill=lc, font=font(38, bold=bold))
        vw = text_w(draw, val, font(44 if bold else 38, bold=bold))
        draw.text((PW-90-vw, ry), val, fill=WHITE,
                  font=font(44 if bold else 38, bold=bold))
        ry += bold and 70 or 60

    draw.line([(80, 1000), (PW-80, 1000)], fill=(60, 55, 50), width=2)
    draw.text((90, 1010), "Expense budget vs income", fill=(160, 150, 140), font=font(36))
    draw.text((PW-180, 1010), "11.1%", fill=WHITE, font=font(40, bold=True))

    # Category spending
    rounded_rect(draw, [40, 1050, PW-40, 1560], 32, WHITE)
    draw.text((90, 1086), "Spending by category", fill=(15, 30, 60), font=font(48, bold=True))

    cats2 = [
        ("🛒", "Groceries",  180_000, 400_000, EMERALD),
        ("🚗", "Transport",   95_000, 150_000, SKY),
        ("🍽️", "Food",        210_000, 200_000, ROSE),
        ("💡", "Utilities",    80_000, 100_000, VIOLET),
    ]
    cy3 = 1158
    for emoji, cat, spent, budget, col in cats2:
        draw.text((90, cy3), emoji, fill=WHITE, font=font(46))
        draw.text((180, cy3+2), cat, fill=(15, 30, 60), font=font(40, bold=True))
        over = spent > budget
        vs2 = f"UGX {spent//1000:,}K"
        vw2 = text_w(draw, vs2, font(40, bold=True))
        draw.text((PW-90-vw2, cy3+2), vs2, fill=ROSE if over else col,
                  font=font(40, bold=True))
        if over:
            draw.text((PW-230, cy3+52), "Over ▲",
                      fill=ROSE, font=font(28, bold=True))
        progress_bar(draw, 90, cy3+54, PW-180, 10, min(spent/budget, 1),
                     (*col, 30), ROSE if over else col, 5)
        cy3 += 100

    bottom_label(draw, "Complete financial reports",
                 "Unassigned cash · Budget performance · Trends")
    img.save(os.path.join(OUT, "screenshot_8_reports.png"))
    print("✓ screenshot_8_reports.png")


# ═══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("Generating Budjit Play Store assets…")
    make_feature_graphic()
    make_ss1()
    make_ss2()
    make_ss3()
    make_ss4()
    make_ss5()
    make_ss6()
    make_ss7()
    make_ss8()
    print("\n✅ All assets saved to store_assets/")
