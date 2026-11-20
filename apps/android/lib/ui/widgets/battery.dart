import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Rayado a 135° (tokens.json → patterns): [stripe] dp de color y [gap] dp transparente.
class HatchPainter extends CustomPainter {
  const HatchPainter(this.color, {this.stripe = 3, this.gap = 4, this.radius = 0});
  final Color color;
  final double stripe, gap, radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    final p = Paint()
      ..color = color
      ..strokeWidth = stripe;
    final step = (stripe + gap) * math.sqrt2;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HatchPainter old) => old.color != color;
}

/// Batería deslizable (DESIGN §4). En modo noche, una manija ([a]) con la reserva rayada.
/// En modo carga, dos manijas ([a] = ahora, [b] = cargar hasta) que no se cruzan.
class BatterySlider extends StatefulWidget {
  const BatterySlider.night({super.key, required this.a, required this.reserve, required this.onA, required this.label})
    : charge = false,
      b = 0,
      onB = null,
      labelB = null;

  const BatterySlider.charge({
    super.key,
    required this.a,
    required this.b,
    required this.onA,
    required this.onB,
    required this.label,
    required this.labelB,
  }) : charge = true,
       reserve = 0;

  final bool charge;
  final double a, b, reserve;
  final ValueChanged<int> onA;
  final ValueChanged<int>? onB;
  final String label;
  final String? labelB;

  @override
  State<BatterySlider> createState() => _BatterySliderState();
}

