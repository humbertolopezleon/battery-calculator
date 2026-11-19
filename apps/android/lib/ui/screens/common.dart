import 'package:material_ui/material_ui.dart';

import '../../app/presenter.dart';
import '../../domain/calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/fields.dart';

/// Modo estrecho: < 400 dp con letra grande, o < 330 dp (DESIGN §5).
bool isNarrow(BuildContext context, bool big) {
  final w = MediaQuery.sizeOf(context).width;
  return (w < 400 && big) || w < 330;
}

/// Mensajes de un campo con la regla de la app: los errores solo después de salir del campo.
List<UiMsg> uiMsgs(List<FieldMsg> msgs, Fmt f, {required bool touched}) => [
  for (final m in msgs)
    if (m.kind != MsgKind.err || touched) (m.kind, f.msg(m)),
];

/// Título de una tarjeta de datos.
class CardTitle extends StatelessWidget {
  const CardTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: AppText.heading.copyWith(fontSize: 20, color: context.colors.tx)),
  );
}

/// Nota de aproximación (con ícono «i»).
class ApproxNote extends StatelessWidget {
  const ApproxNote(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppIcon('info', size: 18, color: c.tx2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppText.hint.copyWith(color: c.tx2)),
          ),
        ],
      ),
    );
  }
}

/// Paso a paso numerado.
class StepsList extends StatelessWidget {
  const StepsList(this.steps, {super.key});
  final List<String> steps;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in steps.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.sf2, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: AppText.small.copyWith(fontWeight: FontWeight.w700, color: c.tx),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s,
                    style: AppText.support.copyWith(color: c.tx, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Respuesta grande (48 sp): se achica si no cabe en una línea.
class BigAnswer extends StatelessWidget {
  const BigAnswer({super.key, required this.lead, required this.big, this.sub});
  final String lead, big;
  final String? sub;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lead, style: AppText.body.copyWith(fontSize: 17, color: c.tx2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(big, style: AppText.answer.copyWith(color: c.tx), maxLines: 1),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: AppText.label.copyWith(fontSize: 17, color: c.tx)),
        ],
      ],
    );
  }
}
