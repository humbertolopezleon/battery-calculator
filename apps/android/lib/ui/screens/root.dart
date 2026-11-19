import 'package:material_ui/material_ui.dart';

import '../../app/app_state.dart';
import 'first_run.dart';
import 'home.dart';

/// Primera vez (si no hay batería) o la pantalla principal.
class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return s.cap == null ? const FirstRun() : const Home();
  }
}
