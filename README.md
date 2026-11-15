# Battery Calculator · Calculadora de Batería

Calcula **cuánto dura la batería de noche** y **cuánto tarda en cargarse con la red**.
Funciona sin internet, en español e inglés (según el idioma del teléfono), con tema Auto/Claro/Oscuro,
botón de letra grande y reporte descargable como imagen PNG.

Este repositorio es un **monorepo con dos apps independientes**. Hacen lo mismo, pero se usan y se publican distinto:

| App | Carpeta | Qué es | Para quién |
|---|---|---|---|
| **HTML único** | [`apps/html-single`](apps/html-single) | Un solo archivo, `Battery-Calculator.html`, que se manda por WhatsApp | Quien solo quiere abrirla en el teléfono, sin instalar nada |
| **App instalable (PWA)** | [`apps/pwa`](apps/pwa) | Carpeta web que se publica en una dirección https y se instala como app | Quien la quiere en la pantalla de inicio, con ícono |

Cada carpeta tiene su propio código, sus pruebas y su `package.json`. No comparten archivos: se puede
copiar una sola carpeta a otro lado y sigue funcionando.

---

## Cómo usar el HTML único

**Para quien la recibe**

1. Descarga el archivo `Battery-Calculator.html` (en WhatsApp, tócalo y guárdalo).
2. Ábrelo con el navegador del teléfono (Chrome o Safari). Si el visor del chat no lo muestra bien, usa "Abrir con…" y elige el navegador.
3. Listo: no necesita internet, ni instalación, ni cuenta.

Los datos que escribes se recuerdan en ese navegador. Para actualizarla hay que recibir y abrir el archivo nuevo.

> Probado en Chromium (computadora). Falta probarlo en iPhone y Android reales.

**Para quien la mantiene**

```bash
cd apps/html-single
npm install          # una vez
npm run build        # genera Battery-Calculator.html desde src/index.html
npm test             # construye y corre las pruebas
```

El archivo se genera con fuentes e ícono incrustados y minificado. Debe pesar **menos de 150 KB**
(hoy unos 103 KB); el build falla si se pasa o si queda alguna petición externa.

---

## Cómo usar la app instalable (PWA)

La PWA no se compila: se publica tal cual.

**Publicarla**

1. Sube la carpeta `apps/pwa` a un hosting con **https** (por ejemplo, arrastrándola a [app.netlify.com/drop](https://app.netlify.com/drop)).
2. Abre la dirección que te dé el hosting y pásala a quien vaya a usarla.

**Instalarla** (cada persona, una sola vez)

- **Android (Chrome):** botón **Instalar**, o menú ⋮ → *Instalar aplicación*.
- **iPhone / iPad (Safari):** Compartir → *Agregar a pantalla de inicio*.
- **Computadora (Chrome, Edge):** botón **Instalar** o el ícono de la barra de direcciones.

Después de abrirla una vez con internet, funciona sin conexión.

**Publicar cambios:** si editas `index.html`, sube el número de `VERSION` en `sw.js` (`battery-v5` → `battery-v6`)
y la constante `APP_VERSION`. Sin eso, los teléfonos siguen con la copia guardada.

**Para quien la mantiene**

```bash
cd apps/pwa
npm install          # una vez
npm run serve        # http://127.0.0.1:4173 para probarla a mano
npm test             # pruebas (incluye abrirla sin internet con el service worker)
```

---

## Estructura

```
apps/
├── html-single/              # App 1: un solo archivo
│   ├── src/index.html        #   fuente (sin nada de PWA)
│   ├── build.js              #   genera Battery-Calculator.html
│   ├── Battery-Calculator.html   # resultado listo para mandar
│   ├── fonts/  icons/        #   se incrustan al construir
│   └── tests/
└── pwa/                      # App 2: instalable
    ├── index.html  manifest.webmanifest  sw.js
    ├── fonts/  icons/
    └── tests/
```

## Reglas que cumplen las dos

- Cero peticiones externas: sin CDNs, sin frameworks ni librerías en ejecución.
- Español e inglés; todo el texto vive en el objeto `STR` de cada `index.html`.
- Diseño para celulares desde 320 px, botones de al menos 44 px.
- Cálculo: energía útil = capacidad × (porciento − reserva) / 100 × 0,9 si se cuentan las pérdidas (reserva 6 % por defecto); tiempo de carga = kWh por cargar ÷ kW, con el tramo de 90 % a 100 % a la mitad de la potencia.

## Importante al cambiar código

Las dos apps son independientes, así que **tienen el código duplicado**
(`apps/html-single/src/index.html` y `apps/pwa/index.html`). Un arreglo se debe aplicar en las dos y
correr las pruebas de cada una. La ventaja es que se pueden publicar y versionar por separado.

## Versión

`1.3` (constante `APP_VERSION` en cada `index.html`).
