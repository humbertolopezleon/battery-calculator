package app.batterycalculator.battery_calculator

import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // La versión de Android llega a main(args) en Dart: en Android 8.1 o anterior, Flutter no
    // pasa a TalkBack la etiqueta de los campos de texto y la app la pone en un nodo aparte.
    override fun getDartEntrypointArgs(): List<String> = listOf("sdk=${Build.VERSION.SDK_INT}")
}
