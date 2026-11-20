/// Convierte los resultados de `domain/` en los textos que se ven en pantalla y en el reporte.
library;

import '../domain/calculator.dart';
import '../domain/formatters.dart';
import '../l10n/gen/app_localizations.dart';

/// Tipo de aviso o veredicto (DESIGN §4: ok, bad/err, info, warn, neutral).
enum Tone { ok, bad, err, info, warn, neutral }

/// Ícono de la leyenda de una regla.
enum LegendIcon { none, moon, sun, battery, clock, flag }

class LegendItem {
  const LegendItem(this.icon, this.label, this.value);
  final LegendIcon icon;
  final String label, value;
  @override
  String toString() => '$label$value';
}

class Figure {
  const Figure(this.value, this.label);
  final String value, label;
  @override
  String toString() => '$value$label';
}

/// Tarjeta de estado (vacío, corregir, en la reserva…).
class StateCardData {
  const StateCardData(this.tone, this.title, this.text, {this.goTo, this.useBolt = false, this.usePlug = false});
  final Tone tone;
  final String title, text;

  /// Campo al que lleva «Ir al dato».
  final Object? goTo;
  final bool useBolt, usePlug;
}

/// Contenido de la franja de respuesta.
class StripData {
  const StripData(this.tone, this.text, this.tag);
  final Tone tone;
  final String text;
  final String? tag;
}

/// Utilidades de formato con idioma y reloj.
class Fmt {
  Fmt(this.l, {required bool use24h})
    : n = NumberFormatter(l.localeName.startsWith('en') ? 'en' : 'es'),
      t = TimeFormatter(l.localeName.startsWith('en') ? 'en' : 'es', use24h: use24h);
  final AppLocalizations l;
  final NumberFormatter n;
  final TimeFormatter t;
  String get lang => n.lang;
  String dur(double h) => formatDuration(h, n, l.days);
  String nf(double x, int d) => n.nf(x, d);

  /// Texto de un mensaje de campo.
  String msg(FieldMsg m) => switch (m.code) {
    MsgCode.numBad => l.numBad,
    MsgCode.gt0 => l.gt0,
    MsgCode.pctBad => l.pctBad,
    MsgCode.tgtBad => l.tgtBad,
    MsgCode.rsvBad => l.rsvBad,
    MsgCode.weird => l.weird,
    MsgCode.ampsResult => l.aResult(n.nf(m.value!, 2)),
    MsgCode.readAs => _readAs(m),
  };

  String _readAs(FieldMsg m) {
    final p = m.parsed!;
    final v = '${n.nf(p.value, 6)} W';
    return l.readAsAlt(v, '${p.alt} W', p.sepIsDot ? l.sepDot : l.sepComma);
  }
}

// =====================================================================
// De noche
// =====================================================================

class NightView {
  NightView._(this.r);
  final NightResult r;
  late String kicker;
  StateCardData? card;
  String? lead, big;
  Tone? verdictTone;
  String? verdictTitle, verdictText;

  /// W del botón «Probar con X W», si aparece.
  int? tryW;
  String? tryLabel;
  List<LegendItem>? legend;
  List<Figure> figures = const [];
  List<String> steps = const [];
  late StripData strip;

  /// Resultado completo: se puede compartir.
  bool get shareable => r.state == NightState.ok;

  /// Como el prototipo lo lee de corrido (título + texto + botón).
  String? get verdictFlat => verdictTitle == null ? null : '$verdictTitle$verdictText${tryLabel ?? ''}';
}

NightView presentNight(NightResult r, Fmt f) {
  final l = f.l;
  final v = NightView._(r);
  v.kicker = r.load >= 0 && r.load.isFinite ? l.kNight(f.nf(r.load, 2)) : l.kNight0;
  switch (r.state) {
    case NightState.empty:
      v.kicker = l.kNight0;
      v.card = StateCardData(Tone.neutral, l.emptyT, l.emptyX, useBolt: true);
      v.strip = StripData(Tone.neutral, l.stripEmpty, null);
    case NightState.fix:
      final text = switch (r.fixField!) {
        NightField.pct => l.fixPct,
        NightField.load => l.fixW,
        NightField.reserve => l.fixRsv,
      };
      v.card = StateCardData(Tone.err, l.fixT, text, goTo: r.fixField);
      v.strip = StripData(Tone.err, l.stripErr, l.tagFix);
    case NightState.inReserve:
      v.card = StateCardData(Tone.bad, l.inRsvT, l.inRsvX(f.nf(r.reserve, 2)));
      v.strip = StripData(Tone.bad, l.inRsvT, null);
    case NightState.noLoad:
      v.card = StateCardData(Tone.ok, l.noLoadT, l.noLoadX(f.nf(r.usable, 2)));
      v.strip = StripData(Tone.ok, l.noLoadT, null);
    case NightState.ok:
      _nightOk(v, r, f);
  }
  v.steps = _nightSteps(r, f);
  return v;
}

