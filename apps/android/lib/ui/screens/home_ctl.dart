import 'package:material_ui/material_ui.dart';

/// Estado de la interfaz que no se guarda: campos tocados, plegables abiertos, foco y posiciones.
class HomeCtl extends ChangeNotifier {
  /// Campos de los que ya se salió (sus errores se muestran).
  final touched = <String>{};
  bool moreOpen = false, nightHowOpen = false, chargeHowOpen = false;

  final _focus = <String, FocusNode>{};
  final _keys = <String, GlobalKey>{};

  /// La tarjeta de resultado de cada pestaña (para saber si se ve).
  final nightResultKey = GlobalKey(debugLabel: 'nightResult');
  final chargeResultKey = GlobalKey(debugLabel: 'chargeResult');

  FocusNode focus(String id) => _focus.putIfAbsent(id, () => FocusNode(debugLabel: id));
  GlobalKey key(String id) => _keys.putIfAbsent(id, () => GlobalKey(debugLabel: id));

  bool isTouched(String id) => touched.contains(id);

  void touch(String id) {
    if (touched.add(id)) notifyListeners();
  }

  void set(void Function(HomeCtl c) f) {
    f(this);
    notifyListeners();
  }

  /// «Ir al dato»: abre «Más opciones» si hace falta, enfoca el campo y lo centra.
  void goTo(String id) {
    if (id == 'nRsv' && !moreOpen) {
      moreOpen = true;
      notifyListeners();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[id]?.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 150));
      _focus[id]?.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final f in _focus.values) {
      f.dispose();
    }
    super.dispose();
  }
}
