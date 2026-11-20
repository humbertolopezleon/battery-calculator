import 'package:material_ui/material_ui.dart';

import '../domain/calculator.dart';
import '../domain/formatters.dart';
import 'store.dart';

enum AppTab { night, charge }

enum ThemePref { auto, light, dark }

/// Estado de la app. Se guarda en cada cambio (SPEC §6), salvo la «hora ahora».
class AppState extends ChangeNotifier {
  AppState(this._store, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    final n = _nowClock();
    nightNow = n;
    chargeNow = n;
  }

  final Store _store;
  final DateTime Function() _clock;

  // Batería
  double? cap;
  BatteryMode batMode = BatteryMode.kwh;
  String capTxt = '';
  String volt = '51,2';
  String ahTxt = '';

  // Pestaña
  AppTab tab = AppTab.night;

  // De noche
  String nPct = '85';
  String nW = '600';
  String nightNow = '';
  String nSun = '07:00';
  bool loss = true;
  String rsv = '6';

  // Carga
  String cPct = '30';
  String cTgt = '100';
  PowerMode pmode = PowerMode.watts;
  String cW = '2500';
  String cA = '50';
  String cV = '51,2';
  String chargeNow = '';

  // Ajustes. [lang] null = el del teléfono.
  String? lang;
  ThemePref theme = ThemePref.auto;
  bool big = false;

  String _nowClock() {
    final d = _clock();
    return clockString(d.hour * 60 + d.minute);
  }

  /// Hora actual del teléfono como «HH:mm».
  String nowClock() => _nowClock();

  Future<void> load() async {
    final m = await _store.load();
    if (m == null) return;
    T? g<T>(String k) => m[k] is T ? m[k] as T : null;
    cap = (m['cap'] as num?)?.toDouble();
    batMode = g<String>('batMode') == 'ah' ? BatteryMode.voltsAh : BatteryMode.kwh;
    capTxt = g('capTxt') ?? capTxt;
    volt = g('volt') ?? volt;
    ahTxt = g('ahTxt') ?? ahTxt;
    tab = g<String>('tab') == 'charge' ? AppTab.charge : AppTab.night;
    nPct = g('nPct') ?? nPct;
    nW = g('nW') ?? nW;
    nSun = g('nSun') ?? nSun;
    loss = g('loss') ?? loss;
    rsv = g('rsv') ?? rsv;
    cPct = g('cPct') ?? cPct;
    cTgt = g('cTgt') ?? cTgt;
    pmode = g<String>('pmode') == 'a' ? PowerMode.amps : PowerMode.watts;
    cW = g('cW') ?? cW;
    cA = g('cA') ?? cA;
    cV = g('cV') ?? cV;
    lang = g('lang');
    theme = ThemePref.values.asNameMap()[g<String>('theme')] ?? ThemePref.auto;
    big = g('big') ?? big;
    notifyListeners();
  }

  Map<String, Object?> toJson() => {
    'cap': cap,
    'batMode': batMode == BatteryMode.voltsAh ? 'ah' : 'kwh',
    'capTxt': capTxt,
    'volt': volt,
    'ahTxt': ahTxt,
    'tab': tab.name,
    'nPct': nPct,
    'nW': nW,
    'nSun': nSun,
    'loss': loss,
    'rsv': rsv,
    'cPct': cPct,
    'cTgt': cTgt,
    'pmode': pmode == PowerMode.amps ? 'a' : 'w',
    'cW': cW,
    'cA': cA,
    'cV': cV,
    'lang': lang,
    'theme': theme.name,
    'big': big,
  };

  /// Cambia algo, avisa a la UI y guarda.
  void update(void Function(AppState s) change) {
    change(this);
    notifyListeners();
    _store.save(toJson());
  }

  /// Idioma efectivo, con el del teléfono como respaldo.
  String effectiveLang(Locale device) => lang ?? (device.languageCode == 'en' ? 'en' : 'es');

  /// «Borrar mis datos y empezar de nuevo».
  Future<void> reset() async {
    await _store.clear();
    final fresh = AppState(MemoryStore(), clock: _clock);
    cap = null;
    batMode = fresh.batMode;
    capTxt = fresh.capTxt;
    volt = fresh.volt;
    ahTxt = fresh.ahTxt;
    tab = fresh.tab;
    nPct = fresh.nPct;
    nW = fresh.nW;
    nightNow = fresh.nightNow;
    nSun = fresh.nSun;
    loss = fresh.loss;
    rsv = fresh.rsv;
    cPct = fresh.cPct;
    cTgt = fresh.cTgt;
    pmode = fresh.pmode;
    cW = fresh.cW;
    cA = fresh.cA;
    cV = fresh.cV;
    chargeNow = fresh.chargeNow;
    lang = null;
    theme = ThemePref.auto;
    big = false;
    notifyListeners();
  }
}

/// Da acceso al [AppState] desde cualquier widget.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Sin suscribirse a cambios (para callbacks).
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
