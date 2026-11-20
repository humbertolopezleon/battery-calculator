import 'package:material_ui/material_ui.dart';

import '../../app/presenter.dart';
import '../../domain/calculator.dart' show NightTrackGeometry;
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';
import 'battery.dart';
import 'controls.dart';

/// Colores (principal, fondo) e ícono de cada tono.
(Color, Color, String) toneStyle(AppColors c, Tone t) => switch (t) {
  Tone.ok => (c.ok, c.okBg, 'check'),
  Tone.bad || Tone.err => (c.bad, c.badBg, 'alert'),
  Tone.info => (c.inf, c.infBg, 'plug'),
  Tone.warn => (c.warn, c.warnBg, 'warn'),
  Tone.neutral => (c.tx2, c.sf2, 'bolt'),
};

/// Tarjeta (fondo sf, radio 22).
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: context.colors.sf, borderRadius: BorderRadius.circular(AppRadius.card)),
    padding: padding,
    child: child,
  );
}

/// Encabezado de la tarjeta de resultado, con el botón de compartir.
class Kicker extends StatelessWidget {
  const Kicker({super.key, required this.icon, required this.text, this.shareLabel, this.onShare});
  final String icon, text;
  final String? shareLabel;
  final VoidCallback? onShare;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        AppIcon(icon, size: 18, color: c.tx2),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppText.hint.copyWith(fontWeight: FontWeight.w700, color: c.tx2),
          ),
        ),
        if (onShare != null)
          Transform.translate(
            offset: const Offset(10, 0),
            child: IconBtn(icon: 'share', label: shareLabel!, onPressed: onShare),
          )
        else
          const SizedBox(height: 48),
      ],
    );
  }
}

/// Círculo de color sólido con el ícono en el color del fondo.
class Badge extends StatelessWidget {
  const Badge({super.key, required this.tone, this.size = 36, this.icon});
  final Tone tone;
  final double size;
  final String? icon;
  @override
  Widget build(BuildContext context) {
    final (fg, bg, ic) = toneStyle(context.colors, tone);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: AppIcon(icon ?? ic, size: size * 0.56, color: bg, stroke: 2.5),
    );
  }
}

/// Aviso o veredicto (radio 16): círculo, título del color del tipo y texto.
class Notice extends StatelessWidget {
  const Notice({super.key, required this.tone, required this.title, required this.text, this.extra});
  final Tone tone;
  final String title, text;
  final Widget? extra;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg, _) = toneStyle(c, tone);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.notice)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Badge(tone: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading.copyWith(color: fg)),
                const SizedBox(height: 2),
                Text(text, style: AppText.support.copyWith(color: c.tx)),
                if (extra != null) ...[const SizedBox(height: 8), extra!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de estado: vacío, corregir, en la reserva, sin consumo, ya cargada.
class StateCard extends StatelessWidget {
  const StateCard({super.key, required this.data, this.goLabel, this.onGo});
  final StateCardData data;
  final String? goLabel;
  final VoidCallback? onGo;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = data.usePlug
        ? 'plug'
        : data.useBolt
        ? 'bolt'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Badge(tone: data.tone, size: 44, icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: AppText.sheetTitle.copyWith(color: c.tx)),
                  const SizedBox(height: 4),
                  Text(data.text, style: AppText.body.copyWith(color: c.tx2)),
                ],
              ),
            ),
          ],
        ),
        if (onGo != null) ...[
          const SizedBox(height: 12),
          SecondaryButton(label: goLabel!, icon: 'down', small: true, onPressed: onGo),
        ],
      ],
    );
  }
}

