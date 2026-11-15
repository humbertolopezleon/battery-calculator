# Battery Calculator · Calculadora de Batería

Calcula **cuánto dura la batería de noche** y **cuánto tarda en cargarse con la red**.
Español e inglés (según el idioma del teléfono), tema Auto/Claro/Oscuro, botón de letra grande
y reporte descargable como imagen PNG. **Funciona sin internet.**

## El archivo para WhatsApp

**[`dist/Battery-Calculator.html`](dist/Battery-Calculator.html)** es el archivo que se distribuye.
Es **un solo archivo** (unos 104 KB) con todo adentro: el código, las fuentes y el ícono van incrustados.
No descarga nada, no usa CDNs, ni librerías, ni cuenta.

**Para quien lo recibe**
1. Descarga el archivo (en WhatsApp, tócalo y guárdalo).
2. Ábrelo con el navegador del teléfono (Chrome o Safari). Si el visor del chat no lo muestra bien, usa "Abrir con…" y elige el navegador.
3. Listo. Los datos que escribes se recuerdan en ese navegador. Para actualizarla, hay que recibir el archivo nuevo.

> Probado con Chromium en computadora, no en iPhone ni Android reales.

### Cómo se garantiza que no dependa de internet
- El build **falla** si el archivo contiene cualquier dirección `http(s)`, `<link>` externo, `<script src>`, `@import`, `url()` que no sea `data:`, `fetch`/`XMLHttpRequest`, o restos de la versión instalable. Se revisa el archivo final.
- El build **falla** si pesa 150 KB o más.
- Una prueba abre el archivo **con la red completamente bloqueada** y comprueba que calcula, cambia idioma y tema, usa las fuentes incrustadas, genera el PNG, no intenta ninguna petición y no da errores de consola.

## La versión instalable (opcional)

[`dist/pwa/`](dist/pwa) es la misma app como carpeta web instalable (PWA). Se publica tal cual en un hosting con **https**
(por ejemplo, arrastrándola a [app.netlify.com/drop](https://app.netlify.com/drop)).

- **Android (Chrome):** botón **Instalar**, o menú ⋮ → *Instalar aplicación*.
- **iPhone / iPad (Safari):** Compartir → *Agregar a pantalla de inicio*.
- **Computadora (Chrome, Edge):** botón **Instalar** o el ícono de la barra de direcciones.

Funciona sin conexión después de la primera visita. El número de versión del service worker cambia solo
cuando cambia el contenido, así que no hay que subirlo a mano.

## Una sola fuente, sin código duplicado

Todo sale de **`src/index.html`**. `npm run build` genera las dos salidas desde ahí:

```
src/                       ← lo único que se edita
├── index.html             (la app: HTML + CSS + JS; los bloques solo-instalables están marcados)
├── manifest.webmanifest   sw.js   fonts/   icons/
build.js                   ← genera dist/
dist/                      ← generado, no se edita a mano
├── Battery-Calculator.html    el archivo único para WhatsApp
└── pwa/                       la versión instalable
tests/                     ← Playwright + axe-core; prueban las dos salidas
```

El archivo único y la versión instalable difieren solo en lo que marcan `<!--pwa-start-->…<!--pwa-end-->`
y `/*@pwa-start*/…/*@pwa-end*/` (aviso de instalar, registro del service worker) y en la etiqueta del manifiesto.

## Desarrollo

```bash
npm install        # una vez
npm run build      # genera dist/Battery-Calculator.html y dist/pwa/
npm test           # construye y corre todas las pruebas (archivo único e instalable)
npm run serve      # prueba la versión instalable en http://127.0.0.1:4173
```

Para cambiar algo: edita `src/index.html`, corre `npm test` y sube también `dist/` (viene versionado para poder
descargar el archivo sin construirlo).

## Reglas que se cumplen

- Cero peticiones externas; sin frameworks ni librerías en ejecución.
- Español e inglés; todo el texto vive en el objeto `STR` de `src/index.html`.
- Diseño para celulares desde 320 px, botones de al menos 44 px.
- Cálculo: energía útil = capacidad × (porciento − reserva) / 100 × 0,9 si se cuentan las pérdidas (reserva 6 % por defecto); tiempo de carga = kWh por cargar ÷ kW, con el tramo de 90 % a 100 % a la mitad de la potencia.

## Versión

`1.3` (constante `APP_VERSION` en `src/index.html`).
