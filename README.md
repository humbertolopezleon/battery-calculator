# Battery Calculator · Calculadora de Batería

Calcula **cuánto dura la batería de noche** y **cuánto tarda en cargarse con la red**.
Este repositorio reúne las versiones de la app y el diseño que comparten.

```
apps/
├── web/        La app web (v1.4): el archivo único para WhatsApp y la versión instalable (PWA)
└── android/    La app nativa para Android, hecha con Flutter
design/
└── handoff/    El paquete de diseño: especificación, sistema de diseño, tokens,
                vectores de prueba, capturas, prototipo, fuentes e ícono
```

## La app web — `apps/web/`

Un solo `src/index.html` genera las dos salidas. Detalles en [`apps/web/README.md`](apps/web/README.md).

```bash
cd apps/web
npm install
npm test           # construye dist/ y corre las pruebas de Playwright
```

El archivo para distribuir es [`apps/web/dist/Battery-Calculator.html`](apps/web/dist/Battery-Calculator.html).

## La app Android — `apps/android/`

App Flutter (Flutter 3.50 / Dart 3.14) que sigue el diseño de `design/handoff/`.
Sus pruebas de cálculo leen los casos directamente de
[`design/handoff/docs/test-vectors.json`](design/handoff/docs/test-vectors.json),
así las dos apps se comprueban contra los mismos números.
Cómo compilar, qué APK mandar y cómo crear la firma: [`apps/android/README.md`](apps/android/README.md).

```bash
cd apps/android
flutter test       # lógica, pantallas, accesibilidad y desbordes
```

## El diseño — `design/handoff/`

Es la fuente de verdad para la app Android:

- [`docs/SPEC.md`](design/handoff/docs/SPEC.md) — qué hace la app y cómo calcula
- [`docs/DESIGN.md`](design/handoff/docs/DESIGN.md) — sistema de diseño y pantallas
- [`design/tokens.json`](design/handoff/design/tokens.json) — colores, tipografía y espacios
- [`reference/`](design/handoff/reference) — prototipo HTML y capturas de cada estado
