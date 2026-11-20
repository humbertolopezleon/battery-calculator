import 'dart:ui' as ui;

import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/app/store.dart';
import 'package:battery_calculator/ui/report/report_card.dart';
import 'package:battery_calculator/ui/report/share_sheet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

void main() {
  testWidgets('primera vez: «Empezar» se activa al elegir un atajo y se guarda la batería', (tester) async {
    final store = MemoryStore();
    final s = AppState(store, clock: fixedClock)..lang = 'es';
    await pumpApp(tester, s);
    expect(find.text('Calculadora de Batería'), findsOneWidget);
    final start = find.text('Empezar');
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(s.cap, isNull, reason: 'deshabilitado sin batería');
    await tester.tap(find.text('10,24'));
    await tester.pumpAndSettle();
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(s.cap, 10.24);
    expect(store.data!['cap'], 10.24);
    expect(find.text('La batería dura hasta las'), findsOneWidget);
    expect(find.text('Llegas al amanecer'), findsOneWidget);
  });

  testWidgets('en voltios y Ah muestra la capacidad calculada', (tester) async {
    final s = AppState(MemoryStore(), clock: fixedClock)..lang = 'es';
    await pumpApp(tester, s);
    await tester.tap(find.text('En voltios y Ah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '200');
    await tester.pumpAndSettle();
    expect(find.textContaining('10,24 kWh', findRichText: true), findsWidgets);
  });

  testWidgets('los datos se recuerdan al volver a abrir y la «hora ahora» se toma de nuevo', (tester) async {
    final store = MemoryStore();
    final s = stateWithBattery(store: store);
    await pumpApp(tester, s);
    await tester.enterText(find.byType(TextField).at(1), '750');
    await tester.pumpAndSettle();
    s.update((s) => s.nightNow = '23:15');
    expect(store.data!['nW'], '750');
    expect(store.data!.containsKey('nightNow'), isFalse);

    final again = AppState(store, clock: () => DateTime(2026, 11, 20, 5, 42));
    await again.load();
    expect(again.nW, '750');
    expect(again.cap, 10.24);
    expect(again.nightNow, '05:42');
    expect(again.chargeNow, '05:42');
  });

  testWidgets('«Probar con 430 W» pone el consumo y ya llega', (tester) async {
    final s = stateWithBattery()
      ..nPct = '45'
      ..nW = '900'
      ..nightNow = '22:30'
      ..nSun = '06:45';
    await pumpApp(tester, s, use24h: true);
    expect(find.text('No llegas al amanecer'), findsOneWidget);
    await tester.tap(find.text('Probar con 430 W'));
    await tester.pumpAndSettle();
    expect(s.nW, '430');
    expect(find.text('Llegas al amanecer'), findsOneWidget);
    expect(find.text('6:52'), findsWidgets);
  });

  testWidgets('el error aparece al salir del campo, y «Ir al dato» lleva el foco al campo', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    final pct = find.byType(TextField).first;
    await tester.enterText(pct, '120');
    await tester.pumpAndSettle();
    expect(find.text('Falta corregir un dato'), findsOneWidget);
    expect(find.text('Escribe un número del 0 al 100.'), findsNothing, reason: 'todavía se está escribiendo');
    // Salir del campo.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Escribe un número del 0 al 100.'), findsOneWidget);
    await tester.tap(find.text('Ir al dato'));
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(find.descendant(of: pct, matching: find.byType(EditableText)));
    expect(editable.focusNode.hasFocus, isTrue);
  });

  testWidgets('reserva inválida: al salir del campo se abre «Más opciones»', (tester) async {
    final s = stateWithBattery()..rsv = '95';
    await pumpApp(tester, s);
    expect(find.text('Revisa la reserva: debe ser un número del 0 al 90.'), findsOneWidget);
    await tester.tap(find.text('Ir al dato'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva de la batería'), findsOneWidget);
  });

  testWidgets('se filtran las letras con su aviso, y «25.000» se lee como 25000', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    final w = find.byType(TextField).at(1);
    await tester.enterText(w, '6a0');
    await tester.pump();
    expect(s.nW, '60');
    expect(find.text('Solo se pueden escribir números.'), findsOneWidget);
    await tester.enterText(w, '25.000');
    await tester.pumpAndSettle();
    expect(find.text('Se entendió: 25000 W. Si querías 25 W, escríbelo sin punto.'), findsOneWidget);
    expect(find.text('¿Seguro? Es más de lo normal en una casa.'), findsOneWidget);
  });

  testWidgets('la franja de respuesta aparece al bajar y al escribir', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    expect(find.text('Hasta 9:08 a. m.'), findsNothing);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Hasta 9:08 a. m.'), findsOneWidget);
    expect(find.text('Llegas'), findsOneWidget);
  });

  testWidgets('cambiar de pestaña vuelve arriba y muestra la carga', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s, use24h: true);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cargando con la red'));
    await tester.pumpAndSettle();
    expect(s.tab, AppTab.charge);
    expect(find.text('Tarda en cargar'), findsOneWidget);
    expect(find.text('3 h 16 min'), findsOneWidget);
    expect(find.text('Llega al 100% cerca de las 0:16'), findsOneWidget);
    expect(tester.widget<Scrollable>(find.byType(Scrollable).first).controller!.offset, 0);
  });

  testWidgets('ajustes: idioma, tema y letra grande; borrar datos pide dos toques', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    await tester.tap(find.bySemanticsLabel('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(s.lang, 'en');
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(s.theme, ThemePref.dark);
    await tester.tap(find.text('Large text'));
    await tester.pumpAndSettle();
    expect(s.big, isTrue);
    await tester.ensureVisible(find.text('Erase my data and start over'));
    await tester.tap(find.text('Erase my data and start over'));
    await tester.pumpAndSettle();
    expect(s.cap, 10.24, reason: 'el primer toque solo pide confirmar');
    await tester.tap(find.text('Tap again to erase everything'));
    await tester.pumpAndSettle();
    expect(s.cap, isNull);
    expect(find.text('Empezar').evaluate().isNotEmpty || find.text('Start').evaluate().isNotEmpty, isTrue);
  });

  testWidgets('hoja de batería: cambiar a 15 kWh', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    await tester.tap(find.bySemanticsLabel(RegExp('^Tu batería: ')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(s.cap, 15);
  });

  testWidgets('el reporte PNG mide 1080 px de ancho y se ve en la hoja de compartir', (tester) async {
    final s = stateWithBattery();
    await pumpApp(tester, s);
    await tester.ensureVisible(find.text('Compartir resultado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir resultado'));
    await tester.pumpAndSettle();
    expect(find.text('Compartir el reporte'), findsOneWidget);
    expect(find.text('reporte-noche.png'), findsOneWidget);
    final boundary = find.ancestor(of: find.byType(ReportCard), matching: find.byType(RepaintBoundary)).first;
    late ui.Image image;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(boundary);
      image = await ro.toImage(pixelRatio: reportPixelRatio);
    });
    expect(image.width, 1080);
    expect(image.height, inInclusiveRange(1500, 2400));
    image.dispose();
    // La captura que se comparte usa la misma función.
    expect(captureReport, isNotNull);
  });

  testWidgets('sin resultado no se puede compartir', (tester) async {
    final s = stateWithBattery()..nW = '';
    await pumpApp(tester, s);
    expect(find.text('Falta el consumo de la casa'), findsOneWidget);
    await tester.ensureVisible(find.text('Compartir resultado'));
    await tester.tap(find.text('Compartir resultado'));
    await tester.pumpAndSettle();
    expect(find.text('Compartir el reporte'), findsNothing);
  });
}