void _nightOk(NightView v, NightResult r, Fmt f) {
  final l = f.l;
  final wm = r.durationMin;
  String? endTxt;
  if (wm < 1) {
    v.lead = l.leadFor;
    v.big = l.almost;
  } else if (r.endMinutes == null) {
    v.lead = l.leadFor;
    v.big = f.dur(r.hours);
  } else {
    final em = r.endMinutes!;
    endTxt = f.t.format(em);
    v.lead = f.lang == 'es' && f.t.article(em) == 'la ' ? l.leadUntil1 : l.leadUntil;
    v.big = endTxt;
  }
  final verdict = r.verdict;
  if (verdict != null) {
    final sunT = f.t.format(r.sun!);
    final sunA = f.t.withArticle(r.sun!);
    if (verdict.reaches) {
      v.verdictTone = Tone.ok;
      v.verdictTitle = l.okT;
      v.verdictText = verdict.left < 0.001
          ? l.okJust(sunA)
          : l.okTxt(f.n.q(verdict.left), sunA, '${verdict.pctAtDawn}');
    } else {
      v.verdictTone = Tone.bad;
      v.verdictTitle = l.badT;
      final k = verdict.maxW;
      v.verdictText = k > 0
          ? l.badTxt(f.n.q(verdict.short), sunA, f.nf(k.toDouble(), 0))
          : l.badLow(f.n.q(verdict.short));
      if (k > 0 && k < r.load) {
        v.tryW = k;
        v.tryLabel = l.tryW(f.nf(k.toDouble(), 0));
      }
    }
    final tr = r.track!;
    final endValue = tr.days ? l.inDays(f.dur(r.hours)) : (endTxt ?? f.dur(r.hours));
    final now = LegendItem(LegendIcon.moon, l.lNow, f.t.format(r.now!));
    final sunI = LegendItem(LegendIcon.sun, l.lSun, sunT);
    final endI = LegendItem(LegendIcon.battery, l.lEnd, endValue);
    v.legend = tr.endBeforeSun ? [now, endI, sunI] : [now, sunI, endI];
    v.strip = StripData(
      verdict.reaches ? Tone.ok : Tone.bad,
      endTxt != null ? '${l.hasta}$endTxt' : v.big!,
      verdict.reaches ? l.tagOk : l.tagBad,
    );
  } else {
    v.strip = StripData(Tone.neutral, endTxt != null ? '${l.hasta}$endTxt' : v.big!, null);
  }
  final hp = r.perPct * 1000;
  v.figures = [
    Figure(r.usable < 0.1 ? '${f.nf(r.usable, 4)} kWh' : f.n.kwh(r.usable), l.fUsable),
    Figure(wm < 1 ? '< 1 min' : f.dur(r.hours), l.fDur),
    Figure('${f.nf(hp, hp < 10 ? 1 : 0)} Wh', l.fPer),
  ];
}

List<String> _nightSteps(NightResult r, Fmt f) {
  if (r.state == NightState.empty || r.state == NightState.fix) return const [];
  final l = f.l;
  final n = f.n;
  final cap = r.cap;
  final out = <String>[];
  if (r.usefulPct == 0) {
    out.add(l.lBelow(n.nf(r.pct, 2), n.nf(r.reserve, 2)));
  } else {
    out.add(l.lReserve(n.nf(r.pct, 2), n.nf(r.reserve, 2), n.nf(r.usefulPct, 2)));
    final capTxt = '${n.nf(cap, 3)} kWh';
    final gross = n.b3(cap * r.usefulPct / 100);
    out.add(
      r.lossF < 1
          ? l.lCapLoss(capTxt, n.nf(r.usefulPct, 2), gross, n.b3(r.usable))
          : l.lCap(capTxt, n.nf(r.usefulPct, 2), gross),
    );
  }
  if (r.loadKw > 0 && r.usefulPct > 0) {
    out.add(l.lRun(n.b3(r.usable), r.loadKw < 1 ? '${n.nf(r.load, 2)} W' : '${n.nf(r.loadKw, 3)} kW', f.dur(r.hours)));
  }
  return out;
}

// =====================================================================
// Duración (SPEC §4.5)
// =====================================================================

