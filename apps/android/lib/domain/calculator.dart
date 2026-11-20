/// Fórmulas de la calculadora (SPEC §3 y §4). Funciones puras: sin Flutter.
library;

import 'dart:math' as math;

import 'formatters.dart' show isDays;
import 'number_parser.dart';

// ---- Constantes (SPEC §3) ----
const reserveDefault = 6.0;
const reserveMin = 0.0;
const reserveMax = 90.0;
const lossFactor = 0.9;
const slowFrom = 90.0;
const weirdPowerW = 10000.0;
const weirdCapacityKwh = 100.0;

/// Tipo de mensaje junto a un campo.
enum MsgKind { err, warn, info }

/// Qué dice el mensaje. La UI lo convierte en texto.
enum MsgCode { numBad, gt0, pctBad, tgtBad, rsvBad, weird, readAs, ampsResult }

/// Mensaje de un campo. [parsed] trae los datos de la lectura de miles; [value], la potencia en modo A.
class FieldMsg {
  const FieldMsg(this.kind, this.code, {this.parsed, this.value});
  final MsgKind kind;
  final MsgCode code;
  final ParsedNumber? parsed;
  final double? value;

  @override
  bool operator ==(Object other) =>
      other is FieldMsg && other.kind == kind && other.code == code && other.value == value;
  @override
  int get hashCode => Object.hash(kind, code, value);
}

// =====================================================================
// Batería
// =====================================================================

enum BatteryMode { kwh, voltsAh }

enum BatteryField { cap, volts, ah }

class BatteryResult {
  const BatteryResult({this.cap, this.empty = false, this.errField, this.errCode, this.warnField, this.ahParsed});
  final double? cap;
  final bool empty;
  final BatteryField? errField;
  final MsgCode? errCode;
  final BatteryField? warnField;
  final ParsedNumber? ahParsed;
  bool get ok => cap != null;
}

/// `batCalc()`: capacidad a partir de lo escrito en la hoja de batería.
BatteryResult batteryCapacity({
  required BatteryMode mode,
  required String capTxt,
  required String voltsTxt,
  required String ahTxt,
  String decimalSep = ',',
}) {
  if (mode == BatteryMode.kwh) {
    final p = parseNumber(capTxt);
    if (p.empty) return const BatteryResult(empty: true);
    if (!(p.value > 0)) {
      return BatteryResult(errField: BatteryField.cap, errCode: p.isNumber ? MsgCode.gt0 : MsgCode.numBad);
    }
    return BatteryResult(cap: p.value, warnField: p.value > weirdCapacityKwh ? BatteryField.cap : null);
  }
  final v = parseNumber(voltsTxt);
  final a = parseNumber(ahTxt, thousands: true, decimalSep: decimalSep);
  if (v.empty || a.empty) return const BatteryResult(empty: true);
  if (!(v.value > 0)) {
    return BatteryResult(errField: BatteryField.volts, errCode: v.isNumber ? MsgCode.gt0 : MsgCode.numBad);
  }
  if (!(a.value > 0)) {
    return BatteryResult(errField: BatteryField.ah, errCode: a.isNumber ? MsgCode.gt0 : MsgCode.numBad);
  }
  final c = v.value * a.value / 1000;
  return BatteryResult(cap: c, warnField: c > weirdCapacityKwh ? BatteryField.ah : null, ahParsed: a);
}

// =====================================================================
// De noche (SPEC §4.2)
// =====================================================================

enum NightField { pct, load, reserve }

enum NightState { empty, fix, inReserve, noLoad, ok }

class NightInput {
  const NightInput({
    required this.cap,
    required this.pctTxt,
    required this.loadTxt,
    required this.reserveTxt,
    required this.loss,
    required this.now,
    required this.sun,
    this.decimalSep = ',',
  });
  final double cap;
  final String pctTxt, loadTxt, reserveTxt;
  final bool loss;

  /// Minutos desde la medianoche; null si falta.
  final int? now, sun;
  final String decimalSep;
}

