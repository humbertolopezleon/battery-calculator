/// Formatos de números, duraciones y horas (SPEC §4.6).
library;

/// Formatea números según el idioma: separador decimal propio y sin separador de miles.
class NumberFormatter {
  const NumberFormatter(this.lang);

  /// 'es' o 'en'.
  final String lang;

  String get decimalSep => lang == 'es' ? ',' : '.';

  /// Como `toLocaleString` con `maximumFractionDigits: d` y sin agrupar:
  /// redondeo «mitad hacia arriba» sobre la representación decimal más corta.
  String nf(double x, int d) {
    if (x.isNaN) return 'NaN';
    if (x.isInfinite) return x > 0 ? '∞' : '-∞';
    final neg = x < 0;
    final s = _roundDecimal(x.abs(), d);
    final out = s == '0' ? s : (neg ? '-$s' : s);
    return out.replaceFirst('.', decimalSep);
  }

  static String _roundDecimal(double v, int d) {
    var str = v.toString();
    if (str.contains('e')) str = v.toStringAsFixed(20);
    final parts = str.split('.');
    final intPart = parts[0];
    final frac = parts.length > 1 ? parts[1] : '';
    if (frac.length <= d) return _trim(intPart, frac);
    final up = frac.codeUnitAt(d) >= 0x35; // '5'
    var digits = BigInt.parse(intPart + frac.substring(0, d));
    if (up) digits += BigInt.one;
    final ds = digits.toString().padLeft(d + 1, '0');
    final ip = ds.substring(0, ds.length - d);
    final fp = ds.substring(ds.length - d);
    return _trim(ip, fp);
  }

  static String _trim(String ip, String fp) {
    final f = fp.replaceFirst(RegExp(r'0+$'), '');
    return f.isEmpty ? ip : '$ip.$f';
  }

  /// kWh con hasta [d] decimales.
  String kwh(double x, [int d = 2]) => '${nf(x, d)} kWh';

  /// Wh con 0, 1 o 2 decimales según el tamaño.
  String wh(double kwhValue) {
    final w = kwhValue * 1000;
    return '${nf(w, w >= 100
        ? 0
        : w >= 10
        ? 1
        : 2)} Wh';
  }

  /// `q()`: menos de 0,1 kWh en Wh; si no, kWh con 2 decimales.
  String q(double x) => x < 0.1 ? wh(x) : kwh(x);

  /// Como [q] pero con hasta 3 decimales en kWh (paso a paso).
  String b3(double x) => x < 0.1 ? wh(x) : '${nf(x, 3)} kWh';

  /// Potencia en kW con hasta 3 decimales, o en W si es menor que 1 kW.
  String power(double kw) => kw < 1 ? '${nf(kw * 1000, 2)} W' : '${nf(kw, 3)} kW';
}

/// ¿La duración [h] (horas) se expresa en días?
bool isDays(double h) => h.isFinite && (h * 60).round() >= 1440;

/// `dur(h)`: «X h Y min», «unos N días» o «∞».
/// [daysText] recibe N ya formateado y devuelve la frase («unos 59 días» / «cerca de 1 día»).
String formatDuration(double h, NumberFormatter f, String Function(String n) daysText) {
  if (!h.isFinite) return '∞';
  if (isDays(h)) {
    final d = h / 24;
    return daysText(f.nf(d, d < 10 ? 1 : 0));
  }
  final m = (h * 60).round();
  final a = m ~/ 60;
  final b = m % 60;
  if (a == 0) return '$b min';
  return b == 0 ? '$a h' : '$a h $b min';
}

const _nbsp = ' ';

/// Formatea horas del día. Sigue el ajuste 12/24 h del teléfono.
class TimeFormatter {
  const TimeFormatter(this.lang, {required this.use24h});

  final String lang;
  final bool use24h;

  static int _norm(num mins) => ((mins.round() % 1440) + 1440) % 1440;

  /// [mins]: minutos desde la medianoche (puede pasar de 1440).
  String format(num mins) {
    final m = _norm(mins);
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    if (use24h) {
      return lang == 'es' ? '$h:$mm' : '${h.toString().padLeft(2, '0')}:$mm';
    }
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final pm = h >= 12;
    if (lang == 'es') return '$h12:$mm$_nbsp${pm ? 'p.${_nbsp}m.' : 'a.${_nbsp}m.'}';
    return '$h12:$mm$_nbsp${pm ? 'PM' : 'AM'}';
  }

  /// Artículo español delante de la hora: «la 1:31», «las 2:30». En inglés, vacío.
  String article(num mins) {
    if (lang != 'es') return '';
    final h = _norm(mins) ~/ 60;
    final shown = use24h ? h : (h % 12 == 0 ? 12 : h % 12);
    return shown == 1 ? 'la ' : 'las ';
  }

  /// Hora con su artículo: «las 7:00».
  String withArticle(num mins) => '${article(mins)}${format(mins)}';
}

/// «HH:mm» → minutos desde la medianoche, o null.
int? parseClock(String? v) {
  if (v == null || v.isEmpty) return null;
  final p = v.split(':');
  if (p.length != 2) return null;
  final a = int.tryParse(p[0]);
  final b = int.tryParse(p[1]);
  return a == null || b == null ? null : a * 60 + b;
}

/// Minutos → «HH:mm» (para guardar).
String clockString(int mins) {
  final m = ((mins % 1440) + 1440) % 1440;
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}
