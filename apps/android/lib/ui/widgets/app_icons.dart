import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Una figura de un ícono, en la caja de 24 × 24 del prototipo.
class IconShape {
  const IconShape.path(this.d, {this.fill = false}) : kind = 0, a = 0, b = 0, c = 0, e = 0, r = 0;
  const IconShape.circle(this.a, this.b, this.r) : kind = 1, d = '', fill = false, c = 0, e = 0;
  const IconShape.rect(this.a, this.b, this.c, this.e, this.r) : kind = 2, d = '', fill = false;
  final int kind;
  final String d;
  final bool fill;
  final double a, b, c, e, r;
}

/// Los íconos del objeto ICONS del prototipo: trazo de 2 dp con puntas redondeadas (DESIGN §7).
const Map<String, List<IconShape>> appIcons = {
  'moon': [IconShape.path('M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z')],
  'sun': [
    IconShape.circle(12, 12, 4),
    IconShape.path(
      'M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
    ),
  ],
  'sunrise': [
    IconShape.path('M3 19h18M7 19a5 5 0 0 1 10 0M12 7v3M5.2 11.6l1.6 1.2M18.8 11.6l-1.6 1.2M12 2l-2 2M12 2l2 2'),
  ],
  'plug': [IconShape.path('M9 2v5M15 2v5M6 7h12v4a6 6 0 0 1-12 0zM12 17v5')],
  'bolt': [IconShape.path('M13 2L4 14h7l-1 8 9-12h-7z')],
  'sliders': [
    IconShape.path('M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1'),
    IconShape.circle(15, 6, 2),
    IconShape.circle(9, 12, 2),
    IconShape.circle(17, 18, 2),
  ],
  'share': [
    IconShape.circle(18, 5, 3),
    IconShape.circle(6, 12, 3),
    IconShape.circle(18, 19, 3),
    IconShape.path('M8.6 13.5l6.8 4M15.4 6.5l-6.8 4'),
  ],
  'check': [IconShape.path('M5 12.5l4.5 4.5L19 7.5')],
  'checkc': [IconShape.circle(12, 12, 9), IconShape.path('M8 12.5l2.7 2.7L16.2 9.6')],
  'alert': [IconShape.path('M12 6.5v7M12 17.5v.01')],
  'alertc': [IconShape.circle(12, 12, 9), IconShape.path('M12 7.5v5.5M12 16.5v.01')],
  'warn': [IconShape.path('M12 3.5L2.5 20h19zM12 10v4.5M12 17.5v.01')],
  'info': [IconShape.circle(12, 12, 9), IconShape.path('M12 11v6M12 7.5v.01')],
  'down': [IconShape.path('M6 9l6 6 6-6')],
  'right': [IconShape.path('M9 6l6 6-6 6')],
  'pencil': [IconShape.path('M4 20h4L19 9l-4-4L4 16zM13.5 6.5l4 4')],
  'clock': [IconShape.circle(12, 12, 9), IconShape.path('M12 7v5l3 2')],
  'battery': [IconShape.rect(2, 7, 17, 10, 2.5), IconShape.path('M22 10.5v3')],
  'minus': [IconShape.path('M5 12h14')],
  'plus': [IconShape.path('M12 5v14M5 12h14')],
  'x': [IconShape.path('M6 6l12 12M18 6L6 18')],
  'flag': [IconShape.path('M5 21V4M5 4h11l-2 4 2 4H5')],
  'download': [IconShape.path('M12 4v11M7 10l5 5 5-5M5 20h14')],
  'globe': [IconShape.circle(12, 12, 9), IconShape.path('M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18')],
  'contrast': [IconShape.circle(12, 12, 9), IconShape.path('M12 3a9 9 0 0 1 0 18z', fill: true)],
  'steps': [
    IconShape.path('M9 6h11M9 12h11M9 18h11'),
    IconShape.circle(4.5, 6, 1.2),
    IconShape.circle(4.5, 12, 1.2),
    IconShape.circle(4.5, 18, 1.2),
  ],
  'eq': [IconShape.path('M5 9h14M5 15h14')],
};

/// Ícono de trazo. [name] es una clave de [appIcons].
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 24, this.color, this.stroke = 2});
  final String name;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final col = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _IconPainter(appIcons[name]!, col, stroke)),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.shapes, this.color, this.stroke);
  final List<IconShape> shapes;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final s in shapes) {
      switch (s.kind) {
        case 0:
          final path = parseSvgPath(s.d);
          canvas.drawPath(path, p);
          if (s.fill) canvas.drawPath(path, Paint()..color = color);
        case 1:
          canvas.drawCircle(Offset(s.a, s.b), s.r, p);
        default:
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.a, s.b, s.c, s.e), Radius.circular(s.r)), p);
      }
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.color != color || old.shapes != shapes || old.stroke != stroke;
}

final _token = RegExp(r'[MmLlHhVvAaZz]|-?(?:\d+\.?\d*|\.\d+)');
final _pathCache = <String, Path>{};

/// Interpreta los comandos de ruta SVG que usan los íconos (M L H V A Z, absolutos y relativos).
Path parseSvgPath(String d) => _pathCache.putIfAbsent(d, () => _parse(d));

Path _parse(String d) {
  final toks = _token.allMatches(d).map((m) => m[0]!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  double n() => double.parse(toks[i++]);
  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  while (i < toks.length) {
    if (isCmd(toks[i])) cmd = toks[i++];
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        path.moveTo(x, y);
        sx = x;
        sy = y;
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        path.lineTo(x, y);
      case 'H':
        x = (rel ? x : 0) + n();
        path.lineTo(x, y);
      case 'V':
        y = (rel ? y : 0) + n();
        path.lineTo(x, y);
      case 'A':
        final rx = n(), ry = n(), rot = n(), large = n() != 0, sweep = n() != 0;
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        x = sx;
        y = sy;
      default:
        i++;
    }
  }
  return path;
}

/// Logo de la app (ic_launcher_full.svg), dibujado en vectores.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.radius = 16});
  final double size, radius;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: LogoPainter()),
      ),
    ),
  );
}

class LogoPainter extends CustomPainter {
  const LogoPainter({this.background = true});
  final bool background;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 108);
    const cream = Color(0xFFF7EEDC);
    const amber = Color(0xFFF0A93B);
    if (background) canvas.drawRect(const Rect.fromLTWH(0, 0, 108, 108), Paint()..color = const Color(0xFF0D1626));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(35, 31, 38, 52), const Radius.circular(9)),
      Paint()
        ..color = cream
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(46, 24, 16, 8), const Radius.circular(2.5)),
      Paint()..color = cream,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(42, 66, 24, 10), const Radius.circular(3)),
      Paint()..color = amber,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(54, 63), radius: 9),
      math.pi,
      math.pi,
      true,
      Paint()..color = amber,
    );
    final rays = Paint()
      ..color = amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(parseSvgPath('M54 46v4M43.5 50.5l2.8 2.8M64.5 50.5l-2.8 2.8'), rays);
  }

  @override
  bool shouldRepaint(LogoPainter old) => false;
}
