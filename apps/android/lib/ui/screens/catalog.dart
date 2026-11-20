import 'package:material_ui/material_ui.dart';

import '../../app/presenter.dart';
import '../../domain/calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/battery.dart';
import '../widgets/controls.dart';
import '../widgets/fields.dart';
import '../widgets/result.dart';

/// Catálogo de componentes con sus estados. Solo se abre en debug (desde Ajustes).
class Catalog extends StatefulWidget {
  const Catalog({super.key});
  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  bool _sw = true, _open = true;
  int _seg = 0;
  double _a = 30, _b = 90, _n = 85;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget h(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(t, style: AppText.heading.copyWith(color: c.tx)),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo (debug)'), backgroundColor: c.bg),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          h('Campo numérico'),
          NumberField(label: 'Normal', value: '600', unit: 'W', hint: 'Ayuda', onChanged: (_) {}),
          const SizedBox(height: 12),
          NumberField(label: 'Vacío', value: '', unit: 'W', placeholder: 'Ej.: 600', onChanged: (_) {}),
          const SizedBox(height: 12),
          NumberField(
            label: 'Aviso',
            value: '25000',
            unit: 'W',
            warn: true,
            msgs: const [(MsgKind.warn, '¿Seguro? Es más de lo normal en una casa.')],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          NumberField(
            label: 'Error',
            value: '120',
            unit: '%',
            showError: true,
            msgs: const [(MsgKind.err, 'Escribe un número del 0 al 100.')],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          NumberField(
            label: 'Nota',
            value: '1.500',
            unit: 'W',
            msgs: const [(MsgKind.info, 'Se entendió: 1500 W. Si querías 1,5 W, escríbelo sin punto.')],
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          NumberField(label: 'Deshabilitado', value: '51,2', unit: 'V', enabled: false, onChanged: (_) {}),
          const SizedBox(height: 12),
          TimeField(
            label: 'Hora ahora',
            icon: 'clock',
            minutes: 1260,
            text: '9:00 p. m.',
            onChanged: (_) {},
            nowLabel: 'Ahora',
            onNow: () {},
          ),
          h('Batería deslizable'),
          BatterySlider.night(a: _n, reserve: 6, label: 'Noche', onA: (v) => setState(() => _n = v.toDouble())),
          const SizedBox(height: 12),
          BatterySlider.charge(
            a: _a,
            b: _b,
            label: 'Ahora',
            labelB: 'Hasta',
            onA: (v) => setState(() => _a = v.toDouble()),
            onB: (v) => setState(() => _b = v.toDouble()),
          ),
          h('Selector, interruptor y plegable'),
          Segmented<int>(
            options: const [(0, 'En kWh'), (1, 'En voltios y Ah')],
            value: _seg,
            onChanged: (v) => setState(() => _seg = v),
          ),
          const SizedBox(height: 8),
          const Segmented<int>(options: [(0, 'Sé los watts'), (1, 'Sé los amperios')], value: 0, onChanged: null),
          SwitchRow(
            title: 'Contar las pérdidas (10%)',
            hint: 'Ayuda',
            value: _sw,
            onChanged: (v) => setState(() => _sw = v),
          ),
          const SwitchRow(title: 'Deshabilitado', value: false, onChanged: null),
          Disclosure(
            icon: 'sliders',
            title: 'Más opciones',
            summary: 'Resumen',
            open: _open,
            onToggle: () => setState(() => _open = !_open),
            child: const Text('Contenido'),
          ),
          h('Botones'),
          PrimaryButton(label: 'Compartir resultado', icon: 'share', onPressed: () {}),
          const SizedBox(height: 8),
          const PrimaryButton(label: 'Deshabilitado', icon: 'share'),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Probar con 430 W', icon: 'bolt', onPressed: () {}),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Pequeño', icon: 'down', small: true, onPressed: () {}),
          LinkButton(label: 'Volver a 6%', onPressed: () {}),
          const LinkButton(label: 'Deshabilitado'),
          h('Avisos'),
          for (final t in Tone.values) ...[
            Notice(tone: t, title: t.name, text: 'Texto del aviso.'),
            const SizedBox(height: 8),
          ],
          h('Reglas y franja'),
          const NightTrack(g: NightTrackGeometry(days: false, fill: 90, sunX: 80), reaches: true),
          const SizedBox(height: 8),
          const NightTrack(g: NightTrackGeometry(days: false, fill: 40, sunX: 90), reaches: false),
          const SizedBox(height: 8),
          const NightTrack(g: NightTrackGeometry(days: true, fill: 100, sunX: 6), reaches: true),
          const SizedBox(height: 8),
          const ChargeTrack(fastShare: 75, twoStretches: true),
          const SizedBox(height: 8),
          const AnswerStrip(data: StripData(Tone.ok, 'Hasta las 9:08 a. m.', 'Llegas'), modeIcon: 'moon'),
          const SizedBox(height: 8),
          const AnswerStrip(data: StripData(Tone.err, 'Falta corregir un dato', 'Revisa'), modeIcon: 'moon'),
        ],
      ),
    );
  }
}