/// Veredicto: ¿llega al amanecer?
class NightVerdict {
  const NightVerdict.ok({required this.left, required this.pctAtDawn}) : reaches = true, short = 0, maxW = 0;
  const NightVerdict.bad({required this.short, required this.maxW}) : reaches = false, left = 0, pctAtDawn = 0;
  final bool reaches;
  final double left;
  final int pctAtDawn;
  final double short;
  final int maxW;
}

/// Regla de la noche (en porciento del ancho).
class NightTrackGeometry {
  const NightTrackGeometry({required this.days, required this.fill, required this.sunX});
  final bool days;
  final double fill, sunX;
  bool get endBeforeSun => fill < sunX;
}

class NightResult {
  NightResult({required this.msgs, required this.errs, required this.reserve, required this.pct});

  final Map<NightField, List<FieldMsg>> msgs;
  final Set<NightField> errs;
  NightState state = NightState.empty;

  /// Campo al que lleva «Ir al dato» cuando [state] es fix.
  NightField? fixField;

  final double reserve;
  final double pct;

  /// Capacidad en kWh.
  double cap = 0;
  double load = double.nan;
  double usefulPct = 0, usable = 0, loadKw = 0, hours = 0, perPct = 0, lossF = 1;
  int durationMin = 0;
  int? now, sun;
  double? hoursToSun;
  NightVerdict? verdict;
  NightTrackGeometry? track;

  /// Minutos (desde la medianoche) en que se acaba, si se muestra la hora de fin.
  double? endMinutes;
}

NightResult nightCalc(NightInput inp) {
  final pP = parseNumber(inp.pctTxt);
  final wP = parseNumber(inp.loadTxt, thousands: true, decimalSep: inp.decimalSep);
  final rP = parseNumber(inp.reserveTxt);
  final msgs = {for (final f in NightField.values) f: <FieldMsg>[]};
  final errs = <NightField>{};

  var rsv = reserveDefault;
  var rsvOk = true;
  if (rP.empty || !rP.isNumber || rP.value < reserveMin || rP.value > reserveMax) {
    rsvOk = false;
    msgs[NightField.reserve]!.add(const FieldMsg(MsgKind.err, MsgCode.rsvBad));
    errs.add(NightField.reserve);
  } else {
    rsv = rP.value;
  }
  if (pP.empty || !pP.isNumber || pP.value < 0 || pP.value > 100) {
    errs.add(NightField.pct);
    msgs[NightField.pct]!.add(FieldMsg(MsgKind.err, pP.empty || !pP.isNumber ? MsgCode.numBad : MsgCode.pctBad));
  }
  if (wP.readAsThousands) msgs[NightField.load]!.add(FieldMsg(MsgKind.info, MsgCode.readAs, parsed: wP));
  if (!wP.empty && (!wP.isNumber || wP.value < 0)) {
    errs.add(NightField.load);
    msgs[NightField.load]!.add(const FieldMsg(MsgKind.err, MsgCode.numBad));
  }
  if (wP.value > weirdPowerW) msgs[NightField.load]!.add(const FieldMsg(MsgKind.warn, MsgCode.weird));

  final r = NightResult(msgs: msgs, errs: errs, reserve: rsv, pct: pP.value);
  r.load = wP.value;
  if (errs.contains(NightField.pct)) {
    return r
      ..state = NightState.fix
      ..fixField = NightField.pct;
  }
  if (!rsvOk) {
    return r
      ..state = NightState.fix
      ..fixField = NightField.reserve;
  }
  if (wP.empty) return r..state = NightState.empty;
  if (errs.contains(NightField.load)) {
    return r
      ..state = NightState.fix
      ..fixField = NightField.load;
  }

  final cap = inp.cap;
  final a = pP.value;
  final w = wP.value;
  final s = inp.loss ? lossFactor : 1.0;
  final i = math.max(0.0, a - rsv);
  final c = cap * i / 100 * s;
  final d = w / 1000;
  final u = d > 0 ? c / d : double.infinity;
  final wm = u.isFinite ? (60 * u).round() : 1 << 62;
  r
    ..cap = cap
    ..lossF = s
    ..usefulPct = i
    ..usable = c
    ..loadKw = d
    ..hours = u
    ..perPct = cap * 0.01 * s
    ..durationMin = wm
    ..now = inp.now
    ..sun = inp.sun
    ..state = i == 0
        ? NightState.inReserve
        : d == 0
        ? NightState.noLoad
        : NightState.ok;

  if (r.state == NightState.ok && wm >= 1 && inp.now != null && !isDays(u)) {
    r.endMinutes = inp.now! + 60 * u;
  }

  if (inp.now != null && inp.sun != null && i > 0 && d > 0) {
    var e = inp.sun! - inp.now!;
    if (e < 0) e += 1440;
    if (e > 0) {
      final ah = e / 60;
      final need = d * ah;
      r.hoursToSun = ah;
      if (c >= need || wm >= e) {
        final left = math.max(0.0, c - need);
        r.verdict = NightVerdict.ok(left: left, pctAtDawn: (rsv + left / (cap * s) * 100).round());
      } else {
        final kk = c / ah * 1000;
        final k = kk >= 10 ? 10 * (kk / 10).floor() : kk.floor();
        r.verdict = NightVerdict.bad(short: need - c, maxW: k);
      }
      final days = isDays(u);
      final span = days ? ah / 0.06 : math.max(u, ah) * 1.04;
      final fill = days ? 100.0 : math.min(100.0, u / span * 100);
      final sunX = (ah / span * 100).clamp(4.0, 98.0);
      r.track = NightTrackGeometry(days: days, fill: fill, sunX: sunX);
    }
  }
  return r;
}

