#!/usr/bin/env node
/*
  Genera el archivo único para mandar por WhatsApp:
    Battery-Calculator.html   (en esta misma carpeta)
  - Parte de src/index.html (esta app tiene su propia fuente; no depende de la otra).
  - Fuentes e ícono incrustados en base64.
  - Minificado, sin peticiones externas.
  Uso: node build.js
*/
const fs = require('fs');
const path = require('path');
const { minify } = require('html-minifier-terser');

const ROOT = __dirname;
const OUT = path.join(ROOT, 'Battery-Calculator.html');
const MAX_BYTES = 150 * 1024;

const b64 = rel => fs.readFileSync(path.join(ROOT, rel)).toString('base64');

function replaceOnce(src, from, to, what) {
  const n = src.split(from).length - 1;
  if (n !== 1) throw new Error(`build: se esperaba 1 coincidencia de ${what}, hay ${n}`);
  return src.replace(from, () => to);
}

async function build() {
  let html = fs.readFileSync(path.join(ROOT, 'src', 'index.html'), 'utf8');

  html = replaceOnce(html, 'href="icons/favicon-32.png"', `href="data:image/png;base64,${b64('icons/favicon-32.png')}"`, 'favicon');
  for (const w of ['400', '700']) {
    const f = `fonts/atkinson-hyperlegible-latin-${w}-normal.woff2`;
    html = replaceOnce(html, `url(${f})`, `url(data:font/woff2;base64,${b64(f)})`, `fuente ${w}`);
  }

  // Comprobaciones: nada externo ni de la versión instalable
  for (const bad of ['manifest', 'sw.js', 'serviceWorker', 'icons/', 'fonts/', 'http://', 'https://']) {
    if (html.includes(bad)) throw new Error(`build: quedó "${bad}" en el archivo único`);
  }

  const min = await minify(html, {
    collapseWhitespace: true,
    conservativeCollapse: true,
    removeComments: true,
    removeScriptTypeAttributes: true,
    minifyCSS: true,
    minifyJS: { compress: { passes: 2 }, mangle: true, format: { comments: false } },
  });

  fs.writeFileSync(OUT, min);
  const size = Buffer.byteLength(min);
  console.log(`${path.relative(ROOT, OUT)}: ${(size / 1024).toFixed(1)} KB (${size} bytes)`);
  if (size >= MAX_BYTES) throw new Error(`build: el archivo pesa ${size} bytes; el límite es ${MAX_BYTES}`);
}

build().catch(e => { console.error(e.message || e); process.exit(1); });
