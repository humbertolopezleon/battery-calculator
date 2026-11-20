import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Antes de todas las pruebas: carga Atkinson Hyperlegible para medir y dibujar con la fuente real.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Atkinson')
    ..addFont(rootBundle.load('assets/fonts/AtkinsonHyperlegible-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/AtkinsonHyperlegible-Bold.ttf'));
  await loader.load();
  await testMain();
}