// =====================================================================
// Cargando con la red (SPEC §4.3)
// =====================================================================

enum PowerMode { watts, amps }

enum ChargeField { pct, target, watts, amps, volts }

enum ChargeState { fix, noPower, already, ok }

class ChargeInput {
  const ChargeInput({
    required this.cap,
    required this.pctTxt,
    required this.targetTxt,
    required this.mode,
    required this.wattsTxt,
    required this.ampsTxt,
    required this.voltsTxt,
    required this.now,
    this.decimalSep = ',',
  });
  final double cap;
  final String pctTxt, targetTxt, wattsTxt, ampsTxt, voltsTxt;
  final PowerMode mode;
  final int? now;
  final String decimalSep;
}

class ChargeResult {
  ChargeResult({required this.pctMsgs, required this.powerMsgs, required this.errs});

  /// Mensajes de los dos porcientos (van juntos debajo de los campos).
  final List<FieldMsg> pctMsgs;

  /// Mensajes de la potencia (W, o A y V).
  final List<FieldMsg> powerMsgs;
  final Set<ChargeField> errs;
  ChargeState state = ChargeState.noPower;
  ChargeField? fixField;

  double cap = 0, pct = double.nan, target = double.nan, watts = double.nan;
  double amps = double.nan, volts = double.nan;

  /// % por cargar, kWh por cargar, kW, % de tramo rápido y lento, kWh de cada tramo.
  double delta = 0, kwhToCharge = 0, kw = 0, fastPct = 0, slowPct = 0, fastKwh = 0, slowKwh = 0;

  /// Minutos de cada tramo.
  int fastMin = 0, slowMin = 0;

  /// Horas totales.
  double hours = 0;

  /// % que sube por hora.
  double perHour = 0;

  /// kWh que gasta de la red.
  double grid = 0;
  int? now;

  bool get twoStretches => fastPct > 0 && slowPct > 0;

  /// Desde dónde empieza el tramo lento.
  double get slowStart => math.max(pct, slowFrom);

  /// Fracción (0..100) del ancho de la regla que ocupa el tramo rápido.
  double get fastShare {
    final tot = fastMin + slowMin;
    return tot == 0 ? 100 : fastMin / tot * 100;
  }

  double? get endMinutes => now == null ? null : now! + hours * 60;
}

