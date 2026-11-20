# QA del APK de release · Android 7.0 a 15

Fecha: 19 y 20 de noviembre de 2026 · Rama `feat/monorepo-android` · Versión 1.4.0 (versionCode 2001).

Resumen: la app **arranca y completa todos los flujos en emuladores de Android 7.0, 7.1, 8.0, 8.1,
9, 10, 11 y 15**, sin crashes ni ANR de la app. Se encontraron **7 problemas** (ninguno impedía
usar la app). Los 7 quedaron corregidos; 6 se verificaron en emulador y el de TalkBack (H7) solo
con el árbol de accesibilidad, porque TalkBack no se pudo ejecutar. **Nada se probó
en un teléfono real**, y TalkBack no se pudo ejecutar (ver [lo que falta](#lo-que-falta-probar-en-un-teléfono-real)).

## Entorno y método

| | |
|---|---|
| Máquina | Contenedor Linux x86_64, 4 núcleos, 15 GB, **sin KVM** (`/dev/kvm` no existe) |
| Emulador | Android Emulator 37.3.10 con **emulación por software (TCG)**: `-accel off` y `ANDROID_I_WANT_MY_TCG=yes`, GPU `swiftshader_indirect`. Es entre 10 y 50 veces más lento que un teléfono |
| Imágenes | `system-images;android-{24..30};default;x86_64` y `android-35;google_apis;x86_64` (no hay imagen 36 de este tipo en este SDK). Perfil Pixel (1080 × 1920, 420 dpi, 411 dp de ancho). Sistema en inglés (EE. UU.) salvo donde se indica |
| APK | `app-x86_64-release.apk` de `tool/check_release.sh` (R8, `shrinkResources`, ofuscado, firmado con la clave de debug). Es el mismo código Dart y Java que el arm64-v8a que se reparte |
| Herramientas | `adb` (`am start`, `input`, `screencap`, `uiautomator dump`, `logcat`, `cmd uimode`, `settings`), `aapt2` 36.0.0, Android Lint (AGP del proyecto), lectura del código de los plugins |

**Qué se ejecutó en emulador:** cada versión recibió el mismo recorrido automatizado (guion con
`adb`, capturas en cada paso y `logcat` completo):

1. instalar el APK limpio y abrirlo (Primera vez);
2. elegir 10,24 kWh y «Empezar» (De noche);
3. abrir el selector de hora del amanecer, pasar al modo teclado y cancelar;
4. Ajustes: español, tema oscuro y letra grande;
5. pestaña Cargando con la red;
6. hoja «Compartir el reporte» → «Guardar en el teléfono» (en API 24–28: **negar** el permiso,
   comprobar que no se vuelve a pedir, guardar otra vez y **permitir**) → comprobar el PNG en
   `/sdcard/Pictures` y en MediaStore;
7. «Compartir imagen» → comprobar el `Intent` `SEND` con la URI del `FileProvider`;
8. cerrar la app a la fuerza (`am force-stop`), abrirla y comprobar que recuerda batería, idioma y tema;
9. buscar `FATAL EXCEPTION`, `ANR in`, `E/flutter` y `PlatformException` en el `logcat`.

En API 24 y 29 además se probó a mano: teclado numérico real, «Probar con 840 W», «Ir al dato»,
valores inválidos, modo oscuro del sistema con el tema en «Auto», pantalla de inicio, nombre e
ícono en el launcher con el sistema en español y modo avión.

**Qué solo se revisó de forma estática:** Android Lint con `minSdk` 24, `aapt2 dump badging/resources`,
el manifiesto fusionado, las reglas de R8 (`configuration.txt`, `mapping.txt`) y el código nativo de
`gal` 3.0.1, `share_plus` 13.3.1, `path_provider_android` 2.3.1 (usa `jni`) y `shared_preferences_android` 2.5.5.

**Qué no se pudo ejecutar:** TalkBack (no viene en las imágenes de emulador y no hay forma de
instalarlo sin Play Store), un teléfono real, WhatsApp/Telegram (la hoja de compartir se probó con
las apps del emulador) y medidas de rendimiento (TCG no sirve para medir).

## Matriz por versión

✅ funciona · 🔧 falló y quedó corregido · ➖ no aplica · ❔ no verificado

| | 7.0 · 24 | 7.1 · 25 | 8.0 · 26 | 8.1 · 27 | 9 · 28 | 10 · 29 | 11 · 30 | 15 · 35 |
|---|---|---|---|---|---|---|---|---|
| Arranque en frío (TCG) | 4,1 s | 4,8 s | 5,1 s | 5,6 s | 5,5 s | 5,8 s | 10,5 s | 30–49 s |
| Primera vez → De noche | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Cargando con la red | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hojas de ajustes, idioma, tema, letra grande | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Selector de hora (reloj y teclado) | 🔧 H2, H3 | 🔧 | 🔧 | 🔧 | 🔧 | 🔧 | 🔧 | 🔧 |
| «Probar con X W», «Ir al dato», teclado numérico | ✅ (a mano) | ❔ | ❔ | ❔ | ❔ | ❔ | ❔ | ❔ |
| Campo de porciento con letra grande | 🔧 H4 | ❔ | ❔ | ❔ | ❔ | ❔ | ❔ | ❔ |
| Guardar: pide permiso | sí, 🔧 H1 | sí, 🔧 | sí, 🔧 | sí, 🔧 | sí, 🔧 | no | no | no |
| Guardar: PNG en `Pictures` y MediaStore | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (`RELATIVE_PATH`) |
| Avisos de la hoja visibles | 🔧 H5 (aviso de permiso) | ❔ | ❔ | ❔ | 🔧 H5 (aviso de permiso) | ❔ | 🔧 H5 («Imagen guardada») | ❔ |
| Compartir: `SEND` con URI del `FileProvider` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (con vista previa) |
| Persistencia tras cerrar a la fuerza | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ícono en el launcher | PNG 🔧 H6 | PNG 🔧 H6 | adaptativo ✅ | adaptativo ✅ | ❔ | adaptativo ✅ | ❔ | ❔ (el launcher no dibuja con TCG) |
| Pantalla de inicio | ❔ | ❔ | ❔ | ❔ | ❔ | `layer-list` ✅ (oscuro) | ❔ | Android 12+ ✅ claro y oscuro |
| Modo oscuro del sistema (tema «Auto») | ➖ | ➖ | ➖ | ➖ | ➖ | ✅ | ❔ | ❔ (solo la pantalla de inicio) |
| Nombre según idioma del sistema | «Battery» (en) ✅ | «Battery» ✅ | «Battery» ✅ | «Battery» ✅ | ❔ | «Batería» (es) ✅ | ❔ | ❔ |
| Modo avión | ❔ | ❔ | ❔ | ❔ | ❔ | ✅ | ❔ | ❔ |
| Nombre de los campos para accesibilidad | 🔧 H7 | 🔧 H7* | 🔧 H7* | 🔧 H7* | ✅* (motor) | ✅* | ✅* | ✅* |
| Crashes / ANR de la app en `logcat` | ninguno | ninguno | ninguno | ninguno | ninguno | ninguno | ninguno | ninguno |

Notas:

- \* Por código y pruebas de semántica; en el emulador se comprobó con `uiautomator` solo en API 24.
- Pantalla de inicio ❔: en esas versiones la primera captura ya mostraba la app (dura menos que `am start -W`).
- Campo de porciento ❔: el fallo se vio y su corrección se comprobó en API 24; el código es el mismo en todas.
- **Tarjeta SD:** en API 24–28 `gal` guardó en `/storage/emulated/0/Pictures` sin configurar tarjeta
  SD aparte (el AVD trae el almacenamiento emulado por defecto). La advertencia del README de `gal`
  («los emuladores de API < 29 necesitan tarjeta SD») no hizo falta aquí.
- En API 28 y 30 el primer intento automático lo tapó el diálogo «System UI isn't responding» del
  propio emulador (la interfaz del sistema no da abasto con TCG; no es la app). Se repitieron
  con el APK final ocultando esos diálogos (`settings put global hide_error_dialogs 1`); en API 28
  el guardado y el compartir se terminaron a mano porque el guion leyó mal la pantalla tras el aviso.
- «Modo avión» se probó solo en API 29: la app no pide `INTERNET` y no tiene código de red, así
  que el resultado no depende de la versión.

## Hallazgos

Severidad: **Alta** impide una tarea o deja fuera a usuarios de TalkBack; **Media** se nota y
confunde, pero hay forma de seguir; **Baja** cosmético.

### H1 · Media · El permiso de almacenamiento se pedía dos veces (Android 7 a 9) — resuelto

Al tocar «Guardar en el teléfono» y negar el permiso, el diálogo volvía a salir enseguida, ya con
la casilla «No volver a preguntar». La app llamaba a `Gal.requestPermission()` y luego
`Gal.putImageBytes()`, que en `gal` 3.0.1 vuelve a pedir el permiso por dentro
(`gal_method_channel.dart`: `await requestPermission(...)` antes de `putImageBytes`).

Evidencia (API 24, APK anterior): tras «DENY», `uiautomator` volvía a encontrar
`'Allow Battery to access photos, media, and files on your device?'` con `"Don't ask again"`.
Con la corrección (API 24, 25, 26 y 27): `pide permiso de almacenamiento` → `OK: no lo vuelve a pedir tras negar`.
Capturas: [`qa/24_permiso_dos_veces_antes.png`](qa/24_permiso_dos_veces_antes.png) y [`qa/24_permiso_aviso_despues.png`](qa/24_permiso_aviso_despues.png).

### H2 · Media · El selector de hora mostraba un cuadro vacío en lugar del ícono del teclado — resuelto

`uses-material-design: false` dejaba fuera la fuente Material Icons, que usa el `TimePickerDialog`
de Material para el botón «Switch to text input mode» (y el reloj, en el modo teclado). Se veía `☒`.

Evidencia: [`qa/24_timepicker_antes.png`](qa/24_timepicker_antes.png) (antes), [`qa/24_timepicker_despues.png`](qa/24_timepicker_despues.png) y [`qa/29_timepicker.png`](qa/29_timepicker.png) (después).

### H3 · Media (accesibilidad) · «Cancel» y «OK» del selector de hora con contraste 2,3:1 — resuelto

Los botones de texto usaban el ámbar de relleno (`#E39B2D`) sobre blanco: 2,3:1, por debajo de 4,5:1.
Además «a. m./p. m.» elegido salía en azul (el `tertiary` por defecto heredaba el azul de info).
Ahora usan `ambTx` (`#8A5300`, 6,3:1) y a. m./p. m. elegido va en ámbar con texto oscuro.

Evidencia: las mismas capturas que H2 (en la de después, «Cancel»/«OK» en ámbar oscuro y «AM» en ámbar).

### H4 · Media · Con letra grande, «100 %» se veía como «|00» — resuelto

El campo de porciento de De noche mide 100 dp (DESIGN). Con «Letra grande» (×1,2) el valor no
cabía y el `TextField` se desplazaba: se veía «|00» con 100 y «|5» con 150. Las pruebas de desborde
no lo detectaban porque un `TextField` no desborda: desplaza el texto.

Evidencia: [`qa/24_porciento_antes.png`](qa/24_porciento_antes.png) y [`qa/24_porciento_despues.png`](qa/24_porciento_despues.png) (letra grande, APK final). Corrección: en campos estrechos, relleno de 8 dp, sin el
ícono de error dentro (el mensaje de abajo ya lo lleva) y letra hasta ×1,3.

### H5 · Media · Los avisos de la hoja de compartir quedaban tapados por la hoja — resuelto

«Imagen guardada: reporte-noche.png», «No se pudo guardar la imagen» (y el nuevo aviso de permiso)
eran `SnackBar` del `Scaffold` principal, que está debajo de la hoja modal: el usuario no veía
ninguna confirmación de que se guardó.

Al corregirlo apareció un segundo detalle en el emulador API 24: al negar el permiso, Android entrega la
respuesta **antes** de reanudar la app; el aviso se creaba con la app en pausa y su temporizador de
2,6 s vencía antes del primer fotograma (con TCG la reanudación tarda más). Ahora el tiempo cuenta
desde que el aviso se dibuja.

Evidencia: prueba de impacto en `test/widget/qa_regressions_test.dart` (con el código anterior el
centro del aviso caía sobre la hoja), [`qa/30_aviso_guardado.png`](qa/30_aviso_guardado.png) (API 30) y
[`qa/24_permiso_aviso_despues.png`](qa/24_permiso_aviso_despues.png) (API 24, aviso tras negar).

### H6 · Baja · Ícono cuadrado lleno en Android 7.0 y 7.1 — resuelto

Los PNG de respaldo (API 24–25 no usan el ícono adaptativo) llenaban todo el cuadrado: en el
launcher se veía como una baldosa más grande que las demás. Lint: `IconLauncherShape` (5 avisos).
Ahora hay un cuadrado redondeado con margen transparente y un `roundIcon` circular para Android 7.1.

Evidencia: [`qa/25_icono_antes.png`](qa/25_icono_antes.png) (Android 7.1, antes) y [`qa/24_icono_despues.png`](qa/24_icono_despues.png) (Android 7.0, APK final).

### H7 · Alta (accesibilidad) · En Android 8.1 o anterior, TalkBack no decía el nombre de los campos — resuelto en la app, sin verificar con TalkBack

El motor de Flutter (`BaseRoleConfigurator.configureLabelAndValue`) solo llama a `setHintText`
con la etiqueta de un campo de texto **desde API 28**; antes, el nodo lleva solo el valor. En el
volcado de API 24 el campo de consumo era `class="android.widget.EditText" text="600" content-desc=""`:
TalkBack habría dicho «600, cuadro de edición», sin «Consumo de la casa».

Corrección: `MainActivity` pasa `Build.VERSION.SDK_INT` a `main(args)` y, en API < 28, el campo va
dentro de un nodo contenedor con su nombre. Comprobado con pruebas de semántica (API 24, 27, 28 y 36)
y con `uiautomator` en el emulador API 24 con el APK final:

```xml
<node class="android.view.View" content-desc="Home power use (W)" focusable="true" bounds="[74,939][1006,1094]">
  <node class="android.widget.EditText" text="600" content-desc="" clickable="true" focusable="true" bounds="[74,939][1006,1094]" />
</node>
```

**No se pudo comprobar con TalkBack real**: falta confirmar que TalkBack enfoca y lee el nodo
contenedor antes del campo.

### H8 · Alta · Al cambiar el tema desde Ajustes, la hoja quedaba ilegible — resuelto

Encontrado al probar en un teléfono, después de este QA. Al elegir «Oscuro» con la hoja de Ajustes
abierta, el fondo de la hoja seguía blanco (el color se fijaba al abrirla) mientras el texto ya era
claro: el título, «Idioma», «Colores de la pantalla», «Letra grande» y «Borrar mis datos» casi no se
veían. Al pasar de oscuro a claro, al revés. Ahora el fondo se pinta con el tema actual.

Evidencia: [`qa/24_tema_antes.png`](qa/24_tema_antes.png) (la captura ya estaba en este QA y no se
detectó), [`qa/24_tema_oscuro_despues.png`](qa/24_tema_oscuro_despues.png) y
[`qa/24_tema_claro_despues.png`](qa/24_tema_claro_despues.png).

### Observaciones sin cambio

- **Compartir tarda en el emulador:** generar el PNG de 1080 × 2304 px con TCG tardó hasta 16 s;
  mientras, los botones quedan deshabilitados sin indicador de progreso. En un teléfono debería
  tardar menos de un segundo; si en uno viejo se nota, conviene un indicador.
- **La tarjeta de resultado es un solo nodo para TalkBack** con su botón «Compartir resultado»
  (o «Ir al dato») dentro: se lee todo junto y el doble toque activa el botón. Es usable, pero
  conviene escucharlo en un teléfono.
- **Lint `ScopedStorage`:** avisa que `WRITE_EXTERNAL_STORAGE` no da acceso en Android 10. Es esperado:
  el permiso lleva `maxSdkVersion="29"` y en Android 10 `gal` no lo pide (comprobado en API 29).
- **Lint `AndroidGradlePluginVersion`:** hay un Gradle más nuevo. No afecta.
- **`logcat`:** solo ruido del emulador (`eglCodecCommon`, `EGL Error: Success` de Impeller sobre
  SwiftShader, SELinux `max_map_count`, propiedades de proveedor). Ninguna excepción de la app.
- **Otros idiomas del sistema:** con el sistema en francés, alemán, etc., el nombre es «Batería»
  (los valores por defecto son en español). Es lo esperado: la app solo tiene español e inglés.

## Revisión estática

- **Lint (`./gradlew :app:lintRelease`, `minSdk` 24):** 0 errores, 7 avisos (los 5 de `IconLauncherShape`
  quedaron resueltos con H6). Ningún `NewApi`, ni en código ni en recursos.
- **`aapt2 dump badging`:** `minSdkVersion` 24, `targetSdkVersion` 36, `native-code` solo `arm64-v8a`
  (en el APK arm64). Permisos: `WRITE_EXTERNAL_STORAGE` y `READ_EXTERNAL_STORAGE` (este lo agrega el
  merge), ambos con `maxSdkVersion` 29, y `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (de AndroidX). Sin `INTERNET`.
- **Recursos por versión:** `mipmap/ic_launcher` en PNG (mdpi a xxxhdpi) + `anydpi-v26`;
  `style/LaunchTheme` en `()`, `night`, `v31` y `night-v31`; `color/splash_background` claro y oscuro;
  `string/app_name` «Batería» y `en` «Battery». El `layer-list` de la pantalla de inicio usa
  `android:width/height/gravity` en un `<item>` (API 23+) y un `VectorDrawable` (API 21+): válidos en API 24.
- **Plugins en API 24–29:**
  - `gal`: en API ≤ 29 escribe con `MediaStore.MediaColumns.DATA` en `Pictures/`; pide
    `WRITE_EXTERNAL_STORAGE` en API ≤ 28 y en API 29 solo si se guarda en un álbum (la app no usa
    álbum). No hace falta `requestLegacyExternalStorage`. Comprobado en 24–30.
  - `share_plus`: copia el archivo a `cache/share_plus/` y comparte con su `ShareFileProvider`
    (`${applicationId}.flutter.share_provider`) y `FLAG_GRANT_READ_URI_PERMISSION`. Comprobado en 24–30.
  - `path_provider_android` 2.3.1 llama a Java por `jni`: sus reglas de R8
    (`-keep class com.github.dart_lang.jni.** { *; }`) están en `configuration.txt` y las clases salen
    sin ofuscar en `mapping.txt`. `getTemporaryDirectory()` funcionó en release en todas las versiones.
  - `shared_preferences_android`: usa Pigeon; la persistencia funcionó en release en todas las versiones.

## Lo resuelto

| Hallazgo | Commit |
|---|---|
| H2, H3 · selector de hora: fuente de íconos y colores | `76a5979` |
| H1 · permiso de almacenamiento una sola vez, con aviso si se niega | `8051afc` |
| H7, H4 · nombre de los campos en API < 28 y campo de porciento | `4ab803c` |
| H6 · ícono de Android 7 con margen y `roundIcon` | `3396360` |
| H5 · avisos visibles encima de la hoja | `a18701f`, `8d13f80`, `3653d06` |
| H8 · fondo de las hojas al cambiar el tema | `a6c411e` |

Las correcciones tienen pruebas en `test/widget/qa_regressions_test.dart` (15 pruebas; las de cada
hallazgo fallan con el código anterior, comprobado volviendo a esa versión de los archivos; el
detalle del temporizador de H5 solo se comprobó en el emulador). Tras cada commit: `flutter analyze` sin avisos y `flutter test` en verde
(186 pruebas). El APK arm64-v8a final pesa 8 226 558 bytes (antes 8 187 755; +37 KB por los íconos
redondos y la fuente de íconos recortada) y sigue sin `INTERNET`.

## Lo que no se pudo resolver

Todos los hallazgos tienen corrección. Quedan sin verificar:

- **TalkBack real.** La corrección H7 se comprobó con el árbol de semántica y con `uiautomator`,
  pero no escuchando TalkBack: las imágenes de emulador no lo traen. Falta probarlo en un teléfono.
- **Android 16 (API 36).** No había imagen x86_64 de emulador para 36 en este SDK; la versión
  reciente probada es Android 15 (API 35). `targetSdk` 36 se revisó solo de forma estática.
- **Rendimiento.** Con emulación por software los tiempos no dicen nada de un teléfono.

## Duración (rama `feat/duracion-bateria`)

La pestaña Duración se probó **solo con pruebas automáticas**: este entorno no tiene Android SDK,
así que no se compiló el APK ni se probó en emulador.

- `flutter analyze` sin avisos y `flutter test` en verde (247 pruebas; antes, 188).
- Los 12 casos de `test-vectors-runtime.json` y los 20 de siempre (De noche no cambió).
- Sin desbordes a 320, 360 y 411 dp, con y sin letra grande, en claro y oscuro, con y sin hora de
  fin, y en inglés a 320 dp con letra grande. La barra de tres pestañas cabe.
- Todo lo táctil mide ≥ 48 dp, incluida la X «Quitar la hora de fin» (48 × 56 dp).
- La primera vez abre Duración; quien ya tenía una pestaña guardada sigue en ella.

Falta en emulador o teléfono: la matriz de versiones de arriba con la barra de tres pestañas,
TalkBack en Duración (orden de foco, la X y el veredicto), el selector de hora de fin y compartir
`reporte-duracion.png` por WhatsApp y Telegram.

## Lo que falta probar en un teléfono real

1. **TalkBack** en Android 7 u 8 (H7) y en uno reciente: nombre de cada campo, la batería
   deslizable, la tarjeta de resultado, las hojas y el aviso «Imagen guardada».
2. **Compartir por WhatsApp y Telegram** el reporte de noche y el de carga, y que se vea bien en el chat.
3. **Guardar en la galería** en un Android 7, 8 o 9 de verdad (permiso, aparece en Galería/Fotos)
   y en uno de 10+ (sin permiso).
4. **Tiempo de arranque y de «Compartir imagen»** en un teléfono barato y viejo.
5. **Ícono** en launchers de fabricantes (Samsung, Xiaomi, Motorola) en Android 7 y 8+.
6. **Teclados de fabricante** (Samsung, Gboard en español): coma decimal y el botón «Listo».
7. **Instalar el APK arm64-v8a firmado con la clave de release** (aquí se probó el x86_64 firmado con la de debug).
