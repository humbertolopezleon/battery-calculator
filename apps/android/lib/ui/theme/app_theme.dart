import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Familia de la fuente (Atkinson Hyperlegible 400 y 700, en assets/fonts/).
const appFont = 'Atkinson';

/// Escala de texto (tokens.json → typeScale_sp).
abstract final class AppText {
  static TextStyle _s(double size, double line, FontWeight w, {double ls = 0}) =>
      TextStyle(fontFamily: appFont, fontSize: size, height: line / size, fontWeight: w, letterSpacing: ls);

  static final answer = _s(48, 50, FontWeight.w700, ls: -0.7);
  static final sheetTitle = _s(22, 28, FontWeight.w700);
  static final heading = _s(18, 24, FontWeight.w700);
  static final fieldValue = _s(22, 28, FontWeight.w700);
  static final body = _s(16, 24, FontWeight.w400);
  static final label = _s(16, 22, FontWeight.w700);
  static final support = _s(15, 21, FontWeight.w400);
  static final hint = _s(14, 20, FontWeight.w400);
  static final small = _s(13, 18, FontWeight.w400);
}

/// Espacios, radios y alturas (tokens.json).
abstract final class AppSpace {
  static const screen = 12.0;
  static const cardPad = 16.0;
  static const block = 18.0;
  static const cardGap = 12.0;
  static const maxContent = 480.0;
}

abstract final class AppRadius {
  static const segment = 11.0;
  static const field = 14.0;
  static const button = 16.0;
  static const notice = 16.0;
  static const card = 22.0;
  static const sheet = 28.0;
}

abstract final class AppHeight {
  static const minTouch = 48.0;
  static const field = 56.0;
  static const button = 56.0;
  static const buttonSmall = 48.0;
  static const disclosureRow = 56.0;
  static const answerStrip = 56.0;
  static const topBar = 56.0;
  static const bottomNav = 82.0;
  static const preset = 64.0;
  static const battery = 56.0;
  static const batteryThumb = 82.0;
}

ThemeData buildTheme(AppColors c, Brightness b) {
  final scheme = ColorScheme(
    brightness: b,
    primary: c.amb,
    onPrimary: c.onAmb,
    secondary: c.inf,
    onSecondary: c.sf,
    error: c.bad,
    onError: c.sf,
    surface: c.sf,
    onSurface: c.tx,
    onSurfaceVariant: c.tx2,
    outline: c.ln,
    outlineVariant: c.ln2,
    surfaceContainerHighest: c.sf2,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: appFont,
    extensions: [c],
    splashFactory: NoSplash.splashFactory,
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.focus, selectionHandleColor: c.focus),
    // Botones de diálogos (selector de hora): ámbar de texto, no el ámbar de relleno, que sobre
    // blanco no llega a 4,5:1.
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: c.ambTx)),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: c.sf,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: c.ambTx),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: c.ambTx),
      // a. m. / p. m.: el elegido con los colores de la hora elegida (sin esto sale el azul de info).
      dayPeriodColor: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.amb : Colors.transparent,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.onAmb : c.tx2,
      ),
      dayPeriodBorderSide: BorderSide(color: c.ln),
      entryModeIconColor: c.tx2,
    ),
  );
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
