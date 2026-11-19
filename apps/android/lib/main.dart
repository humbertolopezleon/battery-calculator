import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

import 'app/app_state.dart';
import 'app/store.dart';
import 'l10n/gen/app_localizations.dart';
import 'ui/screens/root.dart';
import 'ui/theme/app_colors.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Atkinson Hyperlegible'], ofl);
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final state = AppState(PrefsStore());
  await state.load();
  runApp(BatteryApp(state: state));
}

/// Raíz de la app: idioma, tema, letra grande.
class BatteryApp extends StatelessWidget {
  const BatteryApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final device = WidgetsBinding.instance.platformDispatcher.locale;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (c) => AppLocalizations.of(c).appName,
            locale: Locale(state.effectiveLang(device)),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: buildTheme(AppColors.light, Brightness.light),
            darkTheme: buildTheme(AppColors.dark, Brightness.dark),
            themeMode: switch (state.theme) {
              ThemePref.auto => ThemeMode.system,
              ThemePref.light => ThemeMode.light,
              ThemePref.dark => ThemeMode.dark,
            },
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              if (!state.big) return child!;
              // Letra grande: ×1,2 sobre la escala del sistema (DESIGN §5).
              final scale = mq.textScaler.scale(100) / 100 * 1.2;
              return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale)), child: child!);
            },
            home: const Root(),
          );
        },
      ),
    );
  }
}
