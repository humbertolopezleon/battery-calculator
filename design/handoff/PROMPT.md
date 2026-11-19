# Prompt para Claude Code

> Copia todo lo que está debajo de la línea y pégalo en Claude Code. Hazlo desde una carpeta que tenga el contenido de este paquete (`docs/`, `design/`, `reference/`, `assets/`). Lo ideal es un repositorio nuevo y vacío, con el paquete en la carpeta `handoff/`.

---

Vas a implementar desde cero la app Android **Calculadora de Batería** en **Flutter**. El diseño y el comportamiento ya están definidos. Tu trabajo es reproducirlos fielmente, con código limpio, probado y ligero. No rediseñes ni añadas funciones.

## 0. Lee primero (obligatorio, antes de escribir código)

1. `handoff/docs/SPEC.md`: qué hace la app, las fórmulas exactas, la validación, la persistencia y el reporte PNG. **Es la fuente de verdad del comportamiento.**
2. `handoff/docs/DESIGN.md`: la estructura, cada componente con sus estados, el comportamiento del teclado y la franja, la accesibilidad, el ícono y la pantalla de inicio.
3. `handoff/design/tokens.json`: los colores en claro y oscuro (con contrastes medidos), la escala de texto, los espaciados, los radios y las alturas. Úsalos tal cual.
4. `handoff/reference/screens/*.png`: mira **todas** las capturas. Son el objetivo visual a 360 × 800 dp: flujo en claro y oscuro, estados, peor caso a 320 dp con letra grande, reporte, inglés, ícono y sistema de diseño.
5. `handoff/reference/prototype/prototype-src.html`: el prototipo funcional en HTML y JavaScript, legible. Ahí están **todos los textos en español e inglés** (objeto `STR`), los íconos (objeto `ICONS`, rutas SVG 24 × 24) y la lógica de referencia (`night()`, `charge()`, `dur()`, `parse()`). `prototype.html` es la misma versión con las fuentes incrustadas; ábrela en un navegador a 360 px de ancho si necesitas ver un comportamiento.
6. `handoff/docs/test-vectors.json`: 20 casos (entradas y resultados esperados, sacados del prototipo). Son el contrato de la lógica.

Cuando termines de leer, escríbeme un **plan breve**: estructura de carpetas, dependencias, fases y riesgos. Espera mi visto bueno antes de empezar. Si encuentras una contradicción entre los documentos, dímela en el plan; no la resuelvas en silencio. El orden de prioridad es: SPEC > DESIGN > tokens > capturas > prototipo.

## 1. Restricciones

- **Flutter estable y Dart 3, solo Android y solo en vertical.** `minSdk` 23; `targetSdk` el más reciente que admita el SDK instalado.
- **Sin internet:** el `AndroidManifest.xml` de `main` **no** puede pedir `INTERNET` (Flutter lo pone solo en debug y profile; compruébalo en el manifiesto fusionado del release). Sin analítica, Firebase, anuncios, cuentas, fuentes ni imágenes remotas.
- **Dependencias permitidas**, y no más sin preguntarme:
  - `flutter_localizations` e `intl` (con `gen-l10n` y archivos ARB)
  - `shared_preferences`
  - `share_plus`
  - `path_provider`
  - `gal` (guardar en la galería)
  - `flutter_svg`, solo si los íconos no se pueden dibujar con `CustomPainter`
  - `flutter_native_splash` y `flutter_launcher_icons` (solo de desarrollo)

  Nada de gestores de estado externos: usa `ChangeNotifier`/`ValueNotifier` + `InheritedNotifier` o `ListenableBuilder`.
- **Peso:** APK de release `arm64-v8a` **≤ 10 MB**. Con R8 activado (`minifyEnabled`, `shrinkResources`), `--obfuscate` y `--split-debug-info`. Sin imágenes rasterizadas en la app, salvo las que exija el ícono.
- **Fuente:** Atkinson Hyperlegible (los TTF están en `handoff/assets/fonts/`; cópialos a `assets/fonts/` y declara la licencia OFL en `LicenseRegistry`).
- **No cambies las fórmulas ni el significado de los resultados.** No añadas pantallas, historial, gráficas, notificaciones ni onboarding.

## 2. Arquitectura propuesta

