import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/presenter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/controls.dart';
import '../widgets/sheet.dart';
import 'report_card.dart';

/// Captura el PNG del reporte (1080 px de ancho) desde su [RepaintBoundary].
Future<Uint8List> captureReport(GlobalKey boundaryKey) async {
  final ro = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await ro.toImage(pixelRatio: reportPixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

/// Hoja «Compartir el reporte», con vista previa.
Future<void> openShareSheet(BuildContext context, ReportData data, Fmt fmt) {
  return showAppSheet(
    context,
    title: (l) => l.shareT,
    builder: (_) => _ShareBody(data: data, fmt: fmt),
  );
}

class _ShareBody extends StatefulWidget {
  const _ShareBody({required this.data, required this.fmt});
  final ReportData data;
  final Fmt fmt;
  @override
  State<_ShareBody> createState() => _ShareBodyState();
}

class _ShareBodyState extends State<_ShareBody> {
  final _key = GlobalKey();
  bool _busy = false;

  Future<Uint8List> _png() async {
    await WidgetsBinding.instance.endOfFrame;
    return captureReport(_key);
  }

  Future<void> _share() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await _png();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.data.fileName(l)}');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          title: l.rTitleN,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      // Android 7 a 9 piden permiso de almacenamiento (en 10+ no hace falta). Se pide una sola vez:
      // Gal.putImageBytes lo volvería a pedir por dentro si aún faltara.
      if (!await Gal.hasPermission() && !await Gal.requestPermission()) {
        if (mounted) showToast(context, l.saveNoPerm);
        return;
      }
      final bytes = await _png();
      final name = widget.data.fileName(l);
      await Gal.putImageBytes(bytes, name: name.replaceAll('.png', ''));
      if (mounted) showToast(context, l.saved(name));
    } on GalException catch (_) {
      if (mounted) showToast(context, l.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final name = widget.data.fileName(l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa: el reporte real, reducido. Se captura a su tamaño propio.
              Semantics(
                image: true,
                label: reportSemantics(widget.data),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 96,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      child: RepaintBoundary(
                        key: _key,
                        child: ExcludeSemantics(
                          child: ReportCard(data: widget.data, fmt: widget.fmt),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.label.copyWith(color: c.tx)),
                    const SizedBox(height: 6),
                    Text(l.shareDesc, style: AppText.hint.copyWith(color: c.tx2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: l.shareImg, icon: 'share', onPressed: _busy ? null : _share),
        const SizedBox(height: 10),
        SecondaryButton(label: l.saveImg, icon: 'download', onPressed: _busy ? null : _save),
        const SizedBox(height: 4),
        Text(l.shareHint, style: AppText.hint.copyWith(color: c.tx2)),
      ],
    );
  }
}
