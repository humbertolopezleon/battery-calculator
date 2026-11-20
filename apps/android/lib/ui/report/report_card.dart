import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/result.dart';

/// Ancho lógico del reporte. Se captura con `pixelRatio` 3 → 1080 px (SPEC §7).
const reportLogicalWidth = 360.0;
const reportPixelRatio = 3.0;

/// Contenido del reporte: lo que se muestra en la tarjeta, más los datos usados.
class ReportData {
  ReportData.night(NightView v, AppState s, Fmt f, this.when)
    : night = true,
      lead = v.r.load.isFinite
          ? '${f.lang == 'es' ? 'Con' : 'Using'} ${f.nf(v.r.load, 2)} W, ${_lower(v.lead!)}'
          : v.lead!,
      big = v.big!,
      sub = null,
      verdict = v.verdictTitle == null ? null : (v.verdictTone!, v.verdictTitle!, v.verdictText!),
      nightView = v,
      chargeView = null,
      figures = v.figures,
      steps = v.steps,
      data = [
        (f.l.dBat, '${f.nf(s.cap!, 2)} kWh'),
        (f.l.dLevel, '${f.nf(v.r.pct, 2)}%'),
        (f.l.dLoad, '${f.nf(v.r.load, 2)} W'),
        (f.l.dAt, v.r.now == null ? '—' : f.t.format(v.r.now!)),
        (f.l.dSun, v.r.sun == null ? '—' : f.t.format(v.r.sun!)),
        (f.l.dRsv, '${f.nf(v.r.reserve, 2)}%'),
        (f.l.dLoss, s.loss ? f.l.lossYes : f.l.lossNo),
      ],
      foot = f.l.footN(f.nf(v.r.reserve, 2));

  ReportData.charge(ChargeView v, AppState s, Fmt f, this.when)
    : night = false,
      lead = v.lead!,
      big = v.big!,
      sub = v.sub,
      verdict = (Tone.info, v.gridTitle!, v.gridText!),
      nightView = null,
      chargeView = v,
      figures = v.figures,
      steps = v.steps,
      data = [
        (f.l.dBat, '${f.nf(s.cap!, 2)} kWh'),
        (f.l.dLevel, '${f.nf(v.r.pct, 2)}%'),
        (f.l.dTgt, '${f.nf(v.r.target, 2)}%'),
        (f.l.dPow, '${f.nf(v.r.watts, 2)} W'),
        (f.l.dAt, v.r.now == null ? '—' : f.t.format(v.r.now!)),
      ],
      foot = f.l.footC;

  static String _lower(String s) => s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  final bool night;
  final String lead, big;
  final String? sub;
  final (Tone, String, String)? verdict;
  final NightView? nightView;
  final ChargeView? chargeView;
  final List<Figure> figures;
  final List<String> steps;
  final List<(String, String)> data;
  final String foot;
  final DateTime when;

  String fileName(AppLocalizations l) => '${night ? l.fileN : l.fileC}.png';
}

/// La imagen del reporte, siempre en tema claro y sin depender de la letra del teléfono.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.data, required this.fmt});
  final ReportData data;
  final Fmt fmt;

  @override
  Widget build(BuildContext context) {
    const c = AppColors.light;
    final l = fmt.l;
    final mq = MediaQuery.of(context);
    final date = DateFormat('d MMM y', fmt.lang).format(data.when);
    final time = fmt.t.format(data.when.hour * 60 + data.when.minute);
    TextStyle st(double size, {bool bold = false, Color color = const Color(0xFF122033), double h = 1.3}) => TextStyle(
      fontFamily: appFont,
      fontSize: size,
      height: h,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );
    const pad = 64 / 3;
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.noScaling),
      child: Theme(
        data: buildTheme(c, Brightness.light),
        child: DefaultTextStyle(
          style: st(14),
          child: Container(
            width: reportLogicalWidth,
            color: c.bg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Cabecera azul noche.
                Container(
                  color: const Color(0xFF0D1626),
                  padding: const EdgeInsets.fromLTRB(pad, 16, pad, 16),
                  child: Row(
                    children: [
                      const AppLogo(size: 104 / 3, radius: 26 / 3),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.rTitleN, style: st(50 / 3, bold: true, color: const Color(0xFFF2F5F9))),
                            Text(data.night ? l.rSubN : l.rSubC, style: st(34 / 3, color: const Color(0xFFF6BC5E))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(date, style: st(28 / 3, color: const Color(0xFFB4C0D0))),
                          Text(time, style: st(28 / 3, color: const Color(0xFFB4C0D0))),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(pad, 16, pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Frase de entrada y respuesta grande.
                      Text(data.lead, style: st(42 / 3, color: c.tx2)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.big,
                          style: st(
                            data.big.length > 12 ? 110 / 3 : 156 / 3,
                            bold: true,
                            h: 1.1,
                          ).copyWith(letterSpacing: -0.7),
                        ),
                      ),
                      if (data.sub != null) Text(data.sub!, style: st(40 / 3, bold: true)),
                      const SizedBox(height: 12),
                      // 3. Veredicto o aviso de la red.
                      if (data.verdict != null)
                        Notice(tone: data.verdict!.$1, title: data.verdict!.$2, text: data.verdict!.$3),
                      // 4. Regla.
                      if (data.nightView?.r.track != null) ...[
                        const SizedBox(height: 14),
                        NightTrack(g: data.nightView!.r.track!, reaches: data.nightView!.r.verdict!.reaches),
                        const SizedBox(height: 6),
                        Legend(data.nightView!.legend!),
                      ],
                      if (data.chargeView?.legend != null) ...[
                        const SizedBox(height: 14),
                        ChargeTrack(
                          fastShare: data.chargeView!.r.fastShare,
                          twoStretches: data.chargeView!.r.twoStretches,
                        ),
                        const SizedBox(height: 6),
                        Legend(data.chargeView!.legend!),
                      ],
                      const SizedBox(height: 14),
                      // 5. Cifras.
                      Figures(data.figures),
                      const SizedBox(height: 16),
                      // 6. Datos usados y Así se calcula.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(l.dataUsed, style: st(36 / 3, bold: true)),
                                const SizedBox(height: 6),
                                for (final (k, v) in data.data)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: c.ln2)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(k, style: st(10, color: c.tx2)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(v, style: st(10, bold: true)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(l.howR, style: st(36 / 3, bold: true)),
                                const SizedBox(height: 6),
                                for (final (i, s) in data.steps.indexed)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 15,
                                          height: 15,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(color: c.sf2, shape: BoxShape.circle),
                                          child: Text('${i + 1}', style: st(8, bold: true, h: 1)),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(child: Text(s, style: st(29 / 3))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 7. Nota y pie.
                      Text(data.foot, style: st(10, color: c.tx2)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const AppLogo(size: 16, radius: 4),
                          const SizedBox(width: 6),
                          Text('${l.appName} · ${l.offline.toLowerCase()}', style: st(28 / 3, color: c.tx2)),
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Para TalkBack: el reporte se describe con su respuesta.
String reportSemantics(ReportData d) => '${d.lead} ${d.big}';
