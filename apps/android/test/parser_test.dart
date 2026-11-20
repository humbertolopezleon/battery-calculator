import 'package:battery_calculator/domain/number_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vacío e inválido', () {
    expect(parseNumber('  ').empty, isTrue);
    expect(parseNumber('abc').isNumber, isFalse);
    expect(parseNumber('1,2,3').isNumber, isFalse);
    expect(parseNumber('-5').isNumber, isFalse);
  });
  test('coma o punto decimal, y puntas sueltas', () {
    expect(parseNumber('10,24').value, 10.24);
    expect(parseNumber('10.24').value, 10.24);
    expect(parseNumber(',5').value, 0.5);
    expect(parseNumber('5.').value, 5);
  });
  test('lectura de miles solo en W, Ah y A', () {
    final p = parseNumber('25.000', thousands: true, decimalSep: ',');
    expect(p.value, 25000);
    expect(p.readAsThousands, isTrue);
    expect(p.alt, '25');
    expect(p.sepIsDot, isTrue);
    final c = parseNumber('1,500', thousands: true, decimalSep: '.');
    expect(c.value, 1500);
    expect(c.alt, '1.5');
    expect(c.sepIsDot, isFalse);
    expect(parseNumber('1.250', thousands: true).alt, '1,25');
    expect(parseNumber('25.000').value, 25);
    expect(parseNumber('25.00', thousands: true).readAsThousands, isFalse);
  });
  test('filtro de caracteres y largo máximo', () {
    expect(filterNumberInput('6a0-0 W'), '600');
    expect(filterNumberInput('1234567890123456'), '123456789012');
    expect(filterNumberInput('10,5'), '10,5');
  });
}
