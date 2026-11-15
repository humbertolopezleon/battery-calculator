// Carga sin internet y sin peticiones externas.
const { test, expect, readNum } = require('./fixtures');

test('cero peticiones externas', async ({ page, app }) => {
  const externas = [];
  const origen = new URL(app.url).origin;
  page.on('request', r => {
    const u = r.url();
    if (u.startsWith('data:') || u.startsWith('blob:')) return;
    if (app.url.startsWith('file:') ? !u.startsWith('file:') : new URL(u).origin !== origen) externas.push(u);
  });
  await app.open();
  await page.click('#tab-carga');
  await page.click('#tab-noche');
  await page.waitForLoadState('networkidle');
  expect(externas).toEqual([]);
});

test('archivo único: funciona sin internet y no pide nada más', async ({ page, app, context }) => {
  const pedidas = [];
  page.on('request', r => { if (!r.url().startsWith('data:')) pedidas.push(r.url()); });
  await context.setOffline(true);
  await page.goto(app.url);
  await page.evaluate(() => document.fonts.ready);
  expect(await page.evaluate(() => document.fonts.check('700 20px "Atkinson Hyperlegible"'))).toBe(true);
  expect(readNum(await page.textContent('#n-f1'), 'en')).toBeGreaterThan(0);
  expect(pedidas).toEqual([app.url]); // solo el propio archivo
  expect(await page.locator('link[rel=manifest]').count()).toBe(0);
});