/// Cifras: cuadrícula de N columnas, o filas en el modo estrecho.
class Figures extends StatelessWidget {
  const Figures(this.items, {super.key, this.narrow = false});
  final List<Figure> items;
  final bool narrow;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final valueStyle = AppText.label.copyWith(color: c.tx, height: 1.25);
    final labelStyle = AppText.small.copyWith(color: c.tx2);
    if (narrow) {
      return Container(
        decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            for (final (i, f) in items.indexed) ...[
              if (i > 0) Divider(height: 1, color: c.ln2),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(f.label, style: labelStyle)),
                    const SizedBox(width: 8),
                    Text(f.value, style: valueStyle),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, f) in items.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Semantics(
                container: true,
                label: '${f.value} ${f.label}',
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(f.value, style: valueStyle, softWrap: false),
                      ),
                      const SizedBox(height: 2),
                      Text(f.label, style: labelStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _legendIcon(LegendIcon i) => switch (i) {
  LegendIcon.moon => 'moon',
  LegendIcon.sun => 'sun',
  LegendIcon.battery => 'battery',
  LegendIcon.clock => 'clock',
  LegendIcon.flag => 'flag',
  LegendIcon.none => '',
};

/// Leyenda de una regla: 3 columnas (izquierda, centro, derecha) o filas en el modo estrecho.
class Legend extends StatelessWidget {
  const Legend(this.items, {super.key, this.narrow = false});
  final List<LegendItem> items;
  final bool narrow;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lab = AppText.small.copyWith(color: c.tx2);
    final val = AppText.support.copyWith(fontWeight: FontWeight.w700, color: c.tx);
    Widget label(LegendItem it) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (it.icon != LegendIcon.none) ...[
          AppIcon(_legendIcon(it.icon), size: 15, color: c.tx2),
          const SizedBox(width: 3),
        ],
        Flexible(child: Text(it.label, style: lab)),
      ],
    );
    if (narrow) {
      return Column(
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: label(it)),
                  Text(it.value, style: val),
                ],
              ),
            ),
        ],
      );
    }
    final n = items.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, it) in items.indexed)
          Expanded(
            child: Column(
              crossAxisAlignment: i == 0
                  ? CrossAxisAlignment.start
                  : i == n - 1
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
              children: [
                label(it),
                Text(
                  it.value,
                  style: val,
                  textAlign: i == 0
                      ? TextAlign.start
                      : i == n - 1
                      ? TextAlign.end
                      : TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Regla de la noche: relleno ámbar, marcador de fin (o flecha si son días), sol y tramo que falta.
/// En Duración, el círculo lleva la bandera de la hora de fin en lugar del sol ([markerIcon]).
class NightTrack extends StatelessWidget {
  const NightTrack({super.key, required this.g, required this.reaches, this.markerIcon = 'sun'});
  final NightTrackGeometry g;
  final bool reaches;
  final String markerIcon;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        height: 40,
        child: LayoutBuilder(
          builder: (context, cons) {
            const sunD = 38.0;
            final w = cons.maxWidth - sunD / 2;
            double x(double pct) => w * pct / 100;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  width: w,
                  top: 13,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.track,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: c.ln, width: 1.5),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: x(g.fill),
                  top: 13,
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: c.amb, borderRadius: BorderRadius.circular(7)),
                  ),
                ),
                if (!reaches && g.sunX > g.fill)
                  Positioned(
                    left: x(g.fill),
                    width: x(g.sunX - g.fill),
                    top: 14.5,
                    height: 11,
                    child: CustomPaint(painter: HatchPainter(c.rsv)),
                  ),
                if (g.days)
                  Positioned(
                    left: w - 14,
                    top: 8,
                    child: AppIcon('right', size: 24, color: c.tx, stroke: 3),
                  )
                else
                  Positioned(
                    left: x(g.fill) - 2,
                    top: 6,
                    width: 4,
                    height: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: c.tx, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                Positioned(
                  left: x(g.sunX) - sunD / 2,
                  top: 1,
                  width: sunD,
                  height: sunD,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.sf,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.tx, width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: AppIcon(markerIcon, size: 20, color: c.tx),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Regla de carga: tramo rápido verde sólido y tramo lento rayado, con marcas en el 90% y al final.
class ChargeTrack extends StatelessWidget {
  const ChargeTrack({super.key, required this.fastShare, required this.twoStretches});
  final double fastShare;
  final bool twoStretches;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        height: 28,
        child: LayoutBuilder(
          builder: (context, cons) {
            final w = cons.maxWidth - 2;
            final fx = w * fastShare / 100;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  width: w,
                  top: 7,
                  height: 14,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.track,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: c.ln, width: 1.5),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: fx,
                  top: 7,
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.chg,
                      borderRadius: fastShare >= 100
                          ? BorderRadius.circular(7)
                          : const BorderRadius.horizontal(left: Radius.circular(7)),
                    ),
                  ),
                ),
                if (fastShare < 100)
                  Positioned(
                    left: fx,
                    width: w - fx,
                    top: 8.5,
                    height: 11,
                    child: CustomPaint(painter: HatchPainter(c.chg, stripe: 4, gap: 4)),
                  ),
                if (twoStretches)
                  Positioned(
                    left: fx - 1.5,
                    top: 0,
                    width: 3,
                    height: 28,
                    child: ColoredBox(color: c.tx),
                  ),
                Positioned(
                  left: w - 2,
                  top: 0,
                  width: 4,
                  height: 28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: c.tx, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Franja de respuesta (56 dp): ícono del modo, texto y píldora de estado.
class AnswerStrip extends StatelessWidget {
  const AnswerStrip({super.key, required this.data, required this.modeIcon});
  final StripData data;
  final String modeIcon;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg, _) = toneStyle(c, data.tone);
    final pillIcon = switch (data.tone) {
      Tone.ok => 'check',
      Tone.info => 'clock',
      _ => 'alert',
    };
    return Semantics(
      container: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppHeight.answerStrip),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: c.sf,
          border: Border(bottom: BorderSide(color: c.ln2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            AppIcon(data.tone == Tone.err ? 'alertc' : modeIcon, color: c.tx2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(data.text, style: AppText.heading.copyWith(color: c.tx)),
            ),
            if (data.tag != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(pillIcon, size: 16, color: fg, stroke: 2.5),
                    const SizedBox(width: 4),
                    Text(
                      data.tag!,
                      style: AppText.hint.copyWith(fontWeight: FontWeight.w700, color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
