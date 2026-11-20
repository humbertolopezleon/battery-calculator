import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../domain/calculator.dart';
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

/// Campos que comparten Duración y De noche: los dos usan el mismo estado (SPEC §4.5).
const consumptionFieldIds = {NightField.pct: 'nPct', NightField.load: 'nW', NightField.reserve: 'nRsv'};

/// Mensajes y estados de error de los campos compartidos.
class _Msgs {
  _Msgs(this.r, this.f, this.ctl);
  final NightResult r;
  final Fmt f;
  final HomeCtl ctl;
  bool shown(NightField fl) => r.errs.contains(fl) && ctl.isTouched(consumptionFieldIds[fl]!);
  List<UiMsg> msgs(NightField fl) => uiMsgs(r.msgs[fl]!, f, touched: ctl.isTouched(consumptionFieldIds[fl]!));
  bool warn(NightField fl) => r.msgs[fl]!.any((m) => m.kind == MsgKind.warn) && !shown(fl);
}

/// «Porciento que marca ahora» (batería deslizable y campo de 100 dp) y «Consumo de la casa».
class PctAndLoadFields extends StatelessWidget {
  const PctAndLoadFields({super.key, required this.r, required this.fmt, required this.ctl});
  final NightResult r;
  final Fmt fmt;
  final HomeCtl ctl;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final m = _Msgs(r, fmt, ctl);
    final pctValid = !r.errs.contains(NightField.pct);
    final a = pctValid ? r.pct.clamp(0, 100).toDouble() : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  showError: m.shown(NightField.pct),
                  onChanged: (v) => s.update((s) => s.nPct = v),
                  onBlur: () => ctl.touch('nPct'),
                ),
              ),
            ),
          ],
        ),
        FieldMessages(m.msgs(NightField.pct)),
        if (pctValid)
          SwatchLegend([
            (hatchSwatch(c.rsv, c.rsv), l.legRsv(fmt.nf(r.reserve, 2))),
            (solidSwatch(c.amb), l.legUse(fmt.nf(math.max(0, a - r.reserve), 2))),
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
            msgs: m.msgs(NightField.load),
            showError: m.shown(NightField.load),
            warn: m.warn(NightField.load),
            hint: l.loadHint,
            onChanged: (v) => s.update((s) => s.nW = v),
            onBlur: () => ctl.touch('nW'),
          ),
        ),
      ],
    );
  }
}

/// «Más opciones»: pérdidas del inversor y reserva.
class MoreOptions extends StatelessWidget {
  const MoreOptions({super.key, required this.r, required this.fmt, required this.ctl});
  final NightResult r;
  final Fmt fmt;
  final HomeCtl ctl;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final m = _Msgs(r, fmt, ctl);
    final rsvParsed = parseNumber(s.rsv);

    void stepReserve(int dv) {
      var v = rsvParsed.isNumber ? rsvParsed.value : reserveDefault;
      v = math.max(reserveMin, math.min(reserveMax, (v.round() + dv).toDouble()));
      s.update((s) => s.rsv = '${v.round()}');
    }

    return Disclosure(
      icon: 'sliders',
      title: l.more,
      summary: l.moreS('${s.loss}', rsvParsed.isNumber ? s.rsv : '—'),
      open: ctl.moreOpen,
      onToggle: () => ctl.set((c) => c.moreOpen = !c.moreOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchRow(title: l.loss, hint: l.lossHint, value: s.loss, onChanged: (v) => s.update((s) => s.loss = v)),
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
                    showError: m.shown(NightField.reserve),
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
          FieldMessages(m.msgs(NightField.reserve)),
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
    );
  }
}

/// Veredicto con el botón «Probar con N W», que pone ese consumo en el campo compartido.
Widget verdictNotice(
  BuildContext context, {
  required Tone tone,
  required String title,
  required String text,
  int? tryW,
  String? tryLabel,
}) {
  final s = AppScope.read(context);
  final l = AppLocalizations.of(context);
  return Notice(
    tone: tone,
    title: title,
    text: text,
    extra: tryW == null
        ? null
        : Align(
            alignment: Alignment.centerLeft,
            child: SecondaryButton(
              label: tryLabel!,
              icon: 'bolt',
              small: true,
              onPressed: () {
                final w = '$tryW';
                s.update((s) => s.nW = w);
                showToast(context, l.trying(w));
              },
            ),
          ),
  );
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
