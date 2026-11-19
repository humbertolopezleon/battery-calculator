#!/usr/bin/env python3
"""Íconos PNG de respaldo para Android 7.0 y 7.1 (API 24-25), que no usan el ícono adaptativo.

Parte de los PNG de fondo completo de tool/icon_src/<densidad>.png (el mismo arte del adaptativo)
y deja dos versiones con margen transparente, como piden las guías de íconos heredados
(Lint IconLauncherShape):
  ic_launcher.png        cuadrado redondeado (Android 7.0 y launchers de íconos cuadrados)
  ic_launcher_round.png  círculo (android:roundIcon, Android 7.1)
Uso, desde apps/android: python3 tool/gen_legacy_icons.py   (necesita Pillow)
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / 'android/app/src/main/res'
SRC = ROOT / 'tool/icon_src'
SS = 8  # supermuestreo de la máscara


def mask(size: int, round_: bool) -> Image.Image:
    big = size * SS
    m = Image.new('L', (big, big), 0)
    d = ImageDraw.Draw(m)
    if round_:
        inset = round(big * 4 / 192)  # círculo de 184/192
        d.ellipse((inset, inset, big - inset - 1, big - inset - 1), fill=255)
    else:
        inset = round(big * 12 / 192)  # cuadrado de 168/192, radio de 30/192
        d.rounded_rectangle((inset, inset, big - inset - 1, big - inset - 1), radius=round(big * 30 / 192), fill=255)
    return m.resize((size, size), Image.LANCZOS)


for src in sorted(SRC.glob('*.png')):
    d = RES / f'mipmap-{src.stem}'
    full = Image.open(src).convert('RGBA')
    for name, round_ in (('ic_launcher.png', False), ('ic_launcher_round.png', True)):
        out = full.copy()
        out.putalpha(mask(full.width, round_))
        out.save(d / name, optimize=True)
        print(d.name, name, out.size)
