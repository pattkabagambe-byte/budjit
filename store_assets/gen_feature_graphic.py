"""
Cashflo – Premium Feature Graphic Generator
Output: feature_graphic_v2.png  (1024 × 500, RGB)
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math, os

OUT  = os.path.dirname(__file__)
W, H = 1024, 500

# ── Palette ───────────────────────────────────────────────────────────────────
INK          = (6,  13,  26)        # near-black navy
NAVY         = (10,  22,  50)
NAVY_MID     = (14,  30,  66)
NAVY_CARD    = (18,  38,  82)
EMERALD      = (16, 185, 129)
EMERALD_L    = (52, 211, 153)
EMERALD_D    = (5,  150, 105)
AMBER        = (245, 158, 11)
ROSE         = (239, 68,  68)
VIOLET       = (139, 92, 246)
SKY          = (14, 165, 233)
WHITE        = (255, 255, 255)
WHITE60      = (255, 255, 255)      # used with alpha=150
WHITE30      = (255, 255, 255)      # used with alpha=76
GREY         = (140, 155, 185)

# ── Font helpers ──────────────────────────────────────────────────────────────
ARIAL_BOLD   = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
ARIAL        = "/System/Library/Fonts/Supplemental/Arial.ttf"
ARIAL_NARROW = "/System/Library/Fonts/Supplemental/Arial Narrow.ttf"

def F(size, bold=False):
    try:
        return ImageFont.truetype(ARIAL_BOLD if bold else ARIAL, size)
    except Exception:
        return ImageFont.load_default()

def tw(draw, text, fnt):
    bb = draw.textbbox((0, 0), text, font=fnt)
    return bb[2] - bb[0]

def th(draw, text, fnt):
    bb = draw.textbbox((0, 0), text, font=fnt)
    return bb[3] - bb[1]

def place(draw, text, fnt, x, y, col, anchor="lt"):
    draw.text((x, y), text, fill=col, font=fnt, anchor=anchor)

def center_x(draw, text, fnt, y, col, region_x=0, region_w=W):
    w = tw(draw, text, fnt)
    x = region_x + (region_w - w) // 2
    draw.text((x, y), text, fill=col, font=fnt)

# ── Compositing helpers ───────────────────────────────────────────────────────
def paste_rgba(base, layer, pos=(0,0)):
    """Paste an RGBA layer onto an RGB base using alpha as mask."""
    base.paste(layer, pos, layer)

def glow_circle(radius, color, sigma=None):
    """Return an RGBA image of a soft glowing disk."""
    if sigma is None:
        sigma = radius // 2
    sz = radius * 2 + int(sigma * 4)
    img = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)
    cx  = sz // 2
    d.ellipse([cx-radius, cx-radius, cx+radius, cx+radius],
              fill=(*color, 80))
    return img.filter(ImageFilter.GaussianBlur(sigma))

def rounded_rect_rgba(draw, box, r, fill, outline=None, ow=1):
    x0, y0, x1, y1 = box
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=fill,
                            outline=outline, width=ow)

def card_shadow(base, box, r, offset=6, blur=12):
    """Draw a dark blurred shadow behind a card."""
    x0, y0, x1, y1 = box
    sh = Image.new("RGBA", (x1-x0+offset*2+blur*2, y1-y0+offset*2+blur*2), (0,0,0,0))
    sd = ImageDraw.Draw(sh)
    sd.rounded_rectangle([blur, blur, x1-x0+blur*2, y1-y0+blur*2],
                          radius=r, fill=(0, 0, 0, 140))
    sh = sh.filter(ImageFilter.GaussianBlur(blur//2))
    base.paste(sh, (x0-blur, y0-blur), sh)

# ── Build gradient background ─────────────────────────────────────────────────
def make_background():
    img = Image.new("RGBA", (W, H))
    d   = ImageDraw.Draw(img)
    # Horizontal gradient: very dark navy left → slightly lighter right
    for x in range(W):
        t = x / W
        r = int(INK[0] + (NAVY_MID[0]-INK[0]) * t)
        g = int(INK[1] + (NAVY_MID[1]-INK[1]) * t)
        b = int(INK[2] + (NAVY_MID[2]-INK[2]) * t)
        d.line([(x, 0), (x, H)], fill=(r, g, b, 255))
    return img.convert("RGBA")

# ── Subtle dot-grid overlay ───────────────────────────────────────────────────
def dot_grid(base):
    layer = Image.new("RGBA", (W, H), (0,0,0,0))
    d = ImageDraw.Draw(layer)
    spacing = 28
    for gx in range(0, W+spacing, spacing):
        for gy in range(0, H+spacing, spacing):
            d.ellipse([gx-1, gy-1, gx+1, gy+1], fill=(255,255,255,18))
    base.paste(layer, (0,0), layer)

# ── Diagonal accent stripe ────────────────────────────────────────────────────
def accent_stripe(base):
    layer = Image.new("RGBA", (W, H), (0,0,0,0))
    d = ImageDraw.Draw(layer)
    # Thin emerald diagonal line
    d.line([(420, 0), (720, H)], fill=(*EMERALD, 30), width=140)
    blurred = layer.filter(ImageFilter.GaussianBlur(30))
    base.paste(blurred, (0,0), blurred)

# ── Glow blobs ────────────────────────────────────────────────────────────────
def glow_blobs(base):
    # Large emerald glow bottom-left
    g1 = glow_circle(180, EMERALD, sigma=70)
    base.paste(g1, (-80, H-120), g1)
    # Smaller violet glow top-right
    g2 = glow_circle(120, VIOLET, sigma=55)
    base.paste(g2, (W-80, -60), g2)
    # Tiny sky glow mid-right
    g3 = glow_circle(70, SKY, sigma=35)
    base.paste(g3, (W-180, H//2-30), g3)

# ── App icon (60×60) ─────────────────────────────────────────────────────────
def draw_app_icon(img, x, y, size=64):
    d = ImageDraw.Draw(img)
    # Shadow
    sh = Image.new("RGBA", (size+20, size+20), (0,0,0,0))
    sd = ImageDraw.Draw(sh)
    sd.rounded_rectangle([6,6,size+14,size+14], radius=18,
                          fill=(EMERALD[0],EMERALD[1],EMERALD[2],60))
    sh = sh.filter(ImageFilter.GaussianBlur(5))
    img.paste(sh, (x-8, y-6), sh)
    # Icon background
    rounded_rect_rgba(d, [x, y, x+size, y+size], 16, EMERALD)
    # Rising line chart inside
    pts = [(x+10, y+48), (x+22, y+36), (x+34, y+44), (x+46, y+24), (x+56, y+14)]
    d.line(pts, fill=WHITE, width=3)
    # Arrow cap
    d.polygon([(x+56, y+14), (x+50, y+20), (x+58, y+22)], fill=WHITE)
    # Small "₦" or "$" symbol bottom-left
    d.text((x+8, y+38), "$", fill=(*WHITE, 90), font=F(14, bold=True))

# ── Word-mark ─────────────────────────────────────────────────────────────────
def draw_wordmark(img, x, y):
    d = ImageDraw.Draw(img)
    # "cash" in white, "flo" in emerald
    fnt = F(68, bold=True)
    cash_w = tw(d, "cash", fnt)
    d.text((x, y), "cash", fill=WHITE, font=fnt)
    d.text((x + cash_w, y), "flo", fill=EMERALD, font=fnt)

# ── Tagline ───────────────────────────────────────────────────────────────────
def draw_tagline(img, x, y):
    d = ImageDraw.Draw(img)
    line1 = "Master your money."
    line2 = "Build your future."
    d.text((x, y),    line1, fill=WHITE, font=F(22, bold=True))
    d.text((x, y+30), line2, fill=(*EMERALD_L, 255), font=F(22, bold=True))

# ── Sub-tagline ───────────────────────────────────────────────────────────────
def draw_sub(img, x, y):
    d = ImageDraw.Draw(img)
    d.text((x, y), "Personal Finance for Africa & the World",
           fill=(*GREY, 200), font=F(14))

# ── Feature pills ─────────────────────────────────────────────────────────────
FEATURES = [
    ("💰", "Expense Tracking",  EMERALD),
    ("📊", "Smart Analytics",   SKY),
    ("🎯", "Savings Goals",     VIOLET),
    ("🤖", "AI Coach",          AMBER),
    ("🔒", "Works Offline",     (80, 160, 120)),
    ("⚡", "Instant Insights",  (200, 100, 50)),
]

def draw_feature_pills(img, x0, y0):
    d = ImageDraw.Draw(img)
    px, py = x0, y0
    col_w = 185
    for i, (emoji, label, col) in enumerate(FEATURES):
        if i > 0 and i % 2 == 0:
            px  = x0
            py += 38
        # Pill background
        pill_w = col_w - 6
        layer = Image.new("RGBA", (pill_w, 30), (0,0,0,0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle([0, 0, pill_w-1, 29], radius=15,
                              fill=(*col, 28))
        ld.rounded_rectangle([0, 0, pill_w-1, 29], radius=15,
                              outline=(*col, 80), width=1)
        img.paste(layer, (px, py), layer)
        # Text
        lbl = f"{emoji} {label}"
        d.text((px + 12, py + 6), lbl, fill=(*col, 220), font=F(13, bold=True))
        px += col_w

# ── Left-side separator line ──────────────────────────────────────────────────
def draw_separator(img):
    d = ImageDraw.Draw(img)
    # Vertical gradient line
    for y in range(30, H-30):
        t = abs(y - H//2) / (H//2 - 30)
        alpha = int(60 * (1 - t))
        d.point((390, y), fill=(*EMERALD, alpha))

# ══════════════════════════════════════════════════════════════════════════════
#  PHONE MOCKUP  (centre-right of the graphic)
# ══════════════════════════════════════════════════════════════════════════════
PX, PY  = 422, 18     # top-left of phone on canvas
PW, PH2 = 216, 428    # phone dimensions
SCR_PAD = 12          # padding inside phone frame to screen edge

def draw_phone(img):
    d = ImageDraw.Draw(img)

    # ── Phone shadow ──
    sh = Image.new("RGBA", (PW+40, PH2+40), (0,0,0,0))
    sd = ImageDraw.Draw(sh)
    sd.rounded_rectangle([14, 14, PW+26, PH2+26], radius=36,
                          fill=(0, 0, 0, 120))
    sh = sh.filter(ImageFilter.GaussianBlur(10))
    img.paste(sh, (PX-14, PY-14), sh)

    # ── Phone body ──
    rounded_rect_rgba(d, [PX, PY, PX+PW, PY+PH2], 36,
                      fill=(22, 34, 64),
                      outline=(50, 72, 120), ow=2)

    # ── Screen area ──
    sx0, sy0 = PX+SCR_PAD, PY+SCR_PAD
    sx1, sy1 = PX+PW-SCR_PAD, PY+PH2-SCR_PAD
    rounded_rect_rgba(d, [sx0, sy0, sx1, sy1], 28, fill=(8, 16, 36))

    # ── Dynamic island ──
    island_w, island_h = 52, 12
    ix = PX + PW//2 - island_w//2
    iy = sy0 + 6
    rounded_rect_rgba(d, [ix, iy, ix+island_w, iy+island_h], 6, (4, 8, 20))

    # ── Status bar ──
    d.text((sx0+8, sy0+5), "9:41", fill=(*WHITE, 180), font=F(9, bold=True))
    d.text((sx1-36, sy0+5), "●●●", fill=(*WHITE, 120), font=F(7))

    _draw_app_bar(d, sx0, sy0, sx1-sx0)
    _draw_balance_card(d, img, sx0, sy0, sx1-sx0)
    _draw_safe_spend(d, sx0, sy0, sx1-sx0)
    _draw_stats_row(d, sx0, sy0, sx1-sx0)
    _draw_transactions(d, sx0, sy0, sx1-sx0)

    # ── Bottom nav bar ──
    nav_y = sy1 - 26
    rounded_rect_rgba(d, [sx0, nav_y, sx1, sy1], 0, (12, 22, 48))
    icons = ["⌂", "◎", "★", "↑", "☰"]
    for i, ic in enumerate(icons):
        nx = sx0 + 6 + i * ((sx1-sx0-12)//5)
        col = EMERALD if i == 0 else (*WHITE, 60)
        d.text((nx+2, nav_y+5), ic, fill=col, font=F(9))

    # ── Side buttons ──
    d.rectangle([PX-3, PY+80, PX-1, PY+110], fill=(40, 60, 100))
    d.rectangle([PX+PW+1, PY+90, PX+PW+3, PY+114], fill=(40, 60, 100))


def _draw_app_bar(d, sx0, sy0, sw):
    y = sy0 + 22
    d.text((sx0+8, y), "cashflo", fill=EMERALD, font=F(11, bold=True))
    d.text((sx0+sw-28, y), "☰", fill=(*WHITE, 120), font=F(10))


def _draw_balance_card(d, img, sx0, sy0, sw):
    cx0 = sx0 + 5
    cy0 = sy0 + 38
    cx1 = sx0 + sw - 5
    cy1 = cy0 + 110

    # Card gradient (navy → navy-lighter)
    for y in range(cy0, cy1):
        t = (y - cy0) / (cy1 - cy0)
        r = int(12 + (22-12)*t)
        g = int(26 + (44-26)*t)
        b = int(58 + (80-58)*t)
        d.line([(cx0, y), (cx1, y)], fill=(r, g, b))
    rounded_rect_rgba(d, [cx0, cy0, cx1, cy1], 14, fill=None,
                      outline=(50, 80, 140), ow=1)

    d.text((cx0+8, cy0+6), "Monthly Balance", fill=(*WHITE, 100), font=F(8))
    d.text((cx0+8, cy0+18), "UGX 14,250,000", fill=WHITE, font=F(15, bold=True))
    d.text((cx0+8, cy0+38), "✓ 28.4% savings", fill=EMERALD, font=F(8))

    # Progress bar
    bar_x0, bar_x1 = cx0+8, cx1-8
    bar_y  = cy0 + 54
    d.rounded_rectangle([bar_x0, bar_y, bar_x1, bar_y+5], radius=3,
                         fill=(255,255,255,25))
    fill_x = bar_x0 + int((bar_x1-bar_x0) * 0.72)
    d.rounded_rectangle([bar_x0, bar_y, fill_x, bar_y+5], radius=3,
                         fill=EMERALD)

    # Mini income/expense
    mid = (cx0+cx1)//2 - 2
    _mini_stat(d, cx0+6, cy0+66, mid-cx0-10, "Income", "UGX 19.8M", EMERALD)
    _mini_stat(d, mid+4, cy0+66, cx1-mid-10, "Expenses", "UGX 5.55M", ROSE)

    # Tiny dot indicator
    d.ellipse([cx1-18, cy0+8, cx1-12, cy0+14], fill=EMERALD)


def _mini_stat(d, x, y, w, label, value, col):
    d.rounded_rectangle([x, y, x+w, y+34], radius=6,
                         fill=(255, 255, 255, 12))
    d.text((x+4, y+3),  label, fill=(*col, 160), font=F(7))
    d.text((x+4, y+15), value, fill=WHITE,        font=F(7, bold=True))


def _draw_safe_spend(d, sx0, sy0, sw):
    y = sy0 + 156
    rounded_rect_rgba(d, [sx0+5, y, sx0+sw-5, y+28], 8, fill=(16, 28, 60))
    d.text((sx0+11, y+4), "🗓", fill=(*EMERALD, 220), font=F(12))
    d.text((sx0+26, y+4), "Safe to spend today", fill=(*WHITE, 100), font=F(7))
    d.text((sx0+26, y+14), "UGX 68,400", fill=WHITE, font=F(9, bold=True))


def _draw_stats_row(d, sx0, sy0, sw):
    y = sy0 + 192
    d.text((sx0+8, y), "This Month", fill=WHITE, font=F(9, bold=True))
    y += 14
    third = (sw - 16) // 3
    stats = [("UGX 19.8M", "Income", EMERALD),
             ("UGX 5.55M", "Expenses", ROSE),
             ("47", "Entries", VIOLET)]
    for i, (val, lbl, col) in enumerate(stats):
        rx = sx0+8 + i*third
        rounded_rect_rgba(d, [rx, y, rx+third-4, y+34], 7, fill=(16,28,62))
        d.text((rx+4, y+3),  val, fill=WHITE, font=F(8, bold=True))
        d.text((rx+4, y+18), lbl, fill=(*col, 200), font=F(7))


def _draw_transactions(d, sx0, sy0, sw):
    y = sy0 + 264
    d.text((sx0+8, y), "Recent", fill=(*WHITE, 140), font=F(8, bold=True))
    y += 14
    txs = [
        ("🛒", "Nakumatt", "-85K",  ROSE),
        ("💼", "Salary",   "+19.8M", EMERALD),
        ("🚗", "Bodaboda", "-12K",   ROSE),
    ]
    for emoji, label, amt, col in txs:
        rounded_rect_rgba(d, [sx0+5, y, sx0+sw-5, y+24], 6, fill=(18,30,64))
        d.text((sx0+8,   y+5), emoji, fill=WHITE, font=F(11))
        d.text((sx0+22, y+7), label, fill=(*WHITE, 180), font=F(8, bold=True))
        aw = tw(d, amt, F(8, bold=True))
        d.text((sx0+sw-aw-8, y+7), amt, fill=col, font=F(8, bold=True))
        y += 28


# ══════════════════════════════════════════════════════════════════════════════
#  FLOATING CARDS (right of phone)
# ══════════════════════════════════════════════════════════════════════════════
def draw_health_score_card(img):
    """Financial Health Score card — top right."""
    cx, cy, cw, ch = 680, 28, 148, 100
    d = ImageDraw.Draw(img)

    card_shadow(img, [cx, cy, cx+cw, cy+ch], 16)
    card = Image.new("RGBA", (cw, ch), (0,0,0,0))
    cd   = ImageDraw.Draw(card)
    cd.rounded_rectangle([0, 0, cw-1, ch-1], radius=16,
                          fill=(16, 30, 68, 230),
                          outline=(50, 90, 160, 100), width=1)

    cd.text((12, 10), "Financial Health", fill=(*WHITE, 120), font=F(9))
    # Score ring (hand-drawn arc approximation)
    ring_x, ring_y, ring_r = 52, 52, 28
    # Background arc
    cd.ellipse([ring_x-ring_r, ring_y-ring_r, ring_x+ring_r, ring_y+ring_r],
               outline=(*EMERALD, 30), width=5)
    # Filled arc ~87% — draw it as a series of short lines
    for ang in range(-90, int(-90 + 360*0.87)):
        rx = ring_x + int(ring_r * math.cos(math.radians(ang)))
        ry = ring_y + int(ring_r * math.sin(math.radians(ang)))
        cd.ellipse([rx-3, ry-3, rx+3, ry+3], fill=(*EMERALD, 180))

    cd.text((ring_x-9, ring_y-14), "87", fill=WHITE,   font=F(16, bold=True))
    cd.text((ring_x-4, ring_y+4),  "A",  fill=EMERALD, font=F(9,  bold=True))

    cd.text((82, 28),  "Score",   fill=(*WHITE,   100), font=F(9))
    cd.text((82, 42),  "87/100",  fill=WHITE,           font=F(14, bold=True))
    cd.text((82, 62),  "Excellent",fill=EMERALD,        font=F(9,  bold=True))
    cd.text((82, 76),  "▲ +4 pts", fill=(*EMERALD, 160),font=F(8))

    img.paste(card, (cx, cy), card)


def draw_goal_card(img):
    """Savings goal progress card."""
    cx, cy, cw, ch = 680, 148, 148, 100
    d = ImageDraw.Draw(img)

    card_shadow(img, [cx, cy, cx+cw, cy+ch], 16)
    card = Image.new("RGBA", (cw, ch), (0,0,0,0))
    cd   = ImageDraw.Draw(card)
    cd.rounded_rectangle([0, 0, cw-1, ch-1], radius=16,
                          fill=(16, 30, 68, 230),
                          outline=(50, 90, 160, 100), width=1)

    cd.text((12, 10), "Top Goal", fill=(*WHITE, 120), font=F(9))
    cd.text((12, 24), "✈️  Dream Vacation", fill=WHITE, font=F(10, bold=True))
    cd.text((12, 40), "UGX 2.5M of 5M", fill=(*WHITE, 140), font=F(9))

    # Progress bar
    bar_w = cw - 24
    cd.rounded_rectangle([12, 58, 12+bar_w, 68], radius=5, fill=(*SKY, 30))
    cd.rounded_rectangle([12, 58, 12+bar_w//2, 68], radius=5, fill=SKY)
    cd.text((12, 74), "50% saved", fill=SKY, font=F(9, bold=True))
    cd.text((cw-52, 74), "By Dec 26", fill=(*WHITE, 80), font=F(8))

    img.paste(card, (cx, cy), card)


def draw_spending_card(img):
    """Spending breakdown mini card."""
    cx, cy, cw, ch = 680, 268, 148, 100
    d = ImageDraw.Draw(img)

    card_shadow(img, [cx, cy, cx+cw, cy+ch], 16)
    card = Image.new("RGBA", (cw, ch), (0,0,0,0))
    cd   = ImageDraw.Draw(card)
    cd.rounded_rectangle([0, 0, cw-1, ch-1], radius=16,
                          fill=(16, 30, 68, 230),
                          outline=(50, 90, 160, 100), width=1)

    cd.text((12, 10), "Top Spending", fill=(*WHITE, 120), font=F(9))
    items = [("🛒 Groceries", "22%", EMERALD),
             ("🚗 Transport", "15%", SKY),
             ("🏠 Housing",   "31%", AMBER)]
    y = 26
    for label, pct, col in items:
        cd.text((12, y), label, fill=(*WHITE, 180), font=F(9))
        pw = tw(cd, pct, F(9, bold=True))
        cd.text((cw-12-pw, y), pct, fill=col, font=F(9, bold=True))
        # Mini bar
        bar_pct = int(label.split()[0].count("🛒")*0.22 if "🛒" in label
                      else (0.15 if "🚗" in label else 0.31))
        filled = int((cw-24) * float(pct[:-1])/100)
        cd.rounded_rectangle([12, y+12, 12+cw-24, y+16], radius=2, fill=(*col, 30))
        cd.rounded_rectangle([12, y+12, 12+filled,  y+16], radius=2, fill=col)
        y += 22

    img.paste(card, (cx, cy), card)


def draw_ai_card(img):
    """AI insight card — bottom right."""
    cx, cy, cw, ch = 680, 386, 148, 80
    d = ImageDraw.Draw(img)

    card_shadow(img, [cx, cy, cx+cw, cy+ch], 16)
    card = Image.new("RGBA", (cw, ch), (0,0,0,0))
    cd   = ImageDraw.Draw(card)
    # Gradient fill (violet tint)
    for x in range(cw):
        t = x / cw
        r = int(20 + (40-20)*t)
        g = int(28 + (20-28)*t)
        b = int(70 + (100-70)*t)
        cd.line([(x,0),(x,ch-1)], fill=(r, g, b, 200))
    cd.rounded_rectangle([0, 0, cw-1, ch-1], radius=16,
                          outline=(*VIOLET, 80), width=1)

    cd.text((10, 8),  "🤖  AI Insight",    fill=(*WHITE, 200), font=F(10, bold=True))
    cd.text((10, 26), '"Cut transport by',  fill=(*WHITE, 160), font=F(8))
    cd.text((10, 38), '20% — save UGX 1.1M', fill=(*WHITE, 160), font=F(8))
    cd.text((10, 50), 'monthly."',           fill=(*WHITE, 160), font=F(8))
    cd.text((10, 64), "Tap for full report ›", fill=(*VIOLET, 200), font=F(8, bold=True))

    img.paste(card, (cx, cy), card)


# ══════════════════════════════════════════════════════════════════════════════
#  BOTTOM CREDIBILITY STRIP
# ══════════════════════════════════════════════════════════════════════════════
def draw_bottom_strip(img):
    d = ImageDraw.Draw(img)
    strip = Image.new("RGBA", (W, 40), (0,0,0,0))
    sd    = ImageDraw.Draw(strip)
    sd.rectangle([0, 0, W, 40], fill=(0, 0, 0, 60))
    img.paste(strip, (0, H-40), strip)

    items = [
        "🔒 Bank-level security",
        "✈️  Works offline",
        "🌍 Built for Africa & beyond",
        "⭐ Free to download",
    ]
    total_w = sum(tw(d, t, F(12)) + 40 for t in items)
    x = (W - total_w) // 2
    y = H - 30
    for item in items:
        iw = tw(d, item, F(12))
        pill = Image.new("RGBA", (iw+28, 22), (0,0,0,0))
        pd   = ImageDraw.Draw(pill)
        pd.rounded_rectangle([0, 0, iw+27, 21], radius=11,
                              fill=(*WHITE, 15), outline=(*WHITE, 30), width=1)
        img.paste(pill, (x, y), pill)
        d.text((x+14, y+4), item, fill=(*WHITE, 200), font=F(12))
        x += iw + 40


# ══════════════════════════════════════════════════════════════════════════════
#  ASSEMBLE
# ══════════════════════════════════════════════════════════════════════════════
def generate():
    # 1. Background layers
    img = make_background()
    dot_grid(img)
    accent_stripe(img)
    glow_blobs(img)

    # 2. Left copy section (x: 0–390)
    draw_app_icon(img, 44, 36, size=64)
    draw_wordmark(img, 44, 112)
    draw_tagline(img, 44, 194)
    draw_sub(img, 44, 256)

    # Thin divider under sub-tagline
    d = ImageDraw.Draw(img)
    d.line([(44, 282), (360, 282)], fill=(*EMERALD, 40), width=1)

    draw_feature_pills(img, 44, 296)
    draw_separator(img)

    # 3. Phone (centre)
    draw_phone(img)

    # 4. Floating cards (right)
    draw_health_score_card(img)
    draw_goal_card(img)
    draw_spending_card(img)
    draw_ai_card(img)

    # 5. Bottom strip
    draw_bottom_strip(img)

    # 6. Convert to RGB and save
    out = img.convert("RGB")
    path = os.path.join(OUT, "feature_graphic_v2.png")
    out.save(path, quality=98)
    print(f"✓  {path}  ({W}×{H})")


if __name__ == "__main__":
    generate()
