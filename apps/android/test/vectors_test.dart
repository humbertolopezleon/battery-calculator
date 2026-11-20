// Los 20 casos de design/handoff/docs/test-vectors.json (SPEC §9): el contrato de la lógica.
// Se leen directamente de esa ruta, sin copiarlos. Idioma es, reloj de 24 h, como el prototipo.
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:battery_calculator/app/presenter.dart';
import 'package:battery_calculator/domain/calculator.dart';
import 'package:battery_calculator/domain/formatters.dart';
import 'package:battery_calculator/domain/number_parser.dart';
import 'package:battery_calculator/l10n/gen/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const vectorsPath = '../../design/handoff/docs/test-vectors.json';

void main() {
  final file = File(vectorsPath);
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final night = (data['night'] as List).cast<Map<String, dynamic>>();
  final chargeCases = (data['charge'] as List).cast<Map<String, dynamic>>();
  final f = Fmt(lookupAppLocalizations(const Locale('es')), use24h: true);

  test('el archivo tiene 12 casos de noche y 8 de carga', () {
    expect(night, hasLength(12));
    expect(chargeCases, hasLength(8));
  });

  String s(Object? v) => v?.toString() ?? '';

  group('De noche', () {
    for (final (i, c) in night.indexed) {
      final inp = c['input'] as Map<String, dynamic>;
      final exp = c['expected_es'] as Map<String, dynamic>;
      test('caso ${i + 1}: ${inp['percentNow']}% · ${inp['loadW']} W · ${inp['timeNow']}→${inp['sunrise']}', () {
        final r = nightCalc(
          NightInput(
            cap: parseNumber(s(inp['capacityKwh'])).value,
            pctTxt: s(inp['percentNow']),
            loadTxt: s(inp['loadW']),
            reserveTxt: s(inp['reservePct']),
            loss: inp['countInverterLoss'] as bool,
            now: parseClock(inp['timeNow'] as String?),
            sun: parseClock(inp['sunrise'] as String?),
          ),
        );
        final v = presentNight(r, f);
        expect(v.lead, exp['lead'], reason: 'lead');
        expect(v.big, exp['big'], reason: 'big');
        expect(v.card == null ? null : '${v.card!.title}${v.card!.text}', exp['card'], reason: 'card');
        expect(v.verdictFlat, exp['verdict'], reason: 'verdict');
        expect(v.figures.map((e) => '$e').toList(), exp['figures'], reason: 'figures');
        expect(v.steps, exp['steps'], reason: 'steps');
      });
    }
  });

  group('Cargando con la red', () {
    for (final (i, c) in chargeCases.indexed) {
      final inp = c['input'] as Map<String, dynamic>;
      final exp = c['expected_es'] as Map<String, dynamic>;
      test('caso ${i + 1}: ${inp['percentNow']}→${inp['chargeTo']}% · ${inp['powerMode']}', () {
        final mode = inp['powerMode'] == 'a' ? PowerMode.amps : PowerMode.watts;
        final r = chargeCalc(
          ChargeInput(
            cap: parseNumber(s(inp['capacityKwh'])).value,
            pctTxt: s(inp['percentNow']),
            targetTxt: s(inp['chargeTo']),
            mode: mode,
            wattsTxt: s(inp['watts']),
            ampsTxt: s(inp['amps']),
            voltsTxt: s(inp['volts']),
            now: parseClock(inp['timeNow'] as String?),
          ),
        );
        final v = presentCharge(r, f, mode: mode);
        expect(v.lead, exp['lead'], reason: 'lead');
        expect(v.big, exp['big'], reason: 'big');
        expect(v.sub, exp['sub'], reason: 'sub');
        expect(v.card == null ? null : '${v.card!.title}${v.card!.text}', exp['card'], reason: 'card');
        expect(v.gridTitle == null ? null : '${v.gridTitle}${v.gridText}', exp['grid'], reason: 'grid');
        expect(v.legend?.join(), exp['legend'], reason: 'legend');
        expect(v.figures.map((e) => '$e').toList(), exp['figures'], reason: 'figures');
        expect(v.steps, exp['steps'], reason: 'steps');
      });
    }
  });
}
