import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../domain/calculator.dart';
import '../../domain/formatters.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/result.dart';
import '../widgets/sheet.dart';
import 'common.dart';
import 'consumption_fields.dart';
import 'home_ctl.dart';

/// Calcula la pestaña Duración con el estado actual (SPEC §4.5).
RuntimeView computeRuntime(AppState s, Fmt f) {
  final r = runtimeCalc(
    RuntimeInput(
      cap: s.cap ?? 0,
      pctTxt: s.nPct,
      loadTxt: s.nW,
      reserveTxt: s.rsv,
      loss: s.loss,
      start: parseClock(s.rFrom),
      end: parseClock(s.rTo),
      decimalSep: f.n.decimalSep,
    ),
  );
  return presentRuntime(r, f);
}

class RuntimePane extends StatelessWidget {
  const RuntimePane({super.key, required this.view, required this.fmt, required this.ctl, required this.onShare});
  final RuntimeView view;
  final Fmt fmt;
  final HomeCtl ctl;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final narrow = isNarrow(context, s.big);
    final r = view.r;
    final f = fmt;

    // ---------- Tarjeta de resultado ----------
    final result = <Widget>[];
    if (view.card != null) {
      final go = view.card!.goTo as NightField?;
      result.add(Kicker(icon: 'clock', text: view.kicker));
      result.add(
        StateCard(
          data: view.card!,
          goLabel: l.goField,
          onGo: go == null ? null : () => ctl.goTo(consumptionFieldIds[go]!),
        ),
      );
    } else {
      result.add(Kicker(icon: 'clock', text: view.kicker, shareLabel: l.share, onShare: onShare));
      result.add(BigAnswer(lead: view.lead!, big: view.big!, sub: view.sub));
      if (view.verdictTitle != null) {
        result.add(
          verdictNotice(
            context,
            tone: view.verdictTone!,
            title: view.verdictTitle!,
            text: view.verdictText!,
            tryW: view.tryW,
            tryLabel: view.tryLabel,
          ),
        );
      }
      if (r.track != null) {
        result.add(
          Column(
            children: [
              NightTrack(g: r.track!, reaches: r.verdict!.reaches, markerIcon: 'flag'),
              const SizedBox(height: 6),
              Legend(view.legend!, narrow: narrow),
            ],
          ),
        );
      }
      result.add(Figures(view.figures, narrow: narrow));
    }

    final fromMin = parseClock(s.rFrom);
    final toMin = parseClock(s.rTo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          container: true,
          child: AppCard(
            key: ctl.runtimeResultKey,
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
              CardTitle(l.runtimeData),
              const SizedBox(height: 14),
              PctAndLoadFields(r: r, fmt: f, ctl: ctl),
              const SizedBox(height: AppSpace.block),
              TimeField(
                label: l.fromTime,
                icon: 'clock',
                minutes: fromMin,
                text: fromMin == null ? '—' : f.t.format(fromMin),
                hint: l.fromHint,
                onChanged: (m) => s.update((s) => s.rFrom = clockString(m)),
                nowLabel: l.nowBtn,
                onNow: () {
                  final n = s.nowClock();
                  s.update((s) => s.rFrom = n);
                  showToast(context, l.timeToast(f.t.format(parseClock(n)!)));
                },
              ),
              const SizedBox(height: AppSpace.block),
              TimeField(
                label: l.toTime,
                icon: 'flag',
                minutes: toMin,
                text: toMin == null ? l.toEmpty : f.t.format(toMin),
                hint: l.toHint,
                initialPick: fromMin,
                onChanged: (m) => s.update((s) => s.rTo = clockString(m)),
                clearLabel: l.toClear,
                onClear: () => s.update((s) => s.rTo = ''),
              ),
              const SizedBox(height: AppSpace.block),
              MoreOptions(r: r, fmt: f, ctl: ctl),
              if (view.steps.isNotEmpty)
                Disclosure(
                  icon: 'steps',
                  title: l.how,
                  summary: l.howSub,
                  open: ctl.runtimeHowOpen,
                  onToggle: () => ctl.set((c) => c.runtimeHowOpen = !c.runtimeHowOpen),
                  child: StepsList(view.steps),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.cardGap),
        ApproxNote(l.rNote),
        const SizedBox(height: AppSpace.cardGap),
        PrimaryButton(label: l.share, icon: 'share', onPressed: view.shareable ? onShare : null),
      ],
    );
  }
}