```
lib/
  main.dart                      // MaterialApp, tema, l10n, orientación vertical
  app/                           // AppState (ChangeNotifier) + persistencia
  domain/
    calculator.dart              // funciones puras: night(), charge(), capacity()
    formatters.dart              // dur(), q(), números y horas por idioma, artículo la/las
    number_parser.dart           // parse() con lectura de miles, filtro de caracteres
    validation.dart
  l10n/app_es.arb, app_en.arb
  ui/
    theme/                       // AppColors (claro/oscuro, desde tokens.json), AppText, AppSpacing
    widgets/                     // NumberField, TimeField, BatterySlider (1 y 2 manijas), NightTrack,
                                 // ChargeTrack, ResultCard, Verdict, StateCard, Figures, Segmented,
                                 // AppSwitch, Disclosure, PrimaryButton, SecondaryButton, AnswerStrip,
                                 // AppSheet, AppIcons
    screens/                     // FirstRun, Home (pestañas Noche y Carga), BatterySheet, SettingsSheet, ShareSheet
    report/                      // ReportCard (1080 px) + export a PNG
test/
  calculator_test.dart           // los 20 casos de test-vectors.json (cárgalo desde un fixture)
  formatters_test.dart, parser_test.dart
  widget/                        // flujos principales
```

La lógica (`domain/`) no importa nada de Flutter.

## 3. Fases y puntos de control

Al terminar cada fase: `flutter analyze` sin avisos, `flutter test` en verde, y me dices qué hiciste en 3 o 5 líneas.

1. **Base:** proyecto, tema claro y oscuro con los tokens, fuente, l10n es/en con todos los textos del `STR`, `AppState` y persistencia.
2. **Lógica:** `domain/` completo, con tests que reproducen `test-vectors.json` (valores numéricos exactos y textos con `es` y 24 h).
3. **Componentes:** todos los de DESIGN §4, con sus estados (normal, enfocado, deshabilitado, error y aviso, donde apliquen). Haz una pantalla de catálogo **solo en debug** para revisarlos.
4. **Pantallas y flujos:**
   - Primera vez, Noche, Carga y las hojas de batería y de ajustes.
   - Franja de respuesta, comportamiento con el teclado, «Ir al dato», «Probar con X W».
   - Letra grande y modo estrecho.
5. **Reporte:** `ReportCard` de 1080 px, siempre en claro → PNG → compartir con `share_plus` o guardar con `gal`, desde la hoja «Compartir el reporte» (con vista previa).
6. **Ícono, pantalla de inicio y release:** ícono adaptativo con capas de fondo, frente y monocromo (desde `handoff/assets/icon/*.svg`), splash de Android 12+ en claro y oscuro, nombre «Batería»/«Battery», firma de release y build.

## 4. Criterios de aceptación

- [ ] Los 20 casos de `test-vectors.json` pasan.
- [ ] Las pantallas coinciden con `reference/screens/` a 360 dp, en claro y oscuro: colores, tamaños, radios, jerarquía y textos.
- [ ] A 320 dp con letra grande y el texto del sistema al 100%, nada se corta ni se desborda. Comprueba también 411 dp. Usa tests de widget con `tester.view.physicalSize` y `textScaler`, y falla si hay errores de desbordamiento.
- [ ] Todo lo táctil mide ≥ 48 × 48 dp (`meetsGuideline(androidTapTargetGuideline)`), y el contraste pasa (`textContrastGuideline`) en los dos temas.
- [ ] TalkBack: la respuesta se anuncia; los botones que solo tienen ícono llevan etiqueta; la batería deslizable se maneja con los gestos de ajuste.
- [ ] El teclado nunca tapa el campo que se edita, y la respuesta sigue visible en la franja.
- [ ] Sin `INTERNET` en el manifiesto fusionado del release. Funciona en modo avión.
- [ ] Los datos se recuerdan al cerrar y volver a abrir; la «hora ahora» se toma de nuevo.
- [ ] El PNG mide 1080 px de ancho, se lee bien en el chat y se comparte con la hoja del sistema.
- [ ] APK `arm64-v8a` de release ≤ 10 MB. Dime el tamaño exacto.

## 5. Al terminar

Entrégame:

1. Cómo compilar: `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols`. Explica cuál APK mandar por WhatsApp (arm64-v8a para casi todos los teléfonos actuales; armeabi-v7a para los muy viejos).
2. Capturas de las pantallas principales, sacadas de los tests de widget o de un emulador, para compararlas con `reference/screens/`.
3. Una lista honesta de lo que no quedó igual al diseño y por qué.
4. Instrucciones para crear el keystore de release. **No lo subas al repositorio** y añádelo al `.gitignore`.

No hagas commit ni push sin que te lo pida.
