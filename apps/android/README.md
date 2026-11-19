# Calculadora de Batería · Android (Flutter)

App nativa que sigue el paquete de diseño de [`design/handoff/`](../../design/handoff):
SPEC > DESIGN > tokens > capturas > prototipo. Solo Android, solo vertical y **sin internet**.

- Flutter 3.50 (estable) · Dart 3.14 · `minSdk` 24 · `targetSdk` 36
- Dependencias: `material_ui`, `flutter_localizations`, `intl`, `shared_preferences`,
  `share_plus`, `path_provider` y `gal`. No usa gestores de estado externos.

## Estructura

```
lib/
  main.dart            MaterialApp: idioma, tema, letra grande ×1,2, solo vertical
  app/                 AppState (ChangeNotifier + InheritedNotifier), Store (shared_preferences)
                       y presenter: los textos de la tarjeta, el veredicto, las cifras y el paso a paso
  domain/              Dart puro: calculator.dart, formatters.dart, number_parser.dart
  l10n/                app_es.arb, app_en.arb (desde el objeto STR del prototipo) y gen/
  ui/theme/            AppColors (generado desde tokens.json), AppText, espacios y radios
  ui/widgets/          componentes de DESIGN §4 e íconos (CustomPainter, sin flutter_svg)
  ui/screens/          primera vez, De noche, Cargando con la red, hojas, catálogo (solo debug)
  ui/report/           ReportCard de 1080 px y la hoja «Compartir el reporte»
test/
  vectors_test.dart    los 20 casos de ../../design/handoff/docs/test-vectors.json, leídos de ahí
  widget/              flujos, desbordes (320/360/411 dp, letra grande), accesibilidad, capturas
tool/
  gen_colors.py        regenera los colores desde tokens.json
  check_release.sh     compila el release y comprueba peso e INTERNET
```

## Pruebas

```bash
flutter analyze
flutter test
```

`flutter test` también deja capturas de las pantallas en `screenshots/` (no se suben a git),
con los mismos nombres que [`design/handoff/reference/screens/`](../../design/handoff/reference/screens)
para compararlas.

## Compilar el APK

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols
```

O `tool/check_release.sh`, que además comprueba que el APK de 64 bits no pase de 10 MB
y que no pida el permiso `INTERNET`.

Salen tres APK en `build/app/outputs/flutter-apk/`:

| Archivo | Para quién |
|---|---|
| `app-arm64-v8a-release.apk` (≈ 8,2 MB) | **El que se manda por WhatsApp o Telegram.** Casi todos los teléfonos de los últimos años |
| `app-armeabi-v7a-release.apk` (≈ 7,8 MB) | Teléfonos muy viejos o muy baratos de 32 bits, si el otro no se instala |
| `app-x86_64-release.apk` | Emuladores; no hace falta repartirlo |

Guarda `build/symbols/` de cada versión que repartas: sin esos archivos no se pueden leer
los errores de la versión ofuscada.

## Firma de release

Sin `android/key.properties`, el release se firma con la clave de debug: sirve para probar,
pero **no para repartir**, porque cada computadora tiene una clave de debug distinta y
Android no deja actualizar una app firmada con otra clave.

1. Crea la clave una sola vez, **fuera del repositorio**, y guárdala con su contraseña en un lugar seguro
   (si se pierde, ya no se puede actualizar la app instalada):

   ```bash
   keytool -genkeypair -v -keystore ~/claves/bateria-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bateria
   ```

2. Crea `apps/android/android/key.properties` (ya está en `.gitignore`):

   ```properties
   storeFile=/ruta/completa/a/claves/bateria-release.jks
   storePassword=la-contraseña
   keyAlias=bateria
   keyPassword=la-contraseña
   ```

3. Compila como arriba. Los `.jks`, `.keystore` y `key.properties` nunca se suben (están en el `.gitignore` raíz).

## Lo que no quedó igual al diseño, y por qué

- **`minSdk` 24, no 23.** Flutter 3.50 y el paquete `gal` exigen Android 7.0 como mínimo.
- **Dependencia `material_ui`.** Desde Flutter 3.47, Material salió del framework a ese paquete
  oficial (`package:flutter/material.dart` está obsoleto). No estaba en la lista de PROMPT.
- **Lectura de miles.** El prototipo dice «Si querías 25,000 W»; SPEC §5 y las capturas dicen
  «Si querías 25 W». Manda SPEC: la otra lectura va sin ceros sobrantes («1.500» → «1,5 W»).
- **Leyenda de carga de más de 24 h.** SPEC no la define; se sigue el vector de prueba:
  «Llega al 90%» con la hora (del día siguiente) y «Llega al 100%» con la duración.
- **Selector de tema.** La captura pone íconos de sol y luna en «Claro» y «Oscuro»; DESIGN §4
  dice que las opciones no elegidas van sin ícono, y se siguió DESIGN. La ayuda del tema es la
  del objeto `STR` («Auto sigue al teléfono.»), más corta que la de la captura.
- **Alto del reporte.** Mide unos 2240 px de noche y 2300 px en carga (SPEC habla de 1700 a 2000)
  porque los datos y el paso a paso van en dos columnas con letra legible. El ancho es 1080 px.
  En carga, la regla va después del aviso de la red (SPEC §7 solo pide la regla de noche).
- **«≈» y «∞».** Atkinson Hyperlegible no los trae. En el teléfono los dibuja la fuente del
  sistema; en las capturas de prueba (sin fuentes del sistema) salen como un cuadro.
- **Guardar en la galería en Android 7 a 10** pide permiso de almacenamiento, como exige `gal`
  (`maxSdkVersion` 29). SPEC dice «sin pedir permisos en Android 10+»: en Android 10 sí lo pide.
  En Android 11 o más nuevo no pide nada.
- **Bibliotecas nativas comprimidas** (`useLegacyPackaging`): así el APK baja de 17 MB a 8,2 MB.
  A cambio, ocupa algo más en el teléfono después de instalar.
- **Contraste.** `textContrastGuideline` se comprueba en De noche y en Primera vez. En Cargando
  con la red da falsos positivos: toma como color del texto el suavizado de letras finas junto a
  muestras de color y bordes. Ahí el contraste se comprueba con los pares exactos de colores
  (`test/contrast_test.dart`), todos ≥ 4,5:1 en texto y ≥ 3:1 en bordes, en claro y oscuro.
- **El selector de hora** es el de Material con los colores de la app; no tiene diseño propio.
- **No se probó en un teléfono ni en un emulador** (este entorno no tiene emulador). TalkBack,
  el teclado real, la hoja de compartir, guardar en la galería, el ícono y la pantalla de inicio
  están comprobados con pruebas de widget y con el APK compilado, pero falta verlos en un equipo.