ChargeResult chargeCalc(ChargeInput inp) {
  final aP = parseNumber(inp.pctTxt);
  final oP = parseNumber(inp.targetTxt);
  final errs = <ChargeField>{};
  final pctMsgs = <FieldMsg>[];
  final powMsgs = <FieldMsg>[];
  bool bad(ParsedNumber p) => p.empty || !p.isNumber || p.value < 0 || p.value > 100;
  if (bad(aP)) {
    errs.add(ChargeField.pct);
    pctMsgs.add(const FieldMsg(MsgKind.err, MsgCode.pctBad));
  }
  if (bad(oP)) {
    errs.add(ChargeField.target);
    pctMsgs.add(const FieldMsg(MsgKind.err, MsgCode.tgtBad));
  }
  final r = ChargeResult(pctMsgs: pctMsgs, powerMsgs: powMsgs, errs: errs);
  double w;
  bool wEmpty;
  if (inp.mode == PowerMode.watts) {
    final p = parseNumber(inp.wattsTxt, thousands: true, decimalSep: inp.decimalSep);
    if (p.readAsThousands) powMsgs.add(FieldMsg(MsgKind.info, MsgCode.readAs, parsed: p));
    wEmpty = p.empty;
    w = p.value;
    if (!p.empty && !(p.value > 0)) {
      errs.add(ChargeField.watts);
      powMsgs.add(FieldMsg(MsgKind.err, p.isNumber ? MsgCode.gt0 : MsgCode.numBad));
    }
  } else {
    final a = parseNumber(inp.ampsTxt, thousands: true, decimalSep: inp.decimalSep);
    final v = parseNumber(inp.voltsTxt);
    wEmpty = a.empty || v.empty;
    w = a.value * v.value;
    r
      ..amps = a.value
      ..volts = v.value;
    if (!a.empty && !(a.value > 0)) {
      errs.add(ChargeField.amps);
      powMsgs.add(FieldMsg(MsgKind.err, a.isNumber ? MsgCode.gt0 : MsgCode.numBad));
    }
    if (!v.empty && !(v.value > 0)) {
      errs.add(ChargeField.volts);
      powMsgs.add(FieldMsg(MsgKind.err, v.isNumber ? MsgCode.gt0 : MsgCode.numBad));
    }
    if (w > 0) powMsgs.add(FieldMsg(MsgKind.info, MsgCode.ampsResult, value: w));
  }
  if (w > weirdPowerW) powMsgs.add(const FieldMsg(MsgKind.warn, MsgCode.weird));
  r
    ..pct = aP.value
    ..target = oP.value
    ..watts = w;

  if (errs.contains(ChargeField.pct) || errs.contains(ChargeField.target)) {
    return r
      ..state = ChargeState.fix
      ..fixField = errs.contains(ChargeField.pct) ? ChargeField.pct : ChargeField.target;
  }
  if (wEmpty || !(w > 0)) return r..state = ChargeState.noPower;
  final a = aP.value;
  final o = oP.value;
  if (o <= a) return r..state = ChargeState.already;

  final cap = inp.cap;
  final c = o - a;
  final d = cap * c / 100;
  final u = w / 1000;
  final hh = math.max(a, slowFrom);
  final g = math.max(0.0, math.min(o, slowFrom) - a);
  final m = math.max(0.0, o - hh);
  final p = cap * g / 100;
  final f = cap * m / 100;
  final v = (p / u * 60).round();
  final ww = (f / (u / 2) * 60).round();
  r
    ..state = ChargeState.ok
    ..cap = cap
    ..delta = c
    ..kwhToCharge = d
    ..kw = u
    ..fastPct = g
    ..slowPct = m
    ..fastKwh = p
    ..slowKwh = f
    ..fastMin = v
    ..slowMin = ww
    ..hours = (v + ww) / 60
    ..perHour = math.min(100.0, u / cap * 100)
    ..grid = d / lossFactor
    ..now = inp.now;
  return r;
}
