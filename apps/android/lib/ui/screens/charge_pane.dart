import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../domain/calculator.dart';
import '../../domain/formatters.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/battery.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/result.dart';
import '../widgets/sheet.dart';
import 'common.dart';
import 'home_ctl.dart';

/// ¿Ya se salió de algún campo de potencia?
bool powerTouched(HomeCtl ctl) => ctl.isTouched('cW') || ctl.isTouched('cA') || ctl.isTouched('cV');

ChargeView computeCharge(AppState s, Fmt f, HomeCtl ctl) {
  final r = chargeCalc(
    ChargeInput(
      cap: s.cap ?? 0,
      pctTxt: s.cPct,
      targetTxt: s.cTgt,
      mode: s.pmode,
      wattsTxt: s.cW,
      ampsTxt: s.cA,
      voltsTxt: s.cV,
      now: parseClock(s.chargeNow),
      decimalSep: f.n.decimalSep,
    ),
  );
  return presentCharge(r, f, mode: s.pmode, powerTouched: powerTouched(ctl));
}

const _ids = {
  ChargeField.pct: 'cPct',
  ChargeField.target: 'cTgt',
  ChargeField.watts: 'cW',
  ChargeField.amps: 'cA',
  ChargeField.volts: 'cV',
};

class ChargePane extends StatelessWidget {
  const ChargePane({super.key, required this.view, required this.fmt, required this.ctl, required this.onShare});
  final ChargeView view;
  final Fmt fmt;
  final HomeCtl ctl;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final f = fmt;
    final narrow = isNarrow(context, s.big);
    final r = view.r;

    // ---------- Resultado ----------
    final result = <Widget>[];
    if (view.card != null) {
      final go = view.card!.goTo as ChargeField?;
      result.add(Kicker(icon: 'plug', text: view.kicker));
      result.add(StateCard(data: view.card!, goLabel: l.goField, onGo: go == null ? null : () => ctl.goTo(_ids[go]!)));
    } else {
      result.add(Kicker(icon: 'plug', text: view.kicker, shareLabel: l.share, onShare: onShare));
      result.add(BigAnswer(lead: view.lead!, big: view.big!, sub: view.sub));
      if (view.legend != null) {
        result.add(
          Column(
            children: [
              ChargeTrack(fastShare: r.fastShare, twoStretches: r.twoStretches),
              const SizedBox(height: 6),
              Legend(view.legend!, narrow: narrow),
            ],
          ),
        );
      }
      result.add(Notice(tone: Tone.info, title: view.gridTitle!, text: view.gridText!));
      result.add(Figures(view.figures, narrow: narrow));
    }

