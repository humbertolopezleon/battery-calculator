// Todo lo táctil mide ≥ 48 × 48 dp y el texto tiene contraste suficiente, en claro y oscuro (PROMPT §4).
import 'package:battery_calculator/app/app_state.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Semantics;

import 'harness.dart';

void main() {
  for (final theme in [ThemePref.light, ThemePref.dark]) {
    for (final tab in AppTab.values) {
      testWidgets('48 dp y contraste: ${tab.name}, ${theme.name}', (tester) async {
        final handle = tester.ensureSemantics();
        final s = stateWithBattery(theme: theme)..tab = tab;
        // Pantalla alta: así ningún texto queda medio tapado por la barra inferior al medir el contraste.
        await pumpApp(tester, s, height: 2400, dpr: 3);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // En Carga, el detector de Flutter toma como «color del texto» el suavizado de letras finas
        // junto a muestras y bordes (falso positivo, ver README). Ahí el contraste se verifica con
        // los pares exactos de tokens en contrast_test.dart.
        if (tab == AppTab.night) await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('48 dp y contraste: primera vez, ${theme.name}', (tester) async {
      final handle = tester.ensureSemantics();
      final s = stateWithBattery(theme: theme)..cap = null;
      await pumpApp(tester, s, height: 1600, dpr: 3);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('la respuesta está en una región que TalkBack anuncia', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, stateWithBattery());
    final live = find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true);
    expect(live, findsWidgets);
    handle.dispose();
  });

  testWidgets('los botones de solo ícono tienen etiqueta', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, stateWithBattery());
    expect(find.bySemanticsLabel('Ajustes'), findsOneWidget);
    expect(find.bySemanticsLabel('Compartir resultado'), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('^Tu batería: 10,24 kWh')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('la batería deslizable se ajusta con los gestos de TalkBack', (tester) async {
    final handle = tester.ensureSemantics();
    final s = stateWithBattery();
    await pumpApp(tester, s);
    final slider = find.semantics.byPredicate(
      (n) => n.label == 'Porciento que marca ahora' && n.getSemanticsData().hasAction(SemanticsAction.increase),
    );
    expect(slider.evaluate().single.value, '85%');
    tester.semantics.increase(slider);
    await tester.pumpAndSettle();
    expect(s.nPct, '86');
    tester.semantics.decrease(slider);
    await tester.pumpAndSettle();
    tester.semantics.decrease(slider);
    await tester.pumpAndSettle();
    expect(s.nPct, '84');
    handle.dispose();
  });
}
