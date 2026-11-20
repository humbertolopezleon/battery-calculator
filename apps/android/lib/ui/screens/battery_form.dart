import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../domain/calculator.dart';
import '../../domain/formatters.dart';
import '../../domain/number_parser.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';

/// Borrador de la batería: se edita en la primera vez o en la hoja, y se guarda al aceptar.
class BatteryDraft extends ChangeNotifier {
  BatteryDraft.from(AppState s) : mode = s.batMode, capTxt = s.capTxt, volt = s.volt, ahTxt = s.ahTxt;

  BatteryMode mode;
  String capTxt, volt, ahTxt;
  final touched = <BatteryField>{};

  BatteryResult result(String sep) =>
      batteryCapacity(mode: mode, capTxt: capTxt, voltsTxt: volt, ahTxt: ahTxt, decimalSep: sep);

  void set(void Function(BatteryDraft d) f) {
    f(this);
    notifyListeners();
  }

  /// Guarda en el estado si la capacidad es válida.
  bool commit(AppState s, String sep) {
    final r = result(sep);
    if (!r.ok) return false;
    s.update((s) {
      s.batMode = mode;
      s.capTxt = capTxt;
      s.volt = volt;
      s.ahTxt = ahTxt;
      s.cap = r.cap;
    });
    return true;
  }
}

const _presets = [5.12, 10.24, 15.0];

/// Selector kWh / V·Ah, atajos y campos (DESIGN §3.1, §3.5, §3.6).
class BatteryForm extends StatelessWidget {
  const BatteryForm({super.key, required this.draft, this.firstRun = false});
  final BatteryDraft draft;
  final bool firstRun;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final sep = lang == 'en' ? '.' : ',';
    String nf(double v) => NumberFormatter(lang == 'en' ? 'en' : 'es').nf(v, 2);
    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final r = draft.result(sep);
        final cur = parseNumber(draft.capTxt).value;
        List<UiMsg> msgsFor(BatteryField f) => [
          if (r.errField == f && draft.touched.contains(f)) (MsgKind.err, r.errCode == MsgCode.gt0 ? l.gt0 : l.numBad),
          if (r.warnField == f) (MsgKind.warn, l.weird),
        ];
        bool errShown(BatteryField f) => r.errField == f && draft.touched.contains(f);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Segmented<BatteryMode>(
              label: l.batHow,
              options: [(BatteryMode.kwh, l.modeKwh), (BatteryMode.voltsAh, l.modeAh)],
              value: draft.mode,
              onChanged: (m) => draft.set((d) => d.mode = m),
            ),
            const SizedBox(height: 16),
            if (draft.mode == BatteryMode.kwh) ...[
              FieldLabel(l.common, small: true),
              Row(
                children: [
                  for (final (i, p) in _presets.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _Preset(
                        value: nf(p),
                        selected: (cur - p).abs() < 1e-9,
                        onTap: () => draft.set((d) {
                          d.capTxt = nf(p);
                          d.touched.remove(BatteryField.cap);
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              NumberField(
                label: firstRun ? l.otherCap : l.capacity,
                value: draft.capTxt,
                unit: 'kWh',
                placeholder: l.example(lang == 'en' ? '10.24' : '10,24'),
                msgs: msgsFor(BatteryField.cap),
                showError: errShown(BatteryField.cap),
                warn: r.warnField == BatteryField.cap,
                hint: l.capHint,
                onChanged: (v) => draft.set((d) => d.capTxt = v),
                onBlur: () => draft.set((d) => d.touched.add(BatteryField.cap)),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NumberField(
                      label: l.volts,
                      value: draft.volt,
                      unit: 'V',
                      showError: errShown(BatteryField.volts),
                      onChanged: (v) => draft.set((d) => d.volt = v),
                      onBlur: () => draft.set((d) => d.touched.add(BatteryField.volts)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NumberField(
                      label: l.ah,
                      value: draft.ahTxt,
                      unit: 'Ah',
                      showError: errShown(BatteryField.ah),
                      warn: r.warnField == BatteryField.ah,
                      onChanged: (v) => draft.set((d) => d.ahTxt = v),
                      onBlur: () => draft.set((d) => d.touched.add(BatteryField.ah)),
                    ),
                  ),
                ],
              ),
              FieldMessages([...msgsFor(BatteryField.volts), ...msgsFor(BatteryField.ah)]),
              Hint(l.ahHint),
              if (r.ok) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: c.infBg, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: c.inf, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: AppIcon('eq', size: 18, color: c.infBg, stroke: 2.5),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: l.ahResultPrefix),
                                TextSpan(
                                  text: '${nf(r.cap!)} kWh',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            style: AppText.body.copyWith(color: c.tx),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _Preset extends StatelessWidget {
  const _Preset({required this.value, required this.selected, required this.onTap});
  final String value;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onTap,
      selected: selected,
      semanticLabel: '$value kWh',
      excludeChildSemantics: true,
      builder: (context, pressed, focused) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: AppHeight.preset),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? c.sel : (pressed ? c.sf2 : c.sf),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: focused ? c.focus : (selected ? c.tx : c.ln),
                width: selected || focused ? 2.5 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: AppText.heading.copyWith(color: c.tx)),
                Text('kWh', style: AppText.small.copyWith(color: c.tx2)),
              ],
            ),
          ),
          if (selected)
            Positioned(
              right: -7,
              top: -7,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: c.tx,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.sf, width: 2),
                ),
                alignment: Alignment.center,
                child: AppIcon('check', size: 14, color: c.bg, stroke: 3),
              ),
            ),
        ],
      ),
    );
  }
}
