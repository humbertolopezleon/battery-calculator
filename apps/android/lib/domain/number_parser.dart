/// Lectura de números escritos por la persona (SPEC §5).
library;

/// Resultado de leer un campo numérico.
class ParsedNumber {
  const ParsedNumber._(this.value, {this.empty = false, this.alt, this.sepIsDot = false});

  /// Campo vacío (o solo espacios).
  const ParsedNumber.empty() : this._(double.nan, empty: true);

  /// Texto que no es un número.
  const ParsedNumber.invalid() : this._(double.nan);

  const ParsedNumber.number(double v) : this._(v);

  /// «25.000» leído como 25000. [alt] es la otra lectura («25,000» → 25 coma 000).
  const ParsedNumber.thousands(double v, String this.alt, {required this.sepIsDot}) : empty = false, value = v;

  final double value;
  final bool empty;

  /// Solo cuando se leyó con separador de miles: cómo se escribe la lectura alternativa.
  final String? alt;

  /// El separador que escribió la persona era un punto (si no, una coma).
  final bool sepIsDot;

  bool get isNumber => !value.isNaN;
  bool get readAsThousands => alt != null;
}

final _onlyNumberChars = RegExp(r'^[\d.,]+$');
final _thousands = RegExp(r'^(\d{1,3})[.,](\d{3})$');
final _seps = RegExp(r'[.,]');
final _notAllowed = RegExp(r'[^\d.,]');

/// Lee [raw]. Con [thousands] (campos W, Ah y A) «25.000» se entiende como 25000.
/// [decimalSep] es el separador decimal del idioma, para escribir la lectura alternativa.
ParsedNumber parseNumber(String raw, {bool thousands = false, String decimalSep = ','}) {
  final s = raw.trim();
  if (s.isEmpty) return const ParsedNumber.empty();
  if (!_onlyNumberChars.hasMatch(s)) return const ParsedNumber.invalid();
  final m = _thousands.firstMatch(s);
  if (m != null && thousands) {
    // La otra lectura, como número decimal y sin ceros sobrantes (SPEC §5): «25.000» → «25», «1.500» → «1,5».
    final frac = m[2]!.replaceFirst(RegExp(r'0+$'), '');
    return ParsedNumber.thousands(
      double.parse('${m[1]}${m[2]}'),
      frac.isEmpty ? m[1]! : '${m[1]}$decimalSep$frac',
      sepIsDot: s.contains('.'),
    );
  }
  if (_seps.allMatches(s).length > 1) return const ParsedNumber.invalid();
  var t = s.replaceFirst(',', '.');
  if (t.startsWith('.')) t = '0$t';
  if (t.endsWith('.')) t = '${t}0';
  return ParsedNumber.number(double.parse(t));
}

/// Largo máximo de lo que se puede escribir en un campo numérico.
const maxNumberLength = 12;

/// Quita lo que no sea dígito, punto o coma, y recorta a [maxNumberLength].
/// Devuelve el texto filtrado; si cambió, la UI muestra «Solo se pueden escribir números.».
String filterNumberInput(String s) {
  final n = s.replaceAll(_notAllowed, '');
  return n.length > maxNumberLength ? n.substring(0, maxNumberLength) : n;
}
