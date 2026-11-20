// Flujos de la pestaña Duración (SPEC §4.5 y §6, DESIGN §3.0).
import 'package:battery_calculator/app/app_state.dart';
import 'package:battery_calculator/app/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

const _nb = ' ';

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('la pestaña con la que abre', () {
    test('la primera vez es Duración', () {
      expect(AppState(MemoryStore(), clock: fixedClock).tab, AppTab.runtime);
    });

    test('quien ya usaba la app sigue en su pestaña', () async {
      for (final t in ['night', 'charge']) {
        final s = AppState(MemoryStore({'cap': 10.24, 'tab': t}), clock: fixedClock);
        await s.load();
        expect(s.tab.name, t);
      }
    });

    test('datos guardados sin pestaña: Duración', () async {
      final s = AppState(MemoryStore({'cap': 10.24}), clock: fixedClock);
      await s.load();
      expect(s.tab, AppTab.runtime);
    });
  });

  group('las horas', () {
    test('el inicio es la hora actual y no se guarda; el fin sí se guarda', () async {
      final store = MemoryStore();
      final s = AppState(store, clock: fixedClock)..cap = 10.24;
      expect(s.rFrom, '21:00');
      expect(s.rTo, '');
      s.update(
        (s) => s
          ..rFrom = '18:30'
          ..rTo = '02:00',
      );
      expect(store.data!.containsKey('rFrom'), isFalse);
      expect(store.data!['rTo'], '02:00');

      final again = AppState(store, clock: fixedClock);
      await again.load();
      expect(again.rFrom, '21:00', reason: 'al abrir, la hora actual');
      expect(again.rTo, '02:00');
    });

    test('«Borrar mis datos» quita la hora de fin', () async {
      final s = AppState(MemoryStore(), clock: fixedClock)..rTo = '02:00';
      await s.reset();
      expect(s.rTo, '');
      expect(s.tab, AppTab.runtime);
    });
  });

  testWidgets('sin hora de fin: duración y hora en que se acaba, sin veredicto', (tester) async {
    await pumpApp(tester, stateWithBattery(tab: AppTab.runtime));
    expect(find.text('Duración · 600 W de consumo'), findsOneWidget);
    expect(find.text('La batería dura'), findsOneWidget);
    expect(find.text('12 h 8 min'), findsOneWidget);
    expect(
      find.text('Empezando a las 9:00${_nb}p.${_nb}m., se acaba cerca de las 9:08${_nb}a.${_nb}m.'),
      findsOneWidget,
    );
    expect(find.textContaining('Alcanza'), findsNothing);
    expect(find.text('Sin hora de fin'), findsOneWidget);
    expect(find.bySemanticsLabel('Quitar la hora de fin'), findsNothing);
  });

  testWidgets('con hora de fin: «Probar con» cambia el consumo y la X quita el fin', (tester) async {
    final s = stateWithBattery(tab: AppTab.runtime)
      ..nW = '1500'
      ..rTo = '06:00';
    await pumpApp(tester, s);
    expect(find.text('No alcanza hasta las 6:00${_nb}a.${_nb}m.'), findsOneWidget);

    await _tapVisible(tester, find.text('Probar con 800 W'));
    expect(s.nW, '800');
    expect(find.text('Alcanza hasta las 6:00${_nb}a.${_nb}m.'), findsOneWidget);

    await _tapVisible(tester, find.bySemanticsLabel('Quitar la hora de fin'));
    expect(s.rTo, '');
    expect(find.textContaining('Alcanza'), findsNothing);
    expect(find.text('Sin hora de fin'), findsOneWidget);
  });

  testWidgets('el selector de la hora de fin abre en la hora de inicio', (tester) async {
    final s = stateWithBattery(tab: AppTab.runtime)..rFrom = '18:45';
    await pumpApp(tester, s);
    await _tapVisible(tester, find.bySemanticsLabel(RegExp('^Hasta qué hora')));
    final ml = MaterialLocalizations.of(tester.element(find.byType(TimePickerDialog)));
    await tester.tap(find.text(ml.okButtonLabel));
    await tester.pumpAndSettle();
    expect(s.rTo, '18:45');
  });

  testWidgets('«Ahora» vuelve el inicio a la hora actual', (tester) async {
    final s = stateWithBattery(tab: AppTab.runtime)..rFrom = '18:45';
    await pumpApp(tester, s);
    expect(
      find.text('Empezando a las 6:45${_nb}p.${_nb}m., se acaba cerca de las 6:53${_nb}a.${_nb}m.'),
      findsOneWidget,
    );
    await _tapVisible(tester, find.text('Ahora'));
    expect(s.rFrom, '21:00');
  });

  testWidgets('el porciento, el consumo y la reserva se comparten con De noche', (tester) async {
    final s = stateWithBattery(tab: AppTab.runtime);
    await pumpApp(tester, s);
    final load = find.byWidgetPredicate((w) => w is TextField && w.controller?.text == '600');
    await tester.ensureVisible(load);
    await tester.enterText(load, '300');
    await tester.pumpAndSettle();
    expect(s.nW, '300');
    await tester.tap(find.text('De noche'));
    await tester.pumpAndSettle();
    expect(s.tab, AppTab.night);
    expect(find.text('De noche · 300 W de consumo'), findsOneWidget);
    await tester.tap(find.text('Duración'));
    await tester.pumpAndSettle();
    expect(find.text('Duración · 300 W de consumo'), findsOneWidget);
  });

  testWidgets('barra inferior: Duración es la primera pestaña', (tester) async {
    await pumpApp(tester, stateWithBattery(tab: AppTab.runtime));
    final xs = [
      'Duración',
      'De noche',
      'Cargando con la red',
    ].map((t) => tester.getCenter(find.text(t).last).dx).toList();
    expect(xs[0] < xs[1] && xs[1] < xs[2], isTrue);
  });

  testWidgets('vacío: pide el consumo', (tester) async {
    await pumpApp(tester, stateWithBattery(tab: AppTab.runtime)..nW = '');
    expect(find.text('Falta el consumo de la casa'), findsOneWidget);
    expect(find.text('Escríbelo abajo y aquí verás cuánto te dura la batería.'), findsOneWidget);
  });
}
