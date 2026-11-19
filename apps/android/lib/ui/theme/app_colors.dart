// GENERADO desde design/handoff/design/tokens.json (no editar a mano).
// Para regenerar: tool/gen_colors.py

import 'package:flutter/painting.dart';
import 'package:material_ui/material_ui.dart' show ThemeExtension;

/// Colores del diseño (DESIGN, tokens.json), en claro y oscuro.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.sf,
    required this.sf2,
    required this.tx,
    required this.tx2,
    required this.ln,
    required this.ln2,
    required this.amb,
    required this.ambTx,
    required this.ambBg,
    required this.onAmb,
    required this.ok,
    required this.okBg,
    required this.bad,
    required this.badBg,
    required this.inf,
    required this.infBg,
    required this.warn,
    required this.warnBg,
    required this.rsv,
    required this.focus,
    required this.nav,
    required this.sel,
    required this.track,
    required this.dis,
    required this.disBg,
    required this.chg,
    required this.scrim,
  });

  /// Fondo de la app
  final Color bg;
  /// Superficie: tarjetas, campos, hojas
  final Color sf;
  /// Superficie 2: cifras, selector
  final Color sf2;
  /// Texto principal
  final Color tx;
  /// Texto de apoyo
  final Color tx2;
  /// Borde de campo (≥3:1)
  final Color ln;
  /// Divisor decorativo
  final Color ln2;
  /// Energía: relleno, botón principal, pestaña activa
  final Color amb;
  /// Energía como texto
  final Color ambTx;
  /// Fondo ámbar suave
  final Color ambBg;
  /// Texto sobre ámbar
  final Color onAmb;
  /// Bien (texto/ícono)
  final Color ok;
  /// Fondo de bien
  final Color okBg;
  /// Problema / error
  final Color bad;
  /// Fondo de problema
  final Color badBg;
  /// Información (gasto de la red)
  final Color inf;
  /// Fondo de información; halo de foco
  final Color infBg;
  /// Aviso (valor raro)
  final Color warn;
  /// Fondo de aviso
  final Color warnBg;
  /// Reserva (rayado)
  final Color rsv;
  /// Anillo de foco
  final Color focus;
  /// Barra inferior
  final Color nav;
  /// Pestaña / atajo elegido
  final Color sel;
  /// Pista de la regla
  final Color track;
  /// Deshabilitado
  final Color dis;
  /// Fondo deshabilitado
  final Color disBg;
  /// Carga (rayado y pista)
  final Color chg;
  /// Velo detrás de hojas
  final Color scrim;

  static const light = AppColors(
    bg: Color(0xFFEEF2F6),
    sf: Color(0xFFFFFFFF),
    sf2: Color(0xFFE3E9F0),
    tx: Color(0xFF122033),
    tx2: Color(0xFF46566C),
    ln: Color(0xFF74859C),
    ln2: Color(0xFFD3DBE5),
    amb: Color(0xFFE39B2D),
    ambTx: Color(0xFF8A5300),
    ambBg: Color(0xFFFCEFD9),
    onAmb: Color(0xFF1B1203),
    ok: Color(0xFF1E6B4A),
    okBg: Color(0xFFE2F3EA),
    bad: Color(0xFFA3392E),
    badBg: Color(0xFFFBE8E5),
    inf: Color(0xFF1F5FA8),
    infBg: Color(0xFFE3EDFA),
    warn: Color(0xFF6B4200),
    warnBg: Color(0xFFFFF0D2),
    rsv: Color(0xFFB5574B),
    focus: Color(0xFF1F5FA8),
    nav: Color(0xFFFFFFFF),
    sel: Color(0xFFFCE7C4),
    track: Color(0xFFD5DDE7),
    dis: Color(0xFF8C98A8),
    disBg: Color(0xFFE7ECF2),
    chg: Color(0xFF2F7D5B),
    scrim: Color(0x8C080E1A),
  );

  static const dark = AppColors(
    bg: Color(0xFF0D1626),
    sf: Color(0xFF162236),
    sf2: Color(0xFF203049),
    tx: Color(0xFFF2F5F9),
    tx2: Color(0xFFB4C0D0),
    ln: Color(0xFF7F92B0),
    ln2: Color(0xFF2C3B55),
    amb: Color(0xFFF0A93B),
    ambTx: Color(0xFFF6BC5E),
    ambBg: Color(0xFF33260F),
    onAmb: Color(0xFF1B1203),
    ok: Color(0xFF7DDBA9),
    okBg: Color(0xFF12352A),
    bad: Color(0xFFFF9E92),
    badBg: Color(0xFF3D1F22),
    inf: Color(0xFF9CC6F5),
    infBg: Color(0xFF15304F),
    warn: Color(0xFFFFD38A),
    warnBg: Color(0xFF3A2A10),
    rsv: Color(0xFFE0786B),
    focus: Color(0xFF9CC6F5),
    nav: Color(0xFF121D2F),
    sel: Color(0xFF3B2D14),
    track: Color(0xFF2A3A55),
    dis: Color(0xFF6E7C91),
    disBg: Color(0xFF1C283C),
    chg: Color(0xFF57B98A),
    scrim: Color(0x99000000),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : (other ?? this);
}
