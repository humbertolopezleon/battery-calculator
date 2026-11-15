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

test('archivo único: funciona sin internet y no pide nada más', async ({ page, app, context }, info) => {
  test.skip(info.project.name !== 'archivo-unico');
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

test('instalable: se abre sin internet después de la primera visita', async ({ page, app, context }, info) => {
  test.skip(info.project.name !== 'instalable');
  await page.goto(app.url);
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    const keys = await caches.keys();
    return { scope: reg.scope, keys };
  });
  await expect.poll(() => page.evaluate(async () => (await caches.keys()).includes('watts-v4'))).toBe(true);
  await context.setOffline(true);
  await page.reload();
  await expect(page.locator('#appVer')).toContainText('1.3');
  await expect(page.locator('#n-f1')).not.toHaveText('–');
});
