#!/usr/bin/env node
/*
  Una sola fuente (src/index.html) → dos resultados, sin código duplicado:

    dist/Battery-Calculator.html   El archivo único para mandar por WhatsApp.
                                   Todo incrustado (fuentes e ícono en base64), minificado,
                                   sin manifiesto ni service worker, y sin ninguna dependencia externa.
    dist/pwa/                      La versión instalable (se publica tal cual en un hosting https).

  Uso: node build.js
*/
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { minify } = require('html-minifier-terser');

const ROOT = __dirname;
const SRC = path.join(ROOT, 'src');
const DIST = path.join(ROOT, 'dist');
const PWA = path.join(DIST, 'pwa');
const MAX_BYTES = 150 * 1024;

const read = rel => fs.readFileSync(path.join(SRC, rel));
const b64 = rel => read(rel).toString('base64');
const FONTS = ['400', '700'].map(w => `fonts/atkinson-hyperlegible-latin-${w}-normal.woff2`);
const PWA_ICONS = ['icon-192.png', 'icon-512.png', 'icon-maskable-512.png', 'apple-touch-icon.png', 'favicon-32.png'];

function replaceOnce(src, from, to, what) {
  const n = src.split(from).length - 1;
  if (n !== 1) throw new Error(`build: se esperaba 1 coincidencia de ${what}, hay ${n}`);
  return src.replace(from, () => to);
}
const block = (src, re, what) => { const m = re.exec(src); if (!m) throw new Error(`build: no encuentro el bloque ${what}`); return m[0]; };

const HTML_BLOCK = /[ \t]*<!--pwa-start-->[\s\S]*?<!--pwa-end-->\n?/;
const JS_BLOCK = /[ \t]*\/\*@pwa-start\*\/[\s\S]*?\/\*@pwa-end\*\/\n?/;

/* ---------- Versión instalable ---------- */
function buildPwa(src) {
  const html = src
    .replace('<!--pwa-start-->\n', '').replace('  <!--pwa-end-->\n', '')
    .replace('  /*@pwa-start*/\n', '').replace('  /*@pwa-end*/\n', '');
  if (/pwa-(start|end)/.test(html)) throw new Error('build: quedaron marcadores pwa en la versión instalable');
  fs.rmSync(PWA, { recursive: true, force: true });
  fs.mkdirSync(path.join(PWA, 'fonts'), { recursive: true });
  fs.mkdirSync(path.join(PWA, 'icons'), { recursive: true });
  fs.writeFileSync(path.join(PWA, 'index.html'), html);
  fs.copyFileSync(path.join(SRC, 'manifest.webmanifest'), path.join(PWA, 'manifest.webmanifest'));
  FONTS.forEach(f => fs.copyFileSync(path.join(SRC, f), path.join(PWA, f)));
  PWA_ICONS.forEach(i => fs.copyFileSync(path.join(SRC, 'icons', i), path.join(PWA, 'icons', i)));
  // El número de VERSION del service worker cambia solo cuando cambia el contenido:
  // así nadie se queda con una copia vieja por olvidar subirlo.
  const appVer = /const APP_VERSION = "([^"]+)"/.exec(html)[1];
  const hash = crypto.createHash('sha256').update(html).update(read('manifest.webmanifest')).digest('hex').slice(0, 8);
  const sw = read('sw.js').toString('utf8').replace(/const VERSION = '[^']*';/, `const VERSION = 'battery-${appVer}-${hash}';`);
  if (!sw.includes(`battery-${appVer}-${hash}`)) throw new Error('build: no pude poner VERSION en sw.js');
  fs.writeFileSync(path.join(PWA, 'sw.js'), sw);
  console.log(`dist/pwa/: version battery-${appVer}-${hash}`);
}

/* ---------- Archivo único ---------- */
// Cosas que NO pueden aparecer nunca en el archivo que se manda por WhatsApp.
const FORBIDDEN = [
  [/https?:\/\//i, 'una dirección http(s)'],
  [/<link\b(?![^>]*\shref="data:)/i, 'una etiqueta <link> que no sea un ícono incrustado'],
  [/<script[^>]*\ssrc\s*=/i, 'un <script src>'],
  [/<(?:img|iframe|source|video|audio|embed|object)\b[^>]*\ssrc\s*=\s*["'](?!data:)/i, 'un recurso con src externo'],
  [/\bhref\s*=\s*["'](?!data:|#)/i, 'un href que no sea interno'],
  [/@import\b/i, 'un @import de CSS'],
  [/(?<![A-Za-z])url\(\s*["']?(?!data:)/, 'un url() de CSS que no sea data:'],
  [/\bfetch\s*\(/, 'una llamada fetch()'],
  [/XMLHttpRequest|WebSocket|EventSource|sendBeacon/, 'una API de red'],
  [/\bimport\s*\(/, 'un import() dinámico'],
  [/serviceWorker|manifest/i, 'restos de la versión instalable'],
  [/fonts\/|icons\//, 'una ruta a fuentes o íconos sueltos'],
].filter(([, why]) => why);

async function buildSingle(src) {
  let html = src;
  html = replaceOnce(html, block(html, HTML_BLOCK, 'HTML pwa'), '', 'bloque HTML pwa');
  html = replaceOnce(html, block(html, JS_BLOCK, 'JS pwa'), '', 'bloque JS pwa');
  html = html.replace(/<link rel="manifest"[^>]*>\s*/g, '')
    .replace(/<meta name="theme-color"[^>]*>\s*/g, '')
    .replace(/<link rel="apple-touch-icon"[^>]*>\s*/g, '')
    .replace(/<meta name="(?:apple-mobile-web-app-capable|mobile-web-app-capable|apple-mobile-web-app-title)"[^>]*>\s*/g, '');

  html = replaceOnce(html, 'href="icons/favicon-32.png"', `href="data:image/png;base64,${b64('icons/favicon-32.png')}"`, 'favicon');
  FONTS.forEach(f => { html = replaceOnce(html, `url(${f})`, `url(data:font/woff2;base64,${b64(f)})`, f); });

  const min = await minify(html, {
    collapseWhitespace: true,
    conservativeCollapse: true,
    removeComments: true,
    removeScriptTypeAttributes: true,
    minifyCSS: true,
    minifyJS: { compress: { passes: 2 }, mangle: true, format: { comments: false } },
  });

  // Se revisa el archivo FINAL. Los datos base64 se quitan antes: son datos, no referencias.
  const sinDatos = min.replace(/base64,[A-Za-z0-9+/=]+/g, 'base64,');
  for (const [re, why] of FORBIDDEN) {
    const m = re.exec(sinDatos);
    if (m) throw new Error(`build: el archivo único contiene ${why}: …${sinDatos.slice(Math.max(0, m.index - 30), m.index + 60)}…`);
  }
  for (const f of FONTS) if (!min.includes('data:font/woff2;base64,')) throw new Error('build: faltan las fuentes incrustadas');

  fs.mkdirSync(DIST, { recursive: true });
  const out = path.join(DIST, 'Battery-Calculator.html');
  fs.writeFileSync(out, min);
  const size = Buffer.byteLength(min);
  console.log(`dist/Battery-Calculator.html: ${(size / 1024).toFixed(1)} KB (${size} bytes)`);
  if (size >= MAX_BYTES) throw new Error(`build: el archivo pesa ${size} bytes; el límite es ${MAX_BYTES}`);
}

(async () => {
  const src = fs.readFileSync(path.join(SRC, 'index.html'), 'utf8');
  buildPwa(src);
  await buildSingle(src);
})().catch(e => { console.error(e.message || e); process.exit(1); });