class RuntimeView {
  RuntimeView._(this.r);
  final NightResult r;
  late String kicker;
  StateCardData? card;
  String? lead, big, sub;
  Tone? verdictTone;
  String? verdictTitle, verdictText;
  int? tryW;
  String? tryLabel;
  List<LegendItem>? legend;
  List<Figure> figures = const [];
  List<String> steps = const [];
  late StripData strip;

  bool get shareable => r.state == NightState.ok;
  bool? get reaches => r.verdict?.reaches;
  String? get verdictFlat => verdictTitle == null ? null : '$verdictTitle$verdictText${tryLabel ?? ''}';
}

RuntimeView presentRuntime(NightResult r, Fmt f) {
  final l = f.l;
  final v = RuntimeView._(r);
  v.kicker = r.load >= 0 && r.load.isFinite ? l.kRuntime(f.nf(r.load, 2)) : l.kRuntime0;
  switch (r.state) {
    case NightState.empty:
      v.kicker = l.kRuntime0;
      v.card = StateCardData(Tone.neutral, l.emptyT, l.rtEmptyX, useBolt: true);
      v.strip = StripData(Tone.neutral, l.stripEmpty, null);
    case NightState.fix:
      final text = switch (r.fixField!) {
        NightField.pct => l.fixPct,
        NightField.load => l.fixW,
        NightField.reserve => l.fixRsv,
      };
      v.card = StateCardData(Tone.err, l.fixT, text, goTo: r.fixField);
      v.strip = StripData(Tone.err, l.stripErr, l.tagFix);
    case NightState.inReserve:
      v.card = StateCardData(Tone.bad, l.inRsvT, l.inRsvX(f.nf(r.reserve, 2)));
      v.strip = StripData(Tone.bad, l.inRsvT, null);
    case NightState.noLoad:
      v.card = StateCardData(Tone.ok, l.noLoadT, l.noLoadX(f.nf(r.usable, 2)));
      v.strip = StripData(Tone.ok, l.noLoadT, null);
    case NightState.ok:
      _runtimeOk(v, r, f);
  }
  v.steps = _nightSteps(r, f);
  return v;
}

void _runtimeOk(RuntimeView v, NightResult r, Fmt f) {
  final l = f.l;
  final wm = r.durationMin;
  v.lead = l.leadFor;
  v.big = wm < 1 ? l.almost : f.dur(r.hours);
  final em = r.endMinutes;
  if (em != null) v.sub = l.rtSub(f.t.withArticle(r.now!), f.t.withArticle(em));
  final verdict = r.verdict;
  if (verdict != null) {
    final endA = f.t.withArticle(r.sun!);
    if (verdict.reaches) {
      v.verdictTone = Tone.ok;
      v.verdictTitle = l.rtOkT(endA);
      v.verdictText = verdict.left < 0.001
          ? l.okJust(endA)
          : l.okTxt(f.n.q(verdict.left), endA, '${verdict.pctAtDawn}');
    } else {
      v.verdictTone = Tone.bad;
      v.verdictTitle = l.rtBadT(endA);
      final k = verdict.maxW;
      v.verdictText = k > 0
          ? l.badTxt(f.n.q(verdict.short), endA, f.nf(k.toDouble(), 0))
          : l.badLow(f.n.q(verdict.short));
      if (k > 0 && k < r.load) {
        v.tryW = k;
        v.tryLabel = l.tryW(f.nf(k.toDouble(), 0));
      }
    }
    final tr = r.track!;
    final endValue = tr.days ? l.inDays(f.dur(r.hours)) : (em != null ? f.t.format(em) : f.dur(r.hours));
    final start = LegendItem(LegendIcon.clock, l.lStart, f.t.format(r.now!));
    final until = LegendItem(LegendIcon.flag, l.lUntil, f.t.format(r.sun!));
    final endI = LegendItem(LegendIcon.battery, l.lEnd, endValue);
    v.legend = tr.endBeforeSun ? [start, endI, until] : [start, until, endI];
  }
  v.strip = StripData(
    verdict == null ? Tone.neutral : (verdict.reaches ? Tone.ok : Tone.bad),
    '${l.stripLasts}${v.big}',
    verdict == null ? null : (verdict.reaches ? l.tagReach : l.tagShort),
  );
  final hp = r.perPct * 1000;
  final y = r.perHour;
  v.figures = [
    Figure(r.usable < 0.1 ? '${f.nf(r.usable, 4)} kWh' : f.n.kwh(r.usable), l.fUsable),
    Figure(y < 0.1 ? '< ${f.nf(0.1, 1)}%' : '≈ ${f.nf(y, y < 10 ? 1 : 0)}%', l.fPerHourDown),
    Figure('${f.nf(hp, hp < 10 ? 1 : 0)} Wh', l.fPer),
  ];
}

// =====================================================================
// Cargando con la red
// =====================================================================

