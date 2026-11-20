// Los 12 casos de design/handoff/docs/test-vectors-runtime.json (SPEC §4.5 y §9): el contrato del modo Duración.
// Se leen de esa ruta, sin copiarlos. Idioma es, reloj de 24 h.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:battery_calculator/app/presenter.dart';
import 'package:battery_calculator/domain/calculator.dart';
import 'package:battery_calculator/domain/formatters.dart';
import 'package:battery_calculator/domain/number_parser.dart';
import 'package:battery_calculator/l10n/gen/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const runtimeVectorsPath = '../../design/handoff/docs/test-vectors-runtime.json';

NightResult runtimeFromVector(Map<String, dynamic> inp) {
  String s(Object? v) => v?.toString() ?? '';
  return runtimeCalc(
    RuntimeInput(
      cap: parseNumber(s(inp['capacityKwh'])).value,
      pctTxt: s(inp['percentNow']),
      loadTxt: s(inp['loadW']),
      reserveTxt: s(inp['reservePct']),
      loss: inp['countInverterLoss'] as bool,
      start: parseClock(inp['startTime'] as String?),
      end: parseClock(inp['endTime'] as String?),
    ),
  );
}

void main() {
  final data = jsonDecode(File(runtimeVectorsPath).readAsStringSync()) as Map<String, dynamic>;
  final cases = (data['runtime'] as List).cast<Map<String, dynamic>>();
  final f = Fmt(lookupAppLocalizations(const Locale('es')), use24h: true);

  test('el archivo tiene 12 casos de Duración', () => expect(cases, hasLength(12)));

  group('Duración', () {
    for (final (i, c) in cases.indexed) {
      final exp = c['expected_es'] as Map<String, dynamic>;
      test('caso ${i + 1}: ${c['name']}', () {
        final v = presentRuntime(runtimeFromVector(c['input'] as Map<String, dynamic>), f);
        expect(v.lead, exp['lead'], reason: 'lead');
        expect(v.big, exp['big'], reason: 'big');
        expect(v.sub, exp['sub'], reason: 'sub');
        expect(v.card == null ? null : '${v.card!.title}${v.card!.text}', exp['card'], reason: 'card');
        expect(v.verdictFlat, exp['verdict'], reason: 'verdict');
        expect(v.figures.map((e) => '$e').toList(), exp['figures'], reason: 'figures');
        expect(v.steps, exp['steps'], reason: 'steps');
        final strip = v.strip.tag == null ? v.strip.text : '${v.strip.text} · ${v.strip.tag}';
        expect(strip, exp['strip'], reason: 'strip');
      });
    }
  });

  group('Duración: regla y leyenda', () {
    test('si alcanza, el fin va después de la bandera', () {
      final v = presentRuntime(runtimeFromVector((cases[1]['input'] as Map).cast()), f);
      expect(v.legend!.map((e) => e.label).toList(), ['Inicio', 'Hasta', 'Se acaba']);
      expect(v.legend!.map((e) => e.value).toList(), ['21:00', '2:00', '9:08']);
      expect(v.r.track!.endBeforeSun, isFalse);
    });
    test('si no alcanza, se acaba antes de la bandera', () {
      final v = presentRuntime(runtimeFromVector((cases[2]['input'] as Map).cast()), f);
      expect(v.legend!.map((e) => e.label).toList(), ['Inicio', 'Se acaba', 'Hasta']);
      expect(v.tryW, 800);
    });
    test('sin hora de fin no hay regla ni veredicto', () {
      final v = presentRuntime(runtimeFromVector((cases[0]['input'] as Map).cast()), f);
      expect(v.legend, isNull);
      expect(v.r.track, isNull);
    });
  });

  test('en inglés y con reloj de 12 h', () {
    final en = Fmt(lookupAppLocalizations(const Locale('en')), use24h: false);
    final v = presentRuntime(runtimeFromVector((cases[2]['input'] as Map).cast()), en);
    expect(v.lead, 'Your battery lasts');
    expect(v.big, '4 h 51 min');
    expect(v.sub, 'Starting at 9:00\u00a0PM, it runs out around 1:51\u00a0AM');
    expect(v.verdictTitle, 'Won’t last until 6:00\u00a0AM');
    expect(v.figures.map((e) => '$e').toList(), ['7.28 kWhyou can use', '≈ 16%used per hour', '92 Whusable per 1%']);
  });

  test('De noche no cambia: misma cuenta con el sol', () {
    final inp = (cases[1]['input'] as Map).cast<String, dynamic>();
    final rt = runtimeFromVector(inp);
    final night = nightCalc(
      NightInput(
        cap: 10.24,
        pctTxt: '85',
        loadTxt: '600',
        reserveTxt: '6',
        loss: true,
        now: parseClock('21:00'),
        sun: parseClock('02:00'),
      ),
    );
    expect(rt.usable, night.usable);
    expect(rt.hours, night.hours);
    expect(rt.verdict!.left, night.verdict!.left);
  });
}
