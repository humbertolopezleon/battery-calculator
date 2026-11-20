import 'package:battery_calculator/domain/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const es = NumberFormatter('es');
  const en = NumberFormatter('en');

  group('nf', () {
    test('separador decimal por idioma y sin miles', () {
      expect(es.nf(10.24, 2), '10,24');
      expect(en.nf(10.24, 2), '10.24');
      expect(es.nf(25000, 2), '25000');
    });
    test('quita ceros a la derecha', () {
      expect(es.nf(4.1, 2), '4,1');
      expect(es.nf(15, 3), '15');
      expect(es.nf(8.0896, 3), '8,09');
    });
    test('redondea mitad hacia arriba sobre la forma decimal corta', () {
      expect(es.nf(1.005, 2), '1,01');
      expect(es.nf(0.125, 2), '0,13');
      expect(es.nf(2.5, 0), '3');
      expect(es.nf(9.995, 2), '10');
    });
    test('negativos, cero y números muy pequeños', () {
      expect(es.nf(-1.5, 1), '-1,5');
      expect(es.nf(-0.0001, 2), '0');
      expect(es.nf(1e-7, 2), '0');
      expect(es.nf(double.infinity, 2), '∞');
    });
  });

  group('energía', () {
    test('q(): Wh por debajo de 0,1 kWh', () {
      expect(es.q(0.0467), '46,7 Wh');
      expect(es.q(0.005), '5 Wh');
      expect(es.q(0.0012), '1,2 Wh');
      expect(es.q(1.2839), '1,28 kWh');
    });
    test('b3() y potencia', () {
      expect(es.b3(7.2811), '7,281 kWh');
      expect(es.power(0.3), '300 W');
      expect(es.power(1.25), '1,25 kW');
    });
  });

  group('dur', () {
    String days(String d) => d == '1' ? 'cerca de 1 día' : 'unos $d días';
    String dur(double h) => formatDuration(h, es, days);
    test('horas y minutos', () {
      expect(dur(12 + 8 / 60), '12 h 8 min');
      expect(dur(4), '4 h');
      expect(dur(17 / 60), '17 min');
      expect(dur(0), '0 min');
    });
    test('días desde 24 h redondeadas', () {
      expect(dur(23.999), 'cerca de 1 día');
      expect(dur(31.4), 'unos 1,3 días');
      expect(dur(1410), 'unos 59 días');
      expect(dur(24 * 12.3), 'unos 12 días');
    });
    test('infinito', () => expect(dur(double.infinity), '∞'));
  });

  group('horas', () {
    test('es, 24 h: sin cero delante', () {
      const t = TimeFormatter('es', use24h: true);
      expect(t.format(9 * 60 + 8), '9:08');
      expect(t.format(21 * 60 + 17), '21:17');
      expect(t.format(1440 + 46), '0:46');
      expect(t.withArticle(13 * 60 + 31), 'las 13:31');
      expect(t.withArticle(60 + 5), 'la 1:05');
    });
    test('es, 12 h: a. m. / p. m. y el artículo usa la hora de 12', () {
      const t = TimeFormatter('es', use24h: false);
      expect(t.format(9 * 60 + 8), '9:08 a. m.');
      expect(t.format(13 * 60 + 31), '1:31 p. m.');
      expect(t.format(0), '12:00 a. m.');
      expect(t.article(13 * 60 + 31), 'la ');
      expect(t.article(14 * 60), 'las ');
    });
    test('en', () {
      expect(const TimeFormatter('en', use24h: false).format(21 * 60), '9:00 PM');
      expect(const TimeFormatter('en', use24h: true).format(7 * 60), '07:00');
      expect(const TimeFormatter('en', use24h: false).article(60), '');
    });
    test('parseClock y clockString', () {
      expect(parseClock('07:30'), 450);
      expect(parseClock(null), isNull);
      expect(parseClock('x'), isNull);
      expect(clockString(1500), '01:00');
    });
  });
}
