// Regresiones de lo que encontró el QA en emuladores (apps/android/QA.md).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/app/platform_info.dart';
import 'package:battery_calculator/ui/theme/app_colors.dart';
import 'package:battery_calculator/ui/theme/app_theme.dart';
import 'package:battery_calculator/ui/widgets/fields.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../contrast_test.dart' show ratio;
import 'harness.dart';

void main() {
  group('selector de hora', () {
    test('la fuente Material Icons va en el APK (el botón del teclado no sale como cuadro)', () {
      // Sin ella, Icons.keyboard_outlined del selector se veía como ☒ en el emulador.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(RegExp(r'^\s*uses-material-design:\s*true', multiLine: true).hasMatch(pubspec), isTrue);
    });

    for (final dark in [false, true]) {
      testWidgets('Cancelar/Aceptar y a. m./p. m. con colores de la app (${dark ? 'oscuro' : 'claro'})', (
        tester,
      ) async {
        final c = dark ? AppColors.dark : AppColors.light;
        final s = stateWithBattery(theme: dark ? ThemePref.dark : ThemePref.light);
        await pumpApp(tester, s);
        final sun = find.text('Hora en que vuelve el sol');
        await tester.ensureVisible(sun);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(TimeField).last);
        await tester.pumpAndSettle();
        expect(find.byType(TimePickerDialog), findsOneWidget);

        final ml = MaterialLocalizations.of(tester.element(find.byType(TimePickerDialog)));
        for (final label in [ml.cancelButtonLabel, ml.okButtonLabel]) {
          final text = tester.widget<Text>(find.text(label));
          final style = DefaultTextStyle.of(tester.element(find.text(label))).style.merge(text.style);
          expect(ratio(style.color!, c.sf), greaterThanOrEqualTo(4.5), reason: '$label sobre el fondo del diálogo');
        }
        final theme = Theme.of(tester.element(find.byType(TimePickerDialog))).timePickerTheme;
        final selected = theme.dayPeriodColor is WidgetStateColor
            ? (theme.dayPeriodColor! as WidgetStateColor).resolve({WidgetState.selected})
            : theme.dayPeriodColor;
        expect(selected, c.amb, reason: 'a. m./p. m. elegido en ámbar, no en el azul de info');
        final onSel = (theme.dayPeriodTextColor! as WidgetStateColor).resolve({WidgetState.selected});
        expect(ratio(onSel, c.amb), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('campo de porciento de 100 dp', () {
    // El valor cabe sin desplazarse dentro del campo (antes «100 %» se veía «|00» con letra grande).
    for (final (scale, error) in [(1.0, false), (1.2, false), (1.2, true), (1.56, false), (1.56, true)]) {
      testWidgets('«100» cabe con letra ×$scale${error ? ' y error' : ''}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(AppColors.light, Brightness.light),
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 100,
                    child: NumberField(value: '100', unit: '%', center: true, showError: error, onChanged: (_) {}),
                  ),
                ),
              ),
            ),
          ),
        );
        final editable = tester.renderObject<RenderBox>(find.byType(EditableText));
        final ctx = tester.element(find.byType(EditableText));
        final tp = TextPainter(
          text: TextSpan(text: '100', style: AppText.fieldValue),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(ctx),
        )..layout();
        // +2: el cursor.
        expect(tp.width + 2, lessThanOrEqualTo(editable.size.width), reason: 'el texto no cabe en el campo');
        tp.dispose();
      });
    }
  });

  group('nombre de los campos para TalkBack', () {
    tearDown(() => androidSdkInt = 0);

    for (final sdk in [24, 27, 28, 36]) {
      testWidgets('API $sdk: «Consumo de la casa» llega a TalkBack', (tester) async {
        androidSdkInt = sdk;
        final handle = tester.ensureSemantics();
        await pumpApp(tester, stateWithBattery());
        final field = find.byType(TextField).at(1);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        final node = tester.getSemantics(field);
        final label = RegExp(r'Consumo de la casa');
        if (sdk < 28) {
          // El motor solo pasa el valor del campo: el nombre va en el nodo padre, que no es campo.
          expect(node.label, isEmpty);
          final parent = node.parent!;
          expect(parent.label, matches(label));
          expect(parent.flagsCollection.isTextField, isFalse);
        } else {
          expect(node.label, matches(label), reason: 'API 28+: el nombre va en el propio campo (hint)');
        }
        handle.dispose();
      });
    }
  });

  group('guardar en la galería', () {
    late List<String> calls;
    setUp(() {
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('gal'),
        (call) async {
          calls.add(call.method);
          return switch (call.method) {
            'hasPermission' || 'requestPermission' => false,
            _ => null,
          };
        },
      );
    });
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('gal'),
        null,
      ),
    );

    testWidgets('sin permiso: lo pide una sola vez y avisa, sin intentar guardar', (tester) async {
      await pumpApp(tester, stateWithBattery());
      await tester.ensureVisible(find.text('Compartir resultado'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compartir resultado'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar en el teléfono'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls.where((m) => m == 'requestPermission'), hasLength(1));
      expect(calls, isNot(contains('putImageBytes')));
      final toast = find.textContaining('permite el acceso a fotos y archivos');
      expect(toast, findsOneWidget);
      // El aviso se ve encima de la hoja (antes el SnackBar quedaba debajo, tapado).
      final hit = tester.hitTestOnBinding(tester.getCenter(toast));
      expect(hit.path.any((e) => e.target == tester.renderObject(toast)), isTrue, reason: 'aviso tapado');
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('ícono de Android 7 (PNG, sin adaptativo)', () {
    test('el manifiesto declara roundIcon y hay versión adaptativa', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('android:roundIcon="@mipmap/ic_launcher_round"'));
      expect(File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml').existsSync(), isTrue);
    });

    testWidgets('los PNG tienen margen transparente (Lint IconLauncherShape)', (tester) async {
      for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        for (final name in ['ic_launcher', 'ic_launcher_round']) {
          final bytes = File('android/app/src/main/res/mipmap-$d/$name.png').readAsBytesSync();
          final data = await tester.runAsync(() async {
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            final w = frame.image.width;
            final rgba = await frame.image.toByteData();
            frame.image.dispose();
            return (w, rgba!);
          });
          final (w, rgba) = data!;
          int alpha(int x, int y) => rgba.getUint8((y * w + x) * 4 + 3);
          expect(alpha(0, 0), 0, reason: '$d/$name: esquina');
          expect(alpha(w ~/ 2, w ~/ 2), 255, reason: '$d/$name: centro');
        }
      }
    });
  });
}
