const base = require('@playwright/test');

// "appUrl" viene de cada proyecto en playwright.config.js
const test = base.test.extend({
  appUrl: ['', { option: true }],
  app: async ({ page, appUrl }, use) => {
    await use({
      url: appUrl,
      async open(opts = {}) {
        await page.goto(appUrl);
        if (opts.clear !== false) {
          await page.evaluate(() => localStorage.clear());
          await page.reload();
        }
        await page.locator('#n-headline').waitFor();
        // "Más opciones" viene cerrado; las pruebas lo abren salvo que pidan lo contrario
        if (opts.closed !== true) await page.evaluate(() => { document.getElementById('n-more').open = true; });
      },
    });
  },
});

// Lee un número tal como lo muestra la app ("6,21" en español, "1,234.5" en inglés)
function readNum(text, lang) {
  let t = String(text).replace(/[^\d.,-]/g, '');
  t = lang === 'es' ? t.replace(/\./g, '').replace(',', '.') : t.replace(/,/g, '');
  return parseFloat(t);
}
// "3 h 12 min" -> 192 ; "48 min" -> 48
function readMinutes(text) {
  const h = /(\d+)\s*h/.exec(text), m = /(\d+)\s*min/.exec(text);
  return (h ? +h[1] * 60 : 0) + (m ? +m[1] : 0);
}
// Escribe con el teclado, como una persona
async function type(page, sel, text) {
  const el = page.locator(sel);
  await el.click();
  await el.press('Control+A');
  await el.press('Backspace');
  if (text) await el.pressSequentially(text);
}

// Tema, letra grande e idioma viven en la hoja de Ajustes: se abre, se toca y se cierra
async function setting(page, sel) {
  await page.click('#settingsBtn');
  await page.click(sel);
  await page.click('#settingsDone');
}

module.exports = { test, expect: base.expect, readNum, readMinutes, type, setting };
