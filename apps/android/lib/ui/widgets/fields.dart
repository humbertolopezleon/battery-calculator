import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/calculator.dart' show MsgKind;
import '../../domain/number_parser.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';
import 'controls.dart';

/// Etiqueta de campo (16 sp, negrita), con ícono opcional.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.icon, this.small = false});
  final String text;
  final String? icon;
  final bool small;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 20, color: c.tx), const SizedBox(width: 8)],
          Expanded(
            child: Text(
              text,
              style: small ? AppText.label.copyWith(fontSize: 15, color: c.tx2) : AppText.label.copyWith(color: c.tx),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto de ayuda (14 sp, tx2).
class Hint extends StatelessWidget {
  const Hint(this.text, {super.key, this.center = false});
  final String text;
  final bool center;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: AppText.hint.copyWith(color: context.colors.tx2),
    ),
  );
}

/// Mensaje junto a un campo.
typedef UiMsg = (MsgKind, String);

/// Mensajes debajo de un campo: error, aviso (caja) o nota.
class FieldMessages extends StatelessWidget {
  const FieldMessages(this.msgs, {super.key});
  final List<UiMsg> msgs;
  @override
  Widget build(BuildContext context) {
    if (msgs.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (kind, text) in msgs)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: switch (kind) {
              MsgKind.err => Semantics(
                liveRegion: true,
                child: _MsgRow(icon: 'alertc', color: c.bad, text: text, bold: true),
              ),
              MsgKind.warn => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: c.warnBg, borderRadius: BorderRadius.circular(10)),
                child: _MsgRow(icon: 'warn', color: c.warn, text: text, bold: true),
              ),
              MsgKind.info => _MsgRow(icon: 'info', color: c.inf, text: text),
            },
          ),
      ],
    );
  }
}

class _MsgRow extends StatelessWidget {
  const _MsgRow({required this.icon, required this.color, required this.text, this.bold = false});
  final String icon;
  final Color color;
  final String text;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: AppIcon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: (bold ? AppText.hint.copyWith(fontWeight: FontWeight.w700) : AppText.hint).copyWith(color: color),
        ),
      ),
    ],
  );
}

/// Caja de campo: borde según el estado (normal, enfocado, error, aviso, deshabilitado).
class FieldBox extends StatelessWidget {
  const FieldBox({
    super.key,
    required this.child,
    this.focused = false,
    this.error = false,
    this.warn = false,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });
  final Widget child;
  final bool focused, error, warn, disabled;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderColor = error
        ? c.bad
        : warn
        ? c.warn
        : focused
        ? c.focus
        : c.ln;
    final width = error || warn || focused ? 2.0 : 1.5;
    final box = Container(
      constraints: const BoxConstraints(minHeight: AppHeight.field),
      padding: padding,
      decoration: BoxDecoration(
        color: disabled ? c.disBg : c.sf,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: disabled ? null : Border.all(color: borderColor, width: width),
        boxShadow: focused && !disabled ? [BoxShadow(color: c.infBg, spreadRadius: 4)] : null,
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    return disabled ? DashedBorder(color: c.dis, radius: AppRadius.field, child: box) : box;
  }
}

/// Filtra lo que no sea número y avisa cuando quitó algo.
class NumberInputFormatter extends TextInputFormatter {
  NumberInputFormatter(this.onFiltered);
  final VoidCallback onFiltered;
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final f = filterNumberInput(newValue.text);
    if (f == newValue.text) return newValue;
    if (newValue.text.replaceAll(RegExp(r'[\d.,]'), '').isNotEmpty) onFiltered();
    final off = (newValue.selection.baseOffset - (newValue.text.length - f.length)).clamp(0, f.length);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: off),
    );
  }
}

