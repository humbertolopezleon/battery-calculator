import 'dart:io';
import 'dart:ui' as ui;

import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/app/store.dart';
import 'package:battery_calculator/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// 21:00 de un día cualquiera: la «hora ahora» de las pruebas.
DateTime fixedClock() => DateTime(2026, 11, 19, 21, 0);

/// Estado con batería de 10,24 kWh y los valores por defecto.
/// [tab] es De noche porque la mayoría de las pruebas son de esa pestaña; la app abre en Duración.
AppState stateWithBattery({
  String lang = 'es',
  ThemePref theme = ThemePref.light,
  bool big = false,
  Store? store,
  AppTab tab = AppTab.night,
}) {
  final s = AppState(store ?? MemoryStore(), clock: fixedClock)
    ..tab = tab
    ..cap = 10.24
    ..capTxt = '10,24'
    ..lang = lang
    ..theme = theme
    ..big = big;
  return s;
}

/// Monta la app con un ancho en dp, tema, letra del sistema y reloj de 12 h (como las capturas).
Future<void> pumpApp(
  WidgetTester tester,
  AppState state, {
  double width = 360,
  double height = 800,
  double systemText = 1.0,
  bool use24h = false,
  Brightness brightness = Brightness.light,
  double dpr = 2,
}) async {
  tester.view.physicalSize = Size(width * dpr, height * dpr);
  tester.view.devicePixelRatio = dpr;
  tester.platformDispatcher.textScaleFactorTestValue = systemText;
  tester.platformDispatcher.alwaysUse24HourFormatTestValue = use24h;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  // Desmonta lo anterior: si no, el Navigator conserva las hojas abiertas de un montaje previo.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(BatteryApp(state: state));
  await tester.pumpAndSettle();
}

/// Guarda una captura de toda la pantalla en `screenshots/<name>.png`.
Future<void> saveScreenshot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final rv = tester.binding.renderViews.first;
    final layer = rv.debugLayer! as OffsetLayer;
    final image = await layer.toImage(Offset.zero & tester.view.physicalSize, pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final f = File('screenshots/$name.png');
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Desplaza la pantalla principal hasta el final, de a poco, devolviendo los errores de dibujo.
Future<void> scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 12; i++) {
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}
