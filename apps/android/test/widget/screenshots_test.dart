// Genera capturas de las pantallas principales en screenshots/ para compararlas con
// design/handoff/reference/screens/ (mismos nombres). 360 × 800 dp, reloj de 12 h.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/domain/calculator.dart';
import 'package:battery_calculator/ui/report/report_card.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

Future<void> _open(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  for (final (mode, theme) in [('claro', ThemePref.light), ('oscuro', ThemePref.dark)]) {
    testWidgets('flujo $mode', (tester) async {
      // 01 Primera vez
      final first = stateWithBattery(theme: theme)..cap = null;
      await pumpApp(tester, first);
      await saveScreenshot(tester, 'flujo-$mode-01-primera-vez');

      // 02 De noche · llega
      final s = stateWithBattery(theme: theme);
      await pumpApp(tester, s);
      await saveScreenshot(tester, 'flujo-$mode-02-de-noche-llega');

      // 03 De noche · no llega
      s.update(
        (s) => s
          ..nPct = '45'
          ..nW = '900'
          ..nightNow = '22:30'
          ..nSun = '06:45',
      );
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'flujo-$mode-03-de-noche-no-llega');

      // 04 Cargando con la red
      s.update(
        (s) => s
          ..tab = AppTab.charge
          ..chargeNow = '10:15',
      );
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'flujo-$mode-04-cargando-con-la-red');

      // 05 y 06 Hoja de batería
      await _open(tester, find.bySemanticsLabel(RegExp('^Tu batería: ')));
      await saveScreenshot(tester, 'flujo-$mode-05-tu-bateria-kwh');
      await _open(tester, find.text('En voltios y Ah'));
      await tester.enterText(find.byType(TextField).last, '200');
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'flujo-$mode-06-tu-bateria-voltios-y-ah');
      Navigator.of(tester.element(find.text('Voltios'))).pop();
      await tester.pumpAndSettle();

      // 07 Más opciones (De noche, abajo)
      s.update(
        (s) => s
          ..tab = AppTab.night
          ..nPct = '85'
          ..nW = '600'
          ..nightNow = '21:00'
          ..nSun = '07:00',
      );
      await tester.pumpAndSettle();
      await _open(tester, find.text('Más opciones'));
      await tester.ensureVisible(find.text('Volver a 6%'));
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'flujo-$mode-07-mas-opciones');

      // 08 Ajustes
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await tester.pumpAndSettle();
      await _open(tester, find.bySemanticsLabel('Ajustes'));
      await saveScreenshot(tester, 'flujo-$mode-08-ajustes');
    });
  }

  testWidgets('estados', (tester) async {
    final s = stateWithBattery()..nW = '';
    await pumpApp(tester, s);
    await saveScreenshot(tester, 'estados-01-vacio');

    s.update(
      (s) => s
        ..nW = '600'
        ..nPct = '120',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'estados-02-campo-invalido');

    s.update(
      (s) => s
        ..nPct = '85'
        ..nW = '25.000',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Consumo de la casa'));
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'estados-03-valor-raro');

    s.update(
      (s) => s
        ..nW = '600'
        ..rsv = '95',
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await _open(tester, find.text('Ir al dato'));
    await saveScreenshot(tester, 'estados-04-reserva-invalida');

    s.update(
      (s) => s
        ..rsv = '6'
        ..tab = AppTab.charge
        ..cPct = '100'
        ..cTgt = '80',
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'estados-05-no-hace-falta-cargar');

    s.update(
      (s) => s
        ..cap = 15
        ..tab = AppTab.night
        ..nPct = '100'
        ..nW = '9',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'estados-06-duracion-de-dias');

    s.update(
      (s) => s
        ..cap = 10.24
        ..tab = AppTab.charge
        ..cPct = '30'
        ..cTgt = '100'
        ..cW = '',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'estados-08-carga-campo-vacio');
  });

  testWidgets('peor caso: 320 dp con letra grande', (tester) async {
    final s = stateWithBattery(big: true)
      ..nPct = '45'
      ..nW = '900'
      ..nightNow = '22:30'
      ..nSun = '06:45';
    await pumpApp(tester, s, width: 320, height: 2200);
    await saveScreenshot(tester, 'peor-caso-01-de-noche-todo-a-la-vista');
    s.update(
      (s) => s
        ..tab = AppTab.charge
        ..chargeNow = '10:15',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'peor-caso-02-carga-todo-a-la-vista');
  });

  testWidgets('peor caso: lo que se ve al abrir a 320 dp, y teléfono ancho', (tester) async {
    await pumpApp(tester, stateWithBattery(big: true), width: 320);
    await saveScreenshot(tester, 'peor-caso-03-lo-que-se-ve-al-abrir');
    await pumpApp(tester, stateWithBattery(), width: 411, height: 914);
    await saveScreenshot(tester, 'peor-caso-05-telefono-ancho-411-dp');
  });

  testWidgets('inglés', (tester) async {
    final s = stateWithBattery(lang: 'en');
    await pumpApp(tester, s);
    await saveScreenshot(tester, 'ingles-01-at-night');
    s.update(
      (s) => s
        ..tab = AppTab.charge
        ..chargeNow = '10:15',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'ingles-02-charging-from-the-grid');
  });

  testWidgets('reporte PNG de 1080 px', (tester) async {
    for (final tab in AppTab.values) {
      final s = stateWithBattery(theme: ThemePref.dark)
        ..tab = tab
        ..rTo = '02:00'
        ..pmode = PowerMode.watts
        ..chargeNow = '10:15';
      await pumpApp(tester, s);
      await tester.ensureVisible(find.text('Compartir resultado'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compartir resultado'));
      await tester.pumpAndSettle();
      if (tab == AppTab.night) await saveScreenshot(tester, 'reporte-02-compartir-o-guardar');
      final boundary = find.ancestor(of: find.byType(ReportCard), matching: find.byType(RepaintBoundary)).first;
      await tester.runAsync(() async {
        final ro = tester.renderObject<RenderRepaintBoundary>(boundary);
        final image = await ro.toImage(pixelRatio: reportPixelRatio);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File(
          'screenshots/reporte-04-la-imagen-png-${switch (tab) {
            AppTab.runtime => 'duracion',
            AppTab.night => 'noche',
            AppTab.charge => 'carga',
          }}.png',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });

  for (final (mode, theme) in [('claro', ThemePref.light), ('oscuro', ThemePref.dark)]) {
    testWidgets('duración $mode', (tester) async {
      // 01 Sin hora de fin: lo que se ve al abrir.
      final s = stateWithBattery(theme: theme, tab: AppTab.runtime);
      await pumpApp(tester, s);
      await saveScreenshot(tester, 'duracion-$mode-01-sin-hora-de-fin');

      // 02 El rango de horas, más abajo.
      await tester.ensureVisible(find.text('Hasta qué hora (opcional)'));
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'duracion-$mode-02-rango-de-horas');

      // 03 Con hora de fin: alcanza.
      s.update((s) => s.rTo = '02:00');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'duracion-$mode-03-alcanza');

      // 04 Con hora de fin: no alcanza.
      s.update(
        (s) => s
          ..nW = '1500'
          ..rTo = '06:00',
      );
      await tester.pumpAndSettle();
      await saveScreenshot(tester, 'duracion-$mode-04-no-alcanza');
    });
  }

  testWidgets('duración: inglés, peor caso y vacío', (tester) async {
    final en = stateWithBattery(lang: 'en', theme: ThemePref.dark, tab: AppTab.runtime)
      ..nW = '1500'
      ..rTo = '06:00';
    await pumpApp(tester, en);
    await saveScreenshot(tester, 'duracion-ingles-01-runtime');

    final big = stateWithBattery(big: true, tab: AppTab.runtime)
      ..nW = '1500'
      ..rTo = '06:00';
    await pumpApp(tester, big, width: 320, height: 2300);
    await saveScreenshot(tester, 'duracion-peor-caso-01-todo-a-la-vista');
    await pumpApp(tester, stateWithBattery(big: true, tab: AppTab.runtime), width: 320);
    await saveScreenshot(tester, 'duracion-peor-caso-02-lo-que-se-ve-al-abrir');

    await pumpApp(tester, stateWithBattery(tab: AppTab.runtime)..nW = '');
    await saveScreenshot(tester, 'duracion-estados-01-vacio');
  });
}
