import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/result.dart';
import 'battery_form.dart';

/// Primera vez: solo se pide la batería (DESIGN §3.1).
class FirstRun extends StatefulWidget {
  const FirstRun({super.key});
  @override
  State<FirstRun> createState() => _FirstRunState();
}

class _FirstRunState extends State<FirstRun> {
  BatteryDraft? _draft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??= BatteryDraft.from(AppScope.read(context));
  }

  @override
  void dispose() {
    _draft?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final s = AppScope.of(context);
    final sep = Localizations.localeOf(context).languageCode == 'en' ? '.' : ',';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpace.maxContent),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const AppLogo(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l.appName,
                                style: AppText.sheetTitle.copyWith(fontSize: 24, height: 1.15, color: c.tx),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                AppIcon('checkc', size: 16, color: c.tx2),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(l.offline, style: AppText.hint.copyWith(color: c.tx2)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(l.intro, style: AppText.body.copyWith(fontSize: 17, height: 1.45, color: c.tx2)),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AppIcon('battery', color: c.tx),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(l.sizeQ, style: AppText.sheetTitle.copyWith(fontSize: 20, color: c.tx)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BatteryForm(draft: _draft!, firstRun: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Hint(l.startHint),
                  const SizedBox(height: 10),
                  ListenableBuilder(
                    listenable: _draft!,
                    builder: (context, _) => PrimaryButton(
                      label: l.start,
                      onPressed: _draft!.result(sep).ok ? () => _draft!.commit(s, sep) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