class ChargeView {
  ChargeView._(this.r);
  final ChargeResult r;
  late String kicker;
  StateCardData? card;
  String? lead, big, sub;
  List<LegendItem>? legend;
  String? gridTitle, gridText;
  List<Figure> figures = const [];
  List<String> steps = const [];
  late StripData strip;
  bool get shareable => r.state == ChargeState.ok;
}

/// [powerTouched]: la persona ya salió de un campo de potencia (el vacío pasa a error).
ChargeView presentCharge(ChargeResult r, Fmt f, {required PowerMode mode, bool powerTouched = false}) {
  final l = f.l;
  final v = ChargeView._(r);
  v.kicker = r.watts > 0 ? l.kCharge(f.nf(r.watts, 0)) : l.kCharge0;
  switch (r.state) {
    case ChargeState.fix:
      v.card = StateCardData(Tone.err, l.fixT, l.fixC, goTo: r.fixField);
      v.strip = StripData(Tone.err, l.stripErr, l.tagFix);
    case ChargeState.noPower:
      v.kicker = l.kCharge0;
      v.card = StateCardData(
        powerTouched ? Tone.err : Tone.neutral,
        l.noPowT,
        l.noPowX,
        goTo: powerTouched ? (mode == PowerMode.watts ? ChargeField.watts : ChargeField.amps) : null,
        usePlug: !powerTouched,
      );
      v.strip = StripData(powerTouched ? Tone.err : Tone.neutral, l.noPowT, null);
    case ChargeState.already:
      v.card = StateCardData(Tone.ok, l.alreadyT, l.alreadyX(f.nf(r.pct, 2), f.nf(r.target, 2)));
      v.strip = StripData(Tone.ok, l.alreadyT, null);
    case ChargeState.ok:
      _chargeOk(v, r, f, mode);
  }
  return v;
}

void _chargeOk(ChargeView v, ChargeResult r, Fmt f, PowerMode mode) {
  final l = f.l;
  final n = f.n;
  final endM = r.endMinutes;
  final endT = endM != null && !isDays(r.hours) ? f.t.format(endM) : null;
  v.lead = l.cLead;
  v.big = f.dur(r.hours);
  if (endT != null) v.sub = l.cSub(n.nf(r.target, 2), '${f.t.article(endM!)}$endT');
  if (r.now != null) {
    v.legend = [
      LegendItem(LegendIcon.none, l.lNow, f.t.format(r.now!)),
      if (r.twoStretches) LegendItem(LegendIcon.none, l.lAt('${slowFrom.round()}'), f.t.format(r.now! + r.fastMin)),
      LegendItem(LegendIcon.none, l.lAt(n.nf(r.target, 2)), isDays(r.hours) ? f.dur(r.hours) : f.t.format(endM!)),
    ];
  }
  v.gridTitle = l.gridT(n.nf(r.grid, 2));
  v.gridText = l.gridX;
  final y = r.perHour;
  v.figures = [
    Figure(n.kwh(r.kwhToCharge), l.fToCharge),
    Figure(y < 0.1 ? '< ${n.nf(0.1, 1)}%' : '≈ ${n.nf(y, y < 10 ? 1 : 0)}%', l.fPerHour),
  ];
  v.strip = StripData(Tone.ok, '${l.stripTakes}${f.dur(r.hours)}', endT);

  final s = <String>[];
  if (mode == PowerMode.amps) s.add(l.lAmps(n.nf(r.amps, 2), n.nf(r.volts, 2), n.nf(r.watts, 2)));
  final cap = r.cap;
  s.add(l.lDelta(n.nf(r.target, 2), n.nf(r.pct, 2), n.nf(r.delta, 2)));
  s.add(l.lKwh('${n.nf(cap, 3)} kWh', n.nf(r.delta, 2), n.b3(r.kwhToCharge)));
  final fastT = f.dur(r.fastMin / 60);
  final slowT = f.dur(r.slowMin / 60);
  final slowLine = l.lSlow(n.nf(r.slowStart, 2), n.nf(r.target, 2), n.b3(r.slowKwh), n.power(r.kw / 2), slowT);
  if (r.twoStretches) {
    s.add(l.lFast(n.nf(r.pct, 2), n.nf(slowFrom, 2), n.b3(r.fastKwh), n.power(r.kw), fastT));
    s.add(slowLine);
    s.add(l.lTotal(fastT, slowT, f.dur(r.hours)));
  } else if (r.slowPct > 0) {
    s.add(slowLine);
  } else {
    s.add(l.lTime(n.b3(r.kwhToCharge), n.power(r.kw), f.dur(r.hours)));
  }
  v.steps = s;
}
