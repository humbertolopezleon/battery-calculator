# Battery Calculator · HTML único

Un solo archivo (`Battery-Calculator.html`, ~103 KB) que se manda por WhatsApp y se abre en el navegador.
Sin internet, sin instalación, sin cuenta. Es independiente de [`../pwa`](../pwa).

## Usar
1. Descarga `Battery-Calculator.html` y ábrelo con Chrome o Safari.
2. Para actualizar, abre el archivo nuevo.

## Mantener
```bash
npm install
npm run build   # src/index.html → Battery-Calculator.html (fuentes e ícono en base64, minificado, < 150 KB)
npm test        # construye y corre las pruebas (Playwright + axe-core)
```
Edita siempre `src/index.html` y vuelve a construir; `Battery-Calculator.html` es un archivo generado.
Los cambios de código también deben hacerse en [`../pwa/index.html`](../pwa/index.html): son copias independientes.