class _BatterySliderState extends State<BatterySlider> {
  static const _thumbW = 16.0;
  static const _capW = 7.0;
  int _drag = 0; // 0 = a, 1 = b
  final _focusA = FocusNode(), _focusB = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusA.addListener(() => setState(() {}));
    _focusB.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusA.dispose();
    _focusB.dispose();
    super.dispose();
  }

  double _clamp(double v) => v.isFinite ? v.clamp(0, 100).toDouble() : 0;

  void _set(int which, double raw) {
    var v = raw.round().clamp(0, 100);
    if (widget.charge) {
      if (which == 0 && v > widget.b) v = widget.b.round();
      if (which == 1 && v < widget.a) v = widget.a.round();
    }
    if (which == 0) {
      if (v != widget.a.round()) {
        HapticFeedback.selectionClick();
        widget.onA(v);
      }
    } else if (v != widget.b.round()) {
      HapticFeedback.selectionClick();
      widget.onB!(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth;
        // Cuerpo: ancho total menos el borne. El interior tiene 3 dp de borde + 5 dp de relleno.
        final bodyW = w - _capW;
        const inset = 8.0;
        final innerW = math.max(1.0, bodyW - 2 * inset);
        double xOf(double pct) => inset + innerW * _clamp(pct) / 100;
        double pctOf(double x) => (x - inset) / innerW * 100;
        final a = _clamp(widget.a), b = _clamp(widget.b);

        void start(Offset p) {
          if (widget.charge) {
            final da = (p.dx - xOf(a)).abs(), db = (p.dx - xOf(b)).abs();
            _drag = db < da || (db == da && p.dx > xOf(a)) ? 1 : 0;
          } else {
            _drag = 0;
          }
          _set(_drag, pctOf(p.dx));
        }

        Widget fills() {
          final inner = <Widget>[];
          if (!widget.charge) {
            final r = _clamp(widget.reserve);
            inner.add(
              Positioned(
                left: 0,
                width: innerW * r / 100,
                top: 0,
                bottom: 0,
                child: CustomPaint(painter: HatchPainter(c.rsv, radius: 4)),
              ),
            );
            if (a > r) {
              inner.add(
                Positioned(
                  left: innerW * r / 100,
                  width: innerW * (a - r) / 100,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: c.amb, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              );
            }
          } else {
            inner.add(
              Positioned(
                left: 0,
                width: innerW * a / 100,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: c.amb, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            );
            if (b > a) {
              inner.add(
                Positioned(
                  left: innerW * a / 100,
                  width: innerW * (b - a) / 100,
                  top: 0,
                  bottom: 0,
                  child: CustomPaint(painter: HatchPainter(c.chg, stripe: 4, gap: 4)),
                ),
              );
            }
          }
          return Stack(clipBehavior: Clip.none, children: inner);
        }

        Widget thumb(double pct, bool focused) => Positioned(
          left: xOf(pct) - 24,
          top: 0,
          width: 48,
          height: AppHeight.batteryThumb,
          child: Center(
            child: Container(
              width: _thumbW,
              height: AppHeight.batteryThumb,
              decoration: BoxDecoration(
                color: c.sf,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: focused ? c.focus : c.tx, width: 3),
                boxShadow: focused ? [BoxShadow(color: c.focus.withValues(alpha: 0.35), spreadRadius: 4)] : null,
              ),
            ),
          ),
        );

        Widget sem(int which, double v, String label, FocusNode node) => Semantics(
          slider: true,
          label: label,
          value: '${v.round()}%',
          increasedValue: '${math.min(100, v.round() + 1)}%',
          decreasedValue: '${math.max(0, v.round() - 1)}%',
          onIncrease: () => _set(which, v + 1),
          onDecrease: () => _set(which, v - 1),
          child: Focus(
            focusNode: node,
            onKeyEvent: (n, e) {
              if (e is KeyUpEvent) return KeyEventResult.ignored;
              if (e.logicalKey == LogicalKeyboardKey.arrowRight || e.logicalKey == LogicalKeyboardKey.arrowUp) {
                _set(which, v + 1);
                return KeyEventResult.handled;
              }
              if (e.logicalKey == LogicalKeyboardKey.arrowLeft || e.logicalKey == LogicalKeyboardKey.arrowDown) {
                _set(which, v - 1);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: const SizedBox.expand(),
          ),
        );

        return SizedBox(
          height: AppHeight.batteryThumb,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapDown: (d) => start(d.localPosition),
            onHorizontalDragStart: (d) => start(d.localPosition),
            onHorizontalDragUpdate: (d) => _set(_drag, pctOf(d.localPosition.dx)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cuerpo con borde de 3 dp, radio 12, alto 56.
                Positioned(
                  left: 0,
                  width: bodyW,
                  top: (AppHeight.batteryThumb - AppHeight.battery) / 2,
                  height: AppHeight.battery,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.sf,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.tx, width: 3),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ExcludeSemantics(child: fills()),
                  ),
                ),
                // Borne de 7 × 22.
                Positioned(
                  left: bodyW,
                  width: _capW,
                  top: (AppHeight.batteryThumb - 22) / 2,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.tx,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                    ),
                  ),
                ),
                thumb(a, _focusA.hasFocus),
                if (widget.charge) thumb(b, _focusB.hasFocus),
                Positioned.fill(
                  child: Row(
                    children: widget.charge
                        ? [
                            Expanded(child: sem(0, a, widget.label, _focusA)),
                            Expanded(child: sem(1, b, widget.labelB!, _focusB)),
                          ]
                        : [Expanded(child: sem(0, a, widget.label, _focusA))],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Leyenda con muestras de 16 dp debajo de la batería.
class SwatchLegend extends StatelessWidget {
  const SwatchLegend(this.items, {super.key});

  /// (muestra, texto).
  final List<(Widget, String)> items;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final (sw, t) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: 16, child: sw),
              const SizedBox(width: 6),
              Flexible(
                child: Text(t, style: AppText.hint.copyWith(color: context.colors.tx2)),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget solidSwatch(Color c) => DecoratedBox(
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
);

Widget hatchSwatch(Color c, Color border, {double stripe = 3, double gap = 4}) => DecoratedBox(
  decoration: BoxDecoration(
    border: Border.all(color: c, width: 1.5),
    borderRadius: BorderRadius.circular(4),
  ),
  child: CustomPaint(
    painter: HatchPainter(c, stripe: stripe, gap: gap, radius: 3),
  ),
);
