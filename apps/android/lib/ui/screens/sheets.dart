import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../domain/formatters.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/sheet.dart';
import 'battery_form.dart';
import 'catalog.dart';

/// Versión que se muestra en Ajustes.
const appVersion = '1.4';

/// Hoja «Tu batería».
Future<void> openBatterySheet(BuildContext context) {
  final s = AppScope.read(context);
  final l = AppLocalizations.of(context);
  final draft = BatteryDraft.from(s);
  return showAppSheet<void>(
    context,
    title: (l) => l.yourBat,
    builder: (context) {
      final sep = Localizations.localeOf(context).languageCode == 'en' ? '.' : ',';
      final lang = sep == '.' ? 'en' : 'es';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BatteryForm(draft: draft),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: draft,
            builder: (context, _) => PrimaryButton(
              label: l.ok,
              onPressed: draft.result(sep).ok
                  ? () {
                      if (draft.commit(s, sep)) {
                        Navigator.of(context).pop();
                        showToast(context, '${l.batLblPrefix}${NumberFormatter(lang).nf(s.cap!, 2)} kWh');
                      }
                    }
                  : null,
            ),
          ),
        ],
      );
    },
  );
}

/// Hoja «Ajustes».
Future<void> openSettingsSheet(BuildContext context) {
  return showAppSheet<void>(context, title: (l) => l.settings, builder: (context) => const _Settings());
}

class _Settings extends StatefulWidget {
  const _Settings();
  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  bool _confirm = false;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    Widget label(String icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AppIcon(icon, size: 20, color: c.tx),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppText.label.copyWith(color: c.tx)),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label('globe', 'Idioma · Language'),
        Segmented<String>(
          label: 'Idioma · Language',
          options: const [('es', 'Español'), ('en', 'English')],
          value: s.effectiveLang(device),
          onChanged: (v) => s.update((s) => s.lang = v),
        ),
        Hint(l.langHint),
        const SizedBox(height: 18),
        label('contrast', l.themeL),
        Segmented<ThemePref>(
          label: l.themeL,
          options: [(ThemePref.auto, l.thAuto), (ThemePref.light, l.thLight), (ThemePref.dark, l.thDark)],
          value: s.theme,
          onChanged: (v) => s.update((s) => s.theme = v),
        ),
        Hint(l.themeHint),
        const SizedBox(height: 14),
        Divider(height: 1, color: c.ln2),
        SwitchRow(title: l.bigText, hint: l.bigHint, value: s.big, onChanged: (v) => s.update((s) => s.big = v)),
        const SizedBox(height: 14),
        PrimaryButton(label: l.ok, onPressed: () => Navigator.of(context).pop()),
        const SizedBox(height: 6),
        Center(
          child: LinkButton(
            label: _confirm ? l.confirmReset : l.resetAll,
            onPressed: () async {
              if (!_confirm) {
                setState(() => _confirm = true);
                return;
              }
              Navigator.of(context).pop();
              await s.reset();
            },
          ),
        ),
        Hint(l.version(appVersion), center: true),
        if (kDebugMode)
          Center(
            child: LinkButton(
              label: 'Catálogo (debug)',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Catalog()));
              },
            ),
          ),
      ],
    );
  }
}
