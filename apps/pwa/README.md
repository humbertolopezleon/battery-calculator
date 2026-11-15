# Battery Calculator · App instalable (PWA)

Carpeta web que se publica tal cual en una dirección https y se instala como app.
Funciona sin internet después de la primera visita. Es independiente de [`../html-single`](../html-single).

## Publicar
Sube esta carpeta a un hosting con https (por ejemplo, arrastrándola a https://app.netlify.com/drop).

## Instalar
- **Android (Chrome):** botón **Instalar**, o menú ⋮ → *Instalar aplicación*.
- **iPhone / iPad (Safari):** Compartir → *Agregar a pantalla de inicio*.
- **Computadora (Chrome, Edge):** botón **Instalar** o el ícono de la barra de direcciones.

## Publicar cambios
Si editas `index.html`, sube `VERSION` en `sw.js` (`battery-v5` → `battery-v6`) y `APP_VERSION`.

## Mantener
```bash
npm install
npm run serve   # http://127.0.0.1:4173
npm test        # Playwright + axe-core, incluye abrirla sin internet
```
Los cambios de código también deben hacerse en [`../html-single/src/index.html`](../html-single/src/index.html): son copias independientes.
