import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// Base táctil: foco con teclado, estado presionado y semántica de botón.
class Tap extends StatefulWidget {
  const Tap({
    super.key,
    required this.onTap,
    required this.builder,
    this.semanticLabel,
    this.toggled,
    this.selected,
    this.inGroup = false,
    this.focusNode,
    this.excludeChildSemantics = false,
  });
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool pressed, bool focused) builder;
  final String? semanticLabel;
  final bool? toggled, selected;
  final bool inGroup;
  final FocusNode? focusNode;
  final bool excludeChildSemantics;

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _pressed = false, _focused = false;

  void _activate() {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: widget.toggled == null,
      enabled: enabled,
      toggled: widget.toggled,
      selected: widget.selected,
      inMutuallyExclusiveGroup: widget.inGroup ? true : null,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: enabled ? _activate : null,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: enabled ? _activate : null,
          child: widget.builder(context, _pressed, _focused),
        ),
      ),
    );
  }
}

/// Borde discontinuo (estado deshabilitado).
class DashedBorder extends StatelessWidget {
  const DashedBorder({super.key, required this.child, required this.color, required this.radius, this.width = 1.5});
  final Widget child;
  final Color color;
  final double radius, width;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(foregroundPainter: _DashPainter(color, radius, width), child: child);
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius, this.width);
  final Color color;
  final double radius, width;
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius((Offset.zero & size).deflate(width / 2), Radius.circular(radius));
    final src = Path()..addRRect(rr);
    final out = Path();
    for (final m in src.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        out.addPath(m.extractPath(d, d + 5), Offset.zero);
      }
    }
    canvas.drawPath(
      out,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// Anillo de foco de 3 dp separado 3 dp (DESIGN §4).
Widget focusRing(BuildContext context, {required bool focused, required double radius, required Widget child}) {
  if (!focused) return child;
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius + 3),
      border: Border.all(color: context.colors.focus, width: 3),
    ),
    child: child,
  );
}

/// Botón principal: alto 56, radio 16, fondo ámbar.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed});
  final String label;
  final String? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onPressed,
      builder: (context, pressed, focused) {
        final disabled = onPressed == null;
        final fg = disabled ? c.dis : (pressed ? c.bg : c.onAmb);
        final body = Container(
          constraints: const BoxConstraints(minHeight: AppHeight.button),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? c.disBg : (pressed ? c.ambTx : c.amb),
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[AppIcon(icon!, size: 22, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(fontSize: 17, color: fg),
                ),
              ),
            ],
          ),
        );
        return focusRing(
          context,
          focused: focused,
          radius: AppRadius.button,
          child: disabled ? DashedBorder(color: c.dis, radius: AppRadius.button, child: body) : body,
        );
      },
    );
  }
}

/// Botón secundario: borde de 2 dp. [small] mide 48 de alto.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.icon, this.onPressed, this.small = false});
  final String label;
  final String? icon;
  final VoidCallback? onPressed;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onPressed,
      builder: (context, pressed, focused) {
        final disabled = onPressed == null;
        final fg = disabled ? c.dis : c.tx;
        final body = Container(
          constraints: BoxConstraints(minHeight: small ? AppHeight.buttonSmall : AppHeight.button),
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 16, vertical: 6),
          decoration: BoxDecoration(
            color: pressed ? c.sf2 : null,
            borderRadius: BorderRadius.circular(small ? 14 : AppRadius.button),
            border: disabled ? null : Border.all(color: c.tx, width: 2),
          ),
          child: Row(
            mainAxisSize: small ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[AppIcon(icon!, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(label, style: AppText.label.copyWith(color: fg)),
              ),
            ],
          ),
        );
        return focusRing(
          context,
          focused: focused,
          radius: AppRadius.button,
          child: disabled ? DashedBorder(color: c.dis, radius: AppRadius.button, child: body) : body,
        );
      },
    );
  }
}

