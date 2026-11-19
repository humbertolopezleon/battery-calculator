// Contraste WCAG exacto de cada par texto/fondo que usa la app, en claro y oscuro.
// Complementa textContrastGuideline (que mide sobre la imagen y tiene falsos positivos con letra fina).
import 'package:battery_calculator/ui/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double ratio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, c) in [('claro', AppColors.light), ('oscuro', AppColors.dark)]) {
    group('texto ($name) ≥ 4,5:1', () {
      final pairs = <String, (Color, Color)>{
        'tx/bg': (c.tx, c.bg),
        'tx/sf': (c.tx, c.sf),
        'tx/sf2': (c.tx, c.sf2),
        'tx2/bg': (c.tx2, c.bg),
        'tx2/sf': (c.tx2, c.sf),
        'tx2/sf2': (c.tx2, c.sf2),
        'tx2/nav': (c.tx2, c.nav),
        'tx/sel': (c.tx, c.sel),
        'bg/tx (elegido invertido)': (c.bg, c.tx),
        'onAmb/amb (botón principal)': (c.onAmb, c.amb),
        'bg/ambTx (botón presionado)': (c.bg, c.ambTx),
        'ok/okBg': (c.ok, c.okBg),
        'tx/okBg': (c.tx, c.okBg),
        'bad/badBg': (c.bad, c.badBg),
        'tx/badBg': (c.tx, c.badBg),
        'bad/sf (error de campo)': (c.bad, c.sf),
        'inf/infBg': (c.inf, c.infBg),
        'tx/infBg': (c.tx, c.infBg),
        'inf/sf (nota)': (c.inf, c.sf),
        'warn/warnBg': (c.warn, c.warnBg),
        'tx/warnBg': (c.tx, c.warnBg),
      };
      for (final MapEntry(key: k, value: (fg, bg)) in pairs.entries) {
        test(k, () => expect(ratio(fg, bg), greaterThanOrEqualTo(4.5)));
      }
    });
    group('bordes y gráficos ($name) ≥ 3:1', () {
      final pairs = <String, (Color, Color)>{
        'ln/sf (borde de campo)': (c.ln, c.sf),
        'focus/sf': (c.focus, c.sf),
        'rsv/sf': (c.rsv, c.sf),
        'chg/sf': (c.chg, c.sf),
        'tx/sf (batería)': (c.tx, c.sf),
      };
      for (final MapEntry(key: k, value: (fg, bg)) in pairs.entries) {
        test(k, () => expect(ratio(fg, bg), greaterThanOrEqualTo(3)));
      }
    });
  }
}
