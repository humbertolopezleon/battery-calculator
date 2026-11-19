import 'package:battery_calculator/ui/screens/catalog.dart';
import 'package:battery_calculator/ui/theme/app_colors.dart';
import 'package:battery_calculator/ui/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final (name, c, b) in [
    ('claro', AppColors.light, Brightness.light),
    ('oscuro', AppColors.dark, Brightness.dark),
  ]) {
    testWidgets('el catálogo de componentes se dibuja sin errores ($name)', (tester) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(theme: buildTheme(c, b), home: const Catalog()));
      await tester.pumpAndSettle();
      for (var i = 0; i < 10; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
    });
  }
}
