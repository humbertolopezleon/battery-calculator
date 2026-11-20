// Nada se corta ni se desborda de 320 a 411 dp, con y sin letra grande (PROMPT §4).
// Un desborde de RenderFlex es un error de Flutter: hace fallar la prueba.
import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/domain/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  for (final width in [320.0, 360.0, 411.0]) {
    for (final big in [false, true]) {
      for (final theme in [ThemePref.light, ThemePref.dark]) {
        final name = '${width.round()} dp${big ? ', letra grande' : ''}, ${theme.name}';

        testWidgets('De noche sin desbordes: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme);
          await pumpApp(tester, s, width: width);
          // Abrir los dos plegables para revisar todo.
          await scrollThrough(tester);
          await tester.tap(find.text('Más opciones'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
          await tester.tap(find.text('Cómo se calcula'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
        });

        testWidgets('Duración sin desbordes: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme, tab: AppTab.runtime);
          await pumpApp(tester, s, width: width);
          await scrollThrough(tester);
          await tester.tap(find.text('Más opciones'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
          await tester.tap(find.text('Cómo se calcula'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
        });

        testWidgets('Duración, no alcanza con hora de fin: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme, tab: AppTab.runtime)
            ..nW = '1500'
            ..rTo = '06:00';
          await pumpApp(tester, s, width: width);
          expect(find.text('No alcanza hasta las 6:00\u00a0a.\u00a0m.'), findsOneWidget);
          expect(find.text('Probar con 800 W'), findsOneWidget);
          await scrollThrough(tester);
          expect(find.bySemanticsLabel('Quitar la hora de fin'), findsOneWidget);
        });

        testWidgets('No llega, con «Probar con»: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme)
            ..nPct = '45'
            ..nW = '900'
            ..nightNow = '22:30'
            ..nSun = '06:45';
          await pumpApp(tester, s, width: width);
          expect(find.text('Probar con 430 W'), findsOneWidget);
          await scrollThrough(tester);
        });

        testWidgets('Cargando con la red sin desbordes: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme)..tab = AppTab.charge;
          await pumpApp(tester, s, width: width);
          await scrollThrough(tester);
          await tester.tap(find.text('Cómo se calcula'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
          // Modo amperios.
          s.update((s) => s.pmode = PowerMode.amps);
          await tester.pumpAndSettle();
          await scrollThrough(tester);
        });

        testWidgets('Primera vez sin desbordes: $name', (tester) async {
          final s = stateWithBattery(big: big, theme: theme)..cap = null;
          await pumpApp(tester, s, width: width);
          await scrollThrough(tester);
          await tester.tap(find.text('En voltios y Ah'));
          await tester.pumpAndSettle();
          await scrollThrough(tester);
        });
      }
    }
  }

  testWidgets('textos largos en inglés a 320 dp con letra grande', (tester) async {
    final s = stateWithBattery(lang: 'en', big: true)
      ..nPct = '45'
      ..nW = '900'
      ..nightNow = '22:30'
      ..nSun = '06:45';
    await pumpApp(tester, s, width: 320);
    await scrollThrough(tester);
    s.update(
      (s) => s
        ..tab = AppTab.runtime
        ..rTo = '06:45',
    );
    await tester.pumpAndSettle();
    expect(find.text('Try 360 W'), findsOneWidget);
    await scrollThrough(tester);
    s.update((s) => s.tab = AppTab.charge);
    await tester.pumpAndSettle();
    await scrollThrough(tester);
  });

  testWidgets('la letra del sistema al 130% más letra grande no rompe nada a 360 dp', (tester) async {
    final s = stateWithBattery(big: true);
    await pumpApp(tester, s, width: 360, systemText: 1.3);
    await scrollThrough(tester);
  });
}
