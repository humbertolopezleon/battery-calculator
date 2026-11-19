import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../domain/calculator.dart';
import '../../domain/formatters.dart';
import '../../domain/number_parser.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/battery.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/result.dart';
import '../widgets/sheet.dart';
import 'common.dart';
import 'home_ctl.dart';

/// Calcula la pestaña De noche con el estado actual.
NightView computeNight(AppState s, Fmt f) {
  final r = nightCalc(
    NightInput(
      cap: s.cap ?? 0,
      pctTxt: s.nPct,
      loadTxt: s.nW,
      reserveTxt: s.rsv,
      loss: s.loss,
      now: parseClock(s.nightNow),
      sun: parseClock(s.nSun),
      decimalSep: f.n.decimalSep,
    ),
  );
  return presentNight(r, f);
}

const _fieldIds = {NightField.pct: 'nPct', NightField.load: 'nW', NightField.reserve: 'nRsv'};

class NightPane extends StatelessWidget {
  const NightPane({super.key, required this.view, required this.fmt, required this.ctl, required this.onShare});
  final NightView view;
  final Fmt fmt;
  final HomeCtl ctl;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final narrow = isNarrow(context, s.big);
    final r = view.r;
    final f = fmt;

    // ---------- Tarjeta de resultado ----------
    final result = <Widget>[];
    if (view.card != null) {
      final go = view.card!.goTo as NightField?;
      result.add(Kicker(icon: 'moon', text: view.kicker));
      result.add(
        StateCard(data: view.card!, goLabel: l.goField, onGo: go == null ? null : () => ctl.goTo(_fieldIds[go]!)),
      );
    } else {
      result.add(Kicker(icon: 'moon', text: view.kicker, shareLabel: l.share, onShare: onShare));
      result.add(BigAnswer(lead: view.lead!, big: view.big!));
      if (view.verdictTitle != null) {
        result.add(
          Notice(
            tone: view.verdictTone!,
            title: view.verdictTitle!,
            text: view.verdictText!,
            extra: view.tryW == null
                ? null
                : Align(
                    alignment: Alignment.centerLeft,
                    child: SecondaryButton(
                      label: view.tryLabel!,
                      icon: 'bolt',
                      small: true,
                      onPressed: () {
                        final w = '${view.tryW}';
                        s.update((s) => s.nW = w);
                        showToast(context, l.trying(w));
                      },
                    ),
                  ),
          ),
        );
      }
      if (r.track != null) {
        result.add(
          Column(
            children: [
              NightTrack(g: r.track!, reaches: r.verdict!.reaches),
              const SizedBox(height: 6),
              Legend(view.legend!, narrow: narrow),
            ],
          ),
        );
      }
      result.add(Figures(view.figures, narrow: narrow));
    }

    // ---------- Datos ----------
    bool shown(NightField fl) => r.errs.contains(fl) && ctl.isTouched(_fieldIds[fl]!);
    List<UiMsg> msgs(NightField fl) => uiMsgs(r.msgs[fl]!, f, touched: ctl.isTouched(_fieldIds[fl]!));
    bool warn(NightField fl) => r.msgs[fl]!.any((m) => m.kind == MsgKind.warn) && !shown(fl);

    final pctValid = !r.errs.contains(NightField.pct);
    final a = pctValid ? r.pct.clamp(0, 100).toDouble() : 0.0;
    final rsvParsed = parseNumber(s.rsv);
    final nowMin = parseClock(s.nightNow);
    final sunMin = parseClock(s.nSun);

