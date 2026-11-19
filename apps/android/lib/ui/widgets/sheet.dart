import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import 'controls.dart';

/// Hoja inferior: radio 28, asa de 40 × 5, velo `scrim`, relleno 20, título y botón de cerrar.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String Function(AppLocalizations l) title,
  required WidgetBuilder builder,
}) {
  final c = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: c.sf,
    barrierColor: c.scrim,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
    builder: (context) {
      final c = context.colors;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpace.maxContent + 40),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: c.ln, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            title(AppLocalizations.of(context)),
                            style: AppText.sheetTitle.copyWith(color: c.tx),
                          ),
                        ),
                      ),
                      IconBtn(
                        icon: 'x',
                        label: AppLocalizations.of(context).close,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  builder(context),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Aviso breve abajo.
///
/// En la pantalla principal es un SnackBar. Dentro de una hoja (ruta modal) el SnackBar quedaría
/// debajo de la hoja, tapado: ahí va en el Overlay raíz, encima de todo.
void showToast(BuildContext context, String text) {
  final route = ModalRoute.of(context);
  // Si la hoja ya se está cerrando (no es la ruta actual), el SnackBar de siempre sí se ve.
  if (route is PopupRoute && route.isCurrent) {
    _showOverlayToast(context, text);
    return;
  }
  final c = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text, style: AppText.support.copyWith(color: c.bg)),
        backgroundColor: c.tx,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: _toastDuration,
      ),
    );
}

const _toastDuration = Duration(milliseconds: 2600);
OverlayEntry? _overlayToast;
Timer? _overlayToastTimer;

void _showOverlayToast(BuildContext context, String text) {
  final c = context.colors;
  _overlayToastTimer?.cancel();
  _overlayToast?.remove();
  final entry = OverlayEntry(
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      return Positioned(
        left: 16,
        right: 16,
        bottom: 16 + mq.padding.bottom + mq.viewInsets.bottom,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpace.maxContent),
            child: Semantics(
              liveRegion: true,
              container: true,
              child: Material(
                color: c.tx,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(text, style: AppText.support.copyWith(color: c.bg)),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  _overlayToast = entry;
  Overlay.of(context, rootOverlay: true).insert(entry);
  _overlayToastTimer = Timer(_toastDuration, () {
    if (_overlayToast == entry) _overlayToast = null;
    entry.remove();
  });
}
