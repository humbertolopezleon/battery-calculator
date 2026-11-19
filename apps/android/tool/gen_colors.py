#!/usr/bin/env python3
"""Regenera lib/ui/theme/app_colors.dart desde design/handoff/design/tokens.json.
Uso (desde apps/android): python3 tool/gen_colors.py && dart format -l 120 lib/ui/theme"""
import json, re
d = json.load(open('../../design/handoff/design/tokens.json'))
cols = d['color']
def c(v):
    v = v.strip()
    if v.startswith('#'):
        return 'Color(0xFF%s)' % v[1:].upper()
    r, g, b, a = re.match(r'rgba\((\d+),(\d+),(\d+),([\d.]+)\)', v.replace(' ', '')).groups()
    return 'Color(0x%02X%02X%02X%02X)' % (round(float(a) * 255), int(r), int(g), int(b))
names = list(cols)
L = ['// GENERADO desde design/handoff/design/tokens.json (no editar a mano).', '// Para regenerar: tool/gen_colors.py', '',
     "import 'package:flutter/painting.dart';", "import 'package:material_ui/material_ui.dart' show ThemeExtension;", '',
     '/// Colores del diseño (DESIGN, tokens.json), en claro y oscuro.', 'class AppColors extends ThemeExtension<AppColors> {', '  const AppColors({']
L += ['    required this.%s,' % n for n in names]
L += ['  });', '']
for n in names:
    L.append('  /// %s' % cols[n].get('use', ''))
    L.append('  final Color %s;' % n)
for mode in ('light', 'dark'):
    L.append('')
    L.append('  static const %s = AppColors(' % mode)
    for n in names:
        L.append('    %s: %s,' % (n, c(cols[n][mode])))
    L.append('  );')
L += ['', '  @override', '  AppColors copyWith() => this;', '', '  @override',
      '  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);', '}', '']
open('lib/ui/theme/app_colors.dart', 'w').write('\n'.join(L))
