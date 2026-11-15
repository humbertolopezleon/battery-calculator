# Calculadora de Batería · Battery Calculator

App web instalable (PWA), en español e inglés. Funciona sin internet después de abrirla una vez.
Installable web app (PWA), in Spanish and English. Works offline after the first visit.

## Publicar / Publish
Sube esta carpeta a una dirección https (por ejemplo, arrastrándola en https://app.netlify.com/drop).
Upload this folder to an https address (for example, by dropping it on https://app.netlify.com/drop).

## Instalar / Install
- Android (Chrome): botón **Instalar** / **Install**, o menú ⋮ → Instalar aplicación.
- iPhone / iPad (Safari): Compartir → Agregar a pantalla de inicio / Share → Add to Home Screen.
- Computadora / Computer (Chrome, Edge): botón **Instalar** / **Install** o el ícono de la barra de direcciones.

## Idioma / Language
La app usa el idioma del dispositivo (español si está en español; inglés en los demás casos). Se puede cambiar arriba a la derecha con el botón 🌐 Español / English, y la elección se recuerda.
The app follows the device language (Spanish for Spanish devices, English otherwise). It can be switched at the top right with the 🌐 Español / English button, and the choice is remembered.

## Publicar cambios / Updating
Si cambias `index.html`, sube el número en `sw.js` (`battery-v5` → `v6`) y la constante `APP_VERSION`.
If you change `index.html`, bump the number in `sw.js` (`battery-v5` → `v6`) and the `APP_VERSION` constant.

## Archivo único para WhatsApp / Single file
`npm install` (una vez) y luego `node build.js` → `dist/Battery-Calculator.html` (fuentes e ícono incrustados, sin manifiesto ni service worker, minificado, < 150 KB).

## Pruebas / Tests
`npm test` (genera el archivo único y corre Playwright sobre el archivo único y la versión instalable).