    void stepReserve(int dv) {
      var v = rsvParsed.isNumber ? rsvParsed.value : reserveDefault;
      v = math.max(reserveMin, math.min(reserveMax, (v.round() + dv).toDouble()));
      s.update((s) => s.rsv = '${v.round()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          container: true,
          child: AppCard(
            key: ctl.nightResultKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in result.indexed) ...[if (i > 0) const SizedBox(height: 12), w],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(l.nightData),
              const SizedBox(height: 14),
              // Porciento ahora: batería deslizable + campo de 100 dp.
              ExcludeSemantics(child: FieldLabel(l.pctNow)),
              Row(
                children: [
                  Expanded(
                    child: BatterySlider.night(
                      a: a,
                      reserve: r.reserve,
                      label: l.pctNow,
                      onA: (v) => s.update((s) => s.nPct = '$v'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: KeyedSubtree(
                      key: ctl.key('nPct'),
                      child: NumberField(
                        value: s.nPct,
                        unit: '%',
                        center: true,
                        semanticLabel: l.pctNow,
                        focusNode: ctl.focus('nPct'),
                        showError: shown(NightField.pct),
                        onChanged: (v) => s.update((s) => s.nPct = v),
                        onBlur: () => ctl.touch('nPct'),
                      ),
                    ),
                  ),
                ],
              ),
              FieldMessages(msgs(NightField.pct)),
              if (pctValid)
                SwatchLegend([
                  (hatchSwatch(c.rsv, c.rsv), l.legRsv(f.nf(r.reserve, 2))),
                  (solidSwatch(c.amb), l.legUse(f.nf(math.max(0, a - r.reserve), 2))),
                ]),
              const SizedBox(height: AppSpace.block),
              KeyedSubtree(
                key: ctl.key('nW'),
                child: NumberField(
                  label: l.load,
                  labelIcon: 'bolt',
                  value: s.nW,
                  unit: 'W',
                  placeholder: l.phLoad,
                  focusNode: ctl.focus('nW'),
                  msgs: msgs(NightField.load),
                  showError: shown(NightField.load),
                  warn: warn(NightField.load),
                  hint: l.loadHint,
                  onChanged: (v) => s.update((s) => s.nW = v),
                  onBlur: () => ctl.touch('nW'),
                ),
              ),
              const SizedBox(height: AppSpace.block),
              TimeField(
                label: l.timeNow,
                icon: 'clock',
                minutes: nowMin,
                text: nowMin == null ? '—' : f.t.format(nowMin),
                onChanged: (m) => s.update((s) => s.nightNow = clockString(m)),
                nowLabel: l.nowBtn,
                onNow: () {
                  final n = s.nowClock();
                  s.update((s) => s.nightNow = n);
                  showToast(context, '${f.lang == 'es' ? 'Hora: ' : 'Time: '}${f.t.format(parseClock(n)!)}');
                },
              ),
              const SizedBox(height: AppSpace.block),
              TimeField(
                label: l.sunrise,
                icon: 'sunrise',
                minutes: sunMin,
                text: sunMin == null ? '—' : f.t.format(sunMin),
                hint: l.sunHint,
                onChanged: (m) => s.update((s) => s.nSun = clockString(m)),
              ),
              const SizedBox(height: AppSpace.block),
              Disclosure(
                icon: 'sliders',
                title: l.more,
                summary: l.moreS('${s.loss}', rsvParsed.isNumber ? s.rsv : '—'),
                open: ctl.moreOpen,
                onToggle: () => ctl.set((c) => c.moreOpen = !c.moreOpen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchRow(
                      title: l.loss,
                      hint: l.lossHint,
                      value: s.loss,
                      onChanged: (v) => s.update((s) => s.loss = v),
                    ),
                    const SizedBox(height: 14),
                    ExcludeSemantics(child: FieldLabel(l.rsvLabel)),
                    Row(
                      children: [
                        _StepButton(icon: 'minus', label: l.minus, onTap: () => stepReserve(-1)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: KeyedSubtree(
                            key: ctl.key('nRsv'),
                            child: NumberField(
                              value: s.rsv,
                              unit: '%',
                              center: true,
                              semanticLabel: l.rsvLabel,
                              focusNode: ctl.focus('nRsv'),
                              showError: shown(NightField.reserve),
                              onChanged: (v) => s.update((s) => s.rsv = v),
                              onBlur: () => ctl.set((c) {
                                c.touched.add('nRsv');
                                if (r.errs.contains(NightField.reserve)) c.moreOpen = true;
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StepButton(icon: 'plus', label: l.plus, onTap: () => stepReserve(1)),
                      ],
                    ),
                    FieldMessages(msgs(NightField.reserve)),
                    Hint(l.rsvHint),
                    const SizedBox(height: 4),
                    Center(
                      child: LinkButton(
                        label: l.rsvReset,
                        onPressed: rsvParsed.value == reserveDefault ? null : () => s.update((s) => s.rsv = '6'),
                      ),
                    ),
                  ],
                ),
              ),
              if (view.steps.isNotEmpty)
                Disclosure(
                  icon: 'steps',
                  title: l.how,
                  summary: l.howSub,
                  open: ctl.nightHowOpen,
                  onToggle: () => ctl.set((c) => c.nightHowOpen = !c.nightHowOpen),
                  child: StepsList(view.steps),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        ApproxNote(l.nNote),
        const SizedBox(height: AppSpace.cardGap),
        PrimaryButton(label: l.share, icon: 'share', onPressed: view.shareable ? onShare : null),
      ],
    );
  }
}

/// Botón [−]/[+] de 56 dp.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap});
  final String icon, label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, pressed, focused) => Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? c.sf2 : c.sf,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: focused ? c.focus : c.tx, width: 2),
        ),
        child: AppIcon(icon, color: c.tx, stroke: 2.5),
      ),
    );
  }
}