/// Botón de texto subrayado.
class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onPressed,
      builder: (context, pressed, focused) => focusRing(
        context,
        focused: focused,
        radius: 8,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppHeight.minTouch, minWidth: AppHeight.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.label.copyWith(
              color: onPressed == null ? c.dis : c.tx,
              decoration: onPressed == null ? null : TextDecoration.underline,
              decorationColor: c.tx,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de solo ícono, 48 × 48, con etiqueta para TalkBack.
class IconBtn extends StatelessWidget {
  const IconBtn({super.key, required this.icon, required this.label, this.onPressed, this.size = 48});
  final String icon, label;
  final VoidCallback? onPressed;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Tap(
        onTap: onPressed,
        semanticLabel: label,
        builder: (context, pressed, focused) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pressed ? c.sf2 : null,
            shape: BoxShape.circle,
            border: focused ? Border.all(color: c.focus, width: 3) : null,
          ),
          child: AppIcon(icon, color: onPressed == null ? c.dis : c.tx),
        ),
      ),
    );
  }
}

/// Selector segmentado: la opción elegida va invertida y con ✓.
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value, required this.onChanged, this.label});
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      label: label,
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.sf2,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: c.ln, width: 1.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (v, text) in options)
                Expanded(
                  child: Tap(
                    onTap: onChanged == null ? null : () => onChanged!(v),
                    selected: v == value,
                    inGroup: true,
                    builder: (context, pressed, focused) {
                      final sel = v == value;
                      final fg = onChanged == null ? c.dis : (sel ? c.bg : c.tx);
                      return Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel ? (onChanged == null ? c.dis : c.tx) : (pressed ? c.ln2 : null),
                          borderRadius: BorderRadius.circular(AppRadius.segment),
                          border: focused ? Border.all(color: c.focus, width: 2.5) : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (sel) ...[AppIcon('check', size: 18, color: fg, stroke: 2.5), const SizedBox(width: 6)],
                            Flexible(
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: (sel ? AppText.label : AppText.body).copyWith(
                                  fontSize: 15,
                                  height: 1.25,
                                  color: fg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interruptor de 56 × 32 con su etiqueta y ayuda; toda la fila es táctil.
class SwitchRow extends StatelessWidget {
  const SwitchRow({super.key, required this.title, this.hint, required this.value, required this.onChanged});
  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tap(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      toggled: value,
      semanticLabel: hint == null ? title : '$title. $hint',
      excludeChildSemantics: true,
      builder: (context, pressed, focused) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppText.label.copyWith(color: onChanged == null ? c.dis : c.tx)),
                    if (hint != null) ...[
                      const SizedBox(height: 2),
                      Text(hint!, style: AppText.hint.copyWith(color: c.tx2)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SwitchTrack(on: value, focused: focused, disabled: onChanged == null),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({required this.on, required this.focused, required this.disabled});
  final bool on, focused, disabled;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 56,
      height: 32,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: on ? (disabled ? c.dis : c.tx) : c.sf2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: on ? Colors.transparent : (disabled ? c.dis : c.ln), width: 1.5),
        boxShadow: focused ? [BoxShadow(color: c.focus, spreadRadius: 3)] : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: on ? c.bg : c.ln, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: on ? AppIcon('check', size: 16, color: c.tx, stroke: 2.5) : null,
        ),
      ),
    );
    return track;
  }
}

/// Fila plegable: línea arriba, ícono, título, resumen y flecha que gira.
class Disclosure extends StatelessWidget {
  const Disclosure({
    super.key,
    required this.icon,
    required this.title,
    this.summary,
    required this.open,
    required this.onToggle,
    required this.child,
  });
  final String icon, title;
  final String? summary;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: c.ln2),
        Semantics(
          expanded: open,
          child: Tap(
            onTap: onToggle,
            builder: (context, pressed, focused) => Container(
              constraints: const BoxConstraints(minHeight: AppHeight.disclosureRow),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: focused ? Border.all(color: c.focus, width: 2.5) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  AppIcon(icon, color: c.tx2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.label.copyWith(color: c.tx)),
                        if (summary != null) Text(summary!, style: AppText.hint.copyWith(color: c.tx2)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: AppIcon('down', color: c.tx),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (open) Padding(padding: const EdgeInsets.only(top: 4, bottom: 8), child: child),
      ],
    );
  }
}
