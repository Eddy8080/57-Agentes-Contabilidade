#!/usr/bin/env python3
"""
Gera build/assets/icon.ico — 57 Agents Contabilidade
Resoluções incluídas: 256, 128, 64, 48, 32, 24, 16 px
"""

from PIL import Image, ImageDraw, ImageFont
import os, io, struct, math

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT  = os.path.join(ROOT, "build", "assets", "icon.ico")

# Paleta do app (GitHub dark + blue accent)
BG_TOP   = (13,  17,  23)   # #0d1117
BG_BOT   = (22,  27,  34)   # #161b22
BLUE     = (88,  166, 255)  # #58a6ff
BLUE_DIM = (56,  112, 180)  # azul escuro p/ dots alternados
WHITE    = (240, 246, 252)  # #f0f6fc


def find_font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        r"C:\Windows\Fonts\bahnschrift.ttf",
        r"C:\Windows\Fonts\segoeuib.ttf",
        r"C:\Windows\Fonts\arialbd.ttf",
        r"C:\Windows\Fonts\calibrib.ttf",
        r"C:\Windows\Fonts\tahoma.ttf",
    ]
    for p in candidates:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make_icon(size: int) -> Image.Image:
    img  = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── Fundo com gradiente vertical ──────────────────────────
    for y in range(size):
        c = lerp(BG_TOP, BG_BOT, y / max(size - 1, 1))
        draw.line([(0, y), (size - 1, y)], fill=(*c, 255))

    # ── Máscara com cantos arredondados ───────────────────────
    pad    = max(1, round(size * 0.04))
    radius = round(size * 0.22)
    mask   = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [pad, pad, size - 1 - pad, size - 1 - pad],
        radius=radius, fill=255
    )
    img.putalpha(mask)
    draw = ImageDraw.Draw(img)

    # ── Borda interna sutil (realce) ──────────────────────────
    if size >= 48:
        border_alpha = 35
        ImageDraw.Draw(img).rounded_rectangle(
            [pad, pad, size - 1 - pad, size - 1 - pad],
            radius=radius, outline=(*BLUE, border_alpha), width=max(1, size // 80)
        )

    # ── Grade de pontos neural (≥ 64 px) ─────────────────────
    if size >= 64:
        step = size // 8
        r    = max(1, size // 80)
        for gx in range(step, size, step):
            for gy in range(step, size, step):
                draw.ellipse([gx-r, gy-r, gx+r, gy+r], fill=(*BLUE, 12))

    # ── Texto "57" ────────────────────────────────────────────
    fs   = round(size * 0.50)
    font = find_font(fs)

    bbox = draw.textbbox((0, 0), "57", font=font)
    tw   = bbox[2] - bbox[0]
    th   = bbox[3] - bbox[1]

    # Reserva espaço para linha de dots abaixo do número
    dots_reserve = size * 0.20 if size >= 32 else 0
    tx = (size - tw) // 2 - bbox[0]
    ty = round((size - th - dots_reserve) / 2) - bbox[1]

    # Glow azul atrás do número (≥ 48 px)
    if size >= 48:
        for dist in [3, 2]:
            for angle in range(0, 360, 45):
                ox = round(math.cos(math.radians(angle)) * dist)
                oy = round(math.sin(math.radians(angle)) * dist)
                draw.text((tx + ox, ty + oy), "57", font=font,
                          fill=(*BLUE, 20))

    # Sombra leve (dá profundidade)
    if size >= 32:
        draw.text((tx + 1, ty + 2), "57", font=font,
                  fill=(0, 0, 0, 80))

    draw.text((tx, ty), "57", font=font, fill=(*WHITE, 255))

    # ── Linha de "agentes" (dots azuis) ───────────────────────
    if size >= 32:
        n_dots  = 7 if size >= 80 else 5
        dot_r   = max(2, round(size * 0.040))
        dot_gap = max(1, round(dot_r * 0.75))
        total_w = n_dots * dot_r * 2 + (n_dots - 1) * dot_gap
        sx      = (size - total_w) // 2
        cy      = round(size * 0.835)

        for i in range(n_dots):
            x0    = sx + i * (dot_r * 2 + dot_gap)
            alpha = 235 if i % 2 == 0 else 130
            color = (*BLUE, alpha) if i % 2 == 0 else (*BLUE_DIM, alpha)
            draw.ellipse(
                [x0, cy - dot_r, x0 + dot_r * 2, cy + dot_r],
                fill=color
            )

    elif size >= 16:
        # Ícone minúsculo: só um traço azul
        lw = max(1, round(size * 0.10))
        ly = round(size * 0.84)
        draw.line(
            [(round(size * 0.25), ly), (round(size * 0.75), ly)],
            fill=(*BLUE, 220), width=lw
        )

    return img


def write_ico(images_by_size: dict, path: str) -> None:
    """Escreve um ICO multi-resolução com entradas PNG (ICO v3 + PNG embedding)."""
    sizes  = sorted(images_by_size.keys(), reverse=True)
    chunks = []
    for s in sizes:
        buf = io.BytesIO()
        images_by_size[s].save(buf, format="PNG")
        chunks.append((s, buf.getvalue()))

    n            = len(chunks)
    dir_sz       = 16
    header       = struct.pack("<HHH", 0, 1, n)   # Reserved=0, Type=1 (ICO), Count
    data_offset  = 6 + n * dir_sz
    offset       = data_offset

    dir_block = b""
    for s, data in chunks:
        w = h = 0 if s >= 256 else s   # ICO: 256 é representado por 0
        dir_block += struct.pack(
            "<BBBBHHII",
            w, h,           # width, height
            0,              # color count (0 = 256+)
            0,              # reserved
            1,              # color planes
            32,             # bits per pixel
            len(data),      # size of image data
            offset          # offset to image data
        )
        offset += len(data)

    with open(path, "wb") as f:
        f.write(header + dir_block)
        for _, data in chunks:
            f.write(data)


# ── Main ──────────────────────────────────────────────────────
if __name__ == "__main__":
    TARGET_SIZES = [256, 128, 64, 48, 32, 24, 16]

    print("Gerando icone 57 Agents...")
    images = {}
    for s in TARGET_SIZES:
        images[s] = make_icon(s)
        print(f"  {s:>3}x{s}  OK")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    write_ico(images, OUT)

    size_kb = os.path.getsize(OUT) / 1024
    print(f"\nSalvo: {OUT}")
    print(f"Tamanho: {size_kb:.1f} KB")
    print(f"Resolucoes: {', '.join(str(s) for s in TARGET_SIZES)} px")