    // ---------- Datos ----------
    final pctTouched = ctl.isTouched('cPct') || ctl.isTouched('cTgt');
    bool shown(ChargeField fl) => r.errs.contains(fl) && ctl.isTouched(_ids[fl]!);
    final pTouched = powerTouched(ctl);
    final powMsgs = s.pmode == PowerMode.watts
        ? uiMsgs(r.powerMsgs, f, touched: ctl.isTouched('cW'))
        : uiMsgs(r.powerMsgs, f, touched: pTouched);
    final powWarn = r.powerMsgs.any((m) => m.kind == MsgKind.warn);
    final a = r.pct.isFinite ? r.pct.clamp(0, 100).toDouble() : 0.0;
    final o = r.target.isFinite ? r.target.clamp(0, 100).toDouble() : a;
    final nowMin = parseClock(s.chargeNow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          container: true,
          child: AppCard(
            key: ctl.chargeResultKey,
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
              CardTitle(l.chargeData),
              const SizedBox(height: 14),
              ExcludeSemantics(child: FieldLabel(l.batLevel)),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                child: BatterySlider.charge(
                  a: a,
                  b: o,
                  label: l.nowShort,
                  labelB: l.tgt,
                  onA: (v) => s.update((s) => s.cPct = '$v'),
                  onB: (v) => s.update((s) => s.cTgt = '$v'),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: KeyedSubtree(
                      key: ctl.key('cPct'),
                      child: NumberField(
                        label: l.nowShort,
                        smallLabel: true,
                        value: s.cPct,
                        unit: '%',
                        focusNode: ctl.focus('cPct'),
                        showError: shown(ChargeField.pct),
                        onChanged: (v) => s.update((s) => s.cPct = v),
                        onBlur: () => ctl.touch('cPct'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KeyedSubtree(
                      key: ctl.key('cTgt'),
                      child: NumberField(
                        label: l.tgt,
                        smallLabel: true,
                        value: s.cTgt,
                        unit: '%',
                        focusNode: ctl.focus('cTgt'),
                        showError: shown(ChargeField.target),
                        onChanged: (v) => s.update((s) => s.cTgt = v),
                        onBlur: () => ctl.touch('cTgt'),
                      ),
                    ),
                  ),
                ],
              ),
              FieldMessages(pctTouched ? [for (final m in r.pctMsgs) (m.kind, f.msg(m))] : const []),
              SwatchLegend([(solidSwatch(c.amb), l.legNow), (hatchSwatch(c.chg, c.chg, stripe: 4), l.legToCharge)]),
              const SizedBox(height: AppSpace.block),
              ExcludeSemantics(child: FieldLabel(l.power, icon: 'plug')),
              Segmented<PowerMode>(
                label: l.powHow,
                options: [(PowerMode.watts, l.modeW), (PowerMode.amps, l.modeA)],
                value: s.pmode,
                onChanged: (m) => s.update((s) => s.pmode = m),
              ),
              const SizedBox(height: 12),
              if (s.pmode == PowerMode.watts)
                KeyedSubtree(
                  key: ctl.key('cW'),
                  child: NumberField(
                    value: s.cW,
                    unit: 'W',
                    semanticLabel: l.powW,
                    placeholder: l.phPow,
                    focusNode: ctl.focus('cW'),
                    showError: shown(ChargeField.watts),
                    warn: powWarn && !shown(ChargeField.watts),
                    onChanged: (v) => s.update((s) => s.cW = v),
                    onBlur: () => ctl.touch('cW'),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KeyedSubtree(
                        key: ctl.key('cA'),
                        child: NumberField(
                          label: l.amps,
                          smallLabel: true,
                          value: s.cA,
                          unit: 'A',
                          focusNode: ctl.focus('cA'),
                          showError: shown(ChargeField.amps),
                          warn: powWarn && !shown(ChargeField.amps),
                          onChanged: (v) => s.update((s) => s.cA = v),
                          onBlur: () => ctl.touch('cA'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KeyedSubtree(
                        key: ctl.key('cV'),
                        child: NumberField(
                          label: l.volts,
                          smallLabel: true,
                          value: s.cV,
                          unit: 'V',
                          focusNode: ctl.focus('cV'),
                          showError: shown(ChargeField.volts),
                          onChanged: (v) => s.update((s) => s.cV = v),
                          onBlur: () => ctl.touch('cV'),
                        ),
                      ),
                    ),
                  ],
                ),
              FieldMessages(powMsgs),
              Hint(s.pmode == PowerMode.watts ? l.powHintW : l.powHintA),
              const SizedBox(height: AppSpace.block),
              TimeField(
                label: l.timeNow,
                icon: 'clock',
                minutes: nowMin,
                text: nowMin == null ? '—' : f.t.format(nowMin),
                onChanged: (m) => s.update((s) => s.chargeNow = clockString(m)),
                nowLabel: l.nowBtn,
                onNow: () {
                  final n = s.nowClock();
                  s.update((s) => s.chargeNow = n);
                  showToast(context, '${f.lang == 'es' ? 'Hora: ' : 'Time: '}${f.t.format(parseClock(n)!)}');
                },
              ),
              if (view.steps.isNotEmpty) ...[
                const SizedBox(height: AppSpace.block),
                Disclosure(
                  icon: 'steps',
                  title: l.how,
                  summary: l.howSub,
                  open: ctl.chargeHowOpen,
                  onToggle: () => ctl.set((c) => c.chargeHowOpen = !c.chargeHowOpen),
                  child: StepsList(view.steps),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        ApproxNote(l.cNote),
        const SizedBox(height: AppSpace.cardGap),
        PrimaryButton(label: l.share, icon: 'share', onPressed: view.shareable ? onShare : null),
      ],
    );
  }
}
