import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import '../../app/presenter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../report/report_card.dart';
import '../report/share_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';
import '../widgets/result.dart';
import '../widgets/sheet.dart';
import 'charge_pane.dart';
import 'common.dart';
import 'home_ctl.dart';
import 'night_pane.dart';
import 'runtime_pane.dart';
import 'sheets.dart';

/// Pantalla principal: barra superior, franja de respuesta, pestaña activa y barra inferior.
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _ctl = HomeCtl();
  final _scroll = ScrollController();
  final _viewportKey = GlobalKey();
  bool _resultVisible = true;

  @override
  void dispose() {
    _ctl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// ¿La tarjeta de resultado se ve todavía debajo de la franja?
  void _checkResult() {
    final s = AppScope.read(context);
    final key = switch (s.tab) {
      AppTab.runtime => _ctl.runtimeResultKey,
      AppTab.night => _ctl.nightResultKey,
      AppTab.charge => _ctl.chargeResultKey,
    };
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final vp = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || vp == null || !box.attached) return;
    final bottom = box.localToGlobal(Offset(0, box.size.height), ancestor: vp).dy;
    final visible = bottom > AppHeight.answerStrip + 24;
    if (visible != _resultVisible) setState(() => _resultVisible = visible);
  }

  void _setTab(AppState s, AppTab t) {
    if (s.tab == t) return;
    s.update((s) => s.tab = t);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _resultVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final fmt = Fmt(l, use24h: MediaQuery.alwaysUse24HourFormatOf(context));
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final narrow = isNarrow(context, s.big);

    return ListenableBuilder(
      listenable: _ctl,
      builder: (context, _) {
        final tab = s.tab;
        final rv = tab == AppTab.runtime ? computeRuntime(s, fmt) : null;
        final nv = tab == AppTab.night ? computeNight(s, fmt) : null;
        final cv = tab == AppTab.charge ? computeCharge(s, fmt, _ctl) : null;
        final strip = rv?.strip ?? nv?.strip ?? cv!.strip;

        void share() {
          final shareable = rv?.shareable ?? nv?.shareable ?? cv!.shareable;
          if (!shareable) {
            showToast(context, l.fixFirst);
            return;
          }
          final now = DateTime.now();
          final data = rv != null
              ? ReportData.runtime(rv, s, fmt, now)
              : nv != null
              ? ReportData.night(nv, s, fmt, now)
              : ReportData.charge(cv!, s, fmt, now);
          openShareSheet(context, data, fmt);
        }

        final Widget pane = switch (tab) {
          AppTab.runtime => RuntimePane(view: rv!, fmt: fmt, ctl: _ctl, onShare: share),
          AppTab.night => NightPane(view: nv!, fmt: fmt, ctl: _ctl, onShare: share),
          AppTab.charge => ChargePane(view: cv!, fmt: fmt, ctl: _ctl, onShare: share),
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkResult();
        });

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(narrow: narrow),
                Expanded(
                  child: Stack(
                    key: _viewportKey,
                    children: [
                      NotificationListener<ScrollNotification>(
                        onNotification: (_) {
                          _checkResult();
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(AppSpace.screen, 4, AppSpace.screen, 24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: AppSpace.maxContent),
                              child: pane,
                            ),
                          ),
                        ),
                      ),
                      if (keyboard || !_resultVisible)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: AnswerStrip(data: strip, modeIcon: tabIcon(tab)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: keyboard ? null : _Tabs(tab: s.tab, onTab: (t) => _setTab(s, t), colorsNav: c.nav),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.narrow});
  final bool narrow;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final fmt = Fmt(l, use24h: true);
    final cap = '${fmt.nf(s.cap ?? 0, 2)} kWh';
    return Container(
      color: c.bg,
      constraints: const BoxConstraints(minHeight: AppHeight.topBar),
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, 4, 4, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpace.maxContent + AppSpace.screen),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tap(
                    onTap: () => openBatterySheet(context),
                    semanticLabel: '${l.batLblPrefix}$cap',
                    excludeChildSemantics: true,
                    builder: (context, pressed, focused) => Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: pressed ? c.sf2 : c.sf,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: focused ? c.focus : c.ln, width: focused ? 2.5 : 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon('battery', size: 22, color: c.tx),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (!narrow) TextSpan(text: l.batLblPrefix),
                                  TextSpan(
                                    text: cap,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              style: AppText.body.copyWith(color: c.tx),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppIcon('pencil', size: 18, color: c.tx),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconBtn(icon: 'sliders', label: l.settings, onPressed: () => openSettingsSheet(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onTab, required this.colorsNav});
  final AppTab tab;
  final ValueChanged<AppTab> onTab;
  final Color colorsNav;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    Widget item(AppTab t, String icon, String text) {
      final sel = t == tab;
      return Expanded(
        child: Tap(
          onTap: () => onTab(t),
          selected: sel,
          inGroup: true,
          builder: (context, pressed, focused) => Container(
            constraints: const BoxConstraints(minHeight: 66),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: sel ? c.sel : (pressed ? c.sf2 : null),
              borderRadius: BorderRadius.circular(16),
              border: focused ? Border.all(color: c.focus, width: 2.5) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 28,
                  decoration: BoxDecoration(color: sel ? c.amb : null, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: 22, color: sel ? c.onAmb : c.tx2),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: (sel ? AppText.label : AppText.body).copyWith(
                    fontSize: 15,
                    height: 1.2,
                    color: sel ? c.tx : c.tx2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: l.tabsAria,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: colorsNav,
          border: Border(top: BorderSide(color: c.ln2)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppHeight.bottomNav),
            child: Row(
              children: [
                item(AppTab.runtime, tabIcon(AppTab.runtime), l.tabRuntime),
                item(AppTab.night, tabIcon(AppTab.night), l.tabNight),
                item(AppTab.charge, tabIcon(AppTab.charge), l.tabCharge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono de cada modo: en la barra, el encabezado de la tarjeta y la franja.
String tabIcon(AppTab t) => switch (t) {
  AppTab.runtime => 'clock',
  AppTab.night => 'moon',
  AppTab.charge => 'plug',
};
