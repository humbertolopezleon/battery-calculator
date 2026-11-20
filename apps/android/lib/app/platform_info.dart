/// Datos de la plataforma que MainActivity pasa a `main(args)` (ver MainActivity.kt).
library;

/// `Build.VERSION.SDK_INT` del teléfono; 0 si no se sabe (pruebas, otra plataforma).
int androidSdkInt = 0;

/// Lee `sdk=<n>` de los argumentos de arranque.
void readPlatformArgs(List<String> args) {
  for (final a in args) {
    if (a.startsWith('sdk=')) androidSdkInt = int.tryParse(a.substring(4)) ?? 0;
  }
}

/// En Android 8.1 (API 27) o anterior, el motor de Flutter solo da a TalkBack el valor de un
/// campo de texto: su etiqueta se pierde (`setHintText` solo se usa desde API 28). Entonces el
/// nombre del campo va en un nodo propio.
bool get fieldLabelNeedsOwnNode => androidSdkInt > 0 && androidSdkInt < 28;