/// Campo numérico con unidad (DESIGN §4). Los errores se muestran después de salir del campo:
/// eso lo decide quien lo usa, pasando [showError].
class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.unit,
    this.label,
    this.labelIcon,
    this.smallLabel = false,
    this.hint,
    this.msgs = const [],
    this.showError = false,
    this.warn = false,
    this.placeholder,
    this.focusNode,
    this.onBlur,
    this.center = false,
    this.enabled = true,
    this.semanticLabel,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final String unit;
  final String? label, labelIcon, hint, placeholder, semanticLabel;
  final bool smallLabel;
  final List<UiMsg> msgs;
  final bool showError, warn, center, enabled;
  final FocusNode? focusNode;
  final VoidCallback? onBlur;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _ctl = TextEditingController(text: widget.value);
  FocusNode? _own;
  FocusNode get _focus => widget.focusNode ?? (_own ??= FocusNode());
  bool _filtered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(NumberField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _own)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
    if (widget.value != _ctl.text) {
      _ctl.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  void _onFocus() {
    if (!mounted) return;
    if (_focus.hasFocus) {
      // El campo queda centrado por encima del teclado (DESIGN §5).
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focus.hasFocus) {
          Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 150));
        }
      });
    } else {
      _filtered = false;
      widget.onBlur?.call();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _own?.dispose();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final msgs = [...widget.msgs, if (_filtered) (MsgKind.warn, AppLocalizations.of(context).onlyNums)];
    final hasWarn = widget.warn || _filtered;
    final field = FieldBox(
      focused: _focus.hasFocus,
      error: widget.showError,
      warn: hasWarn && !widget.showError,
      disabled: !widget.enabled,
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctl,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [NumberInputFormatter(() => setState(() => _filtered = true))],
              textAlign: widget.center ? TextAlign.center : TextAlign.start,
              style: AppText.fieldValue.copyWith(color: widget.enabled ? c.tx : c.dis),
              cursorColor: c.focus,
              scrollPadding: const EdgeInsets.all(120),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: AppText.fieldValue.copyWith(
                  color: c.tx2.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                semanticCounterText: '',
              ),
              onChanged: widget.onChanged,
            ),
          ),
          const SizedBox(width: 8),
          ExcludeSemantics(
            child: Text(widget.unit, style: AppText.label.copyWith(fontSize: 17, color: c.tx2)),
          ),
          if (widget.showError) ...[const SizedBox(width: 6), AppIcon('alertc', size: 18, color: c.bad)],
        ],
      ),
    );
    final semLabel = widget.semanticLabel ?? (widget.label == null ? null : '${widget.label} (${widget.unit})');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          ExcludeSemantics(
            child: FieldLabel(widget.label!, icon: widget.labelIcon, small: widget.smallLabel),
          ),
        MergeSemantics(
          child: Semantics(label: semLabel, child: field),
        ),
        FieldMessages(msgs),
        if (widget.hint != null) Hint(widget.hint!),
      ],
    );
  }
}

/// Campo de hora: abre el selector de hora de Material, no el teclado.
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.icon,
    required this.minutes,
    required this.text,
    required this.onChanged,
    this.nowLabel,
    this.onNow,
    this.hint,
  });
  final String label, icon, text;
  final int? minutes;
  final ValueChanged<int> onChanged;
  final String? nowLabel, hint;
  final VoidCallback? onNow;

  Future<void> _pick(BuildContext context) async {
    final m = minutes ?? 0;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (t != null) onChanged(t.hour * 60 + t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final box = Tap(
      onTap: () => _pick(context),
      semanticLabel: '$label: $text',
      excludeChildSemantics: true,
      builder: (context, pressed, focused) => FieldBox(
        focused: focused,
        child: Row(
          children: [
            AppIcon(icon, size: 22, color: c.tx),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: AppText.fieldValue.copyWith(color: c.tx)),
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: FieldLabel(label, icon: icon == 'clock' ? 'clock' : 'sunrise')),
        Row(
          children: [
            Expanded(child: box),
            if (onNow != null) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 72, minHeight: 56),
                child: Tap(
                  onTap: onNow,
                  builder: (context, pressed, focused) => Container(
                    constraints: const BoxConstraints(minWidth: 72, minHeight: 56),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pressed ? c.sf2 : c.sf,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      border: Border.all(color: focused ? c.focus : c.tx, width: 2),
                    ),
                    child: Text(nowLabel!, style: AppText.label.copyWith(color: c.tx)),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hint != null) Hint(hint!),
      ],
    );
  }
}
