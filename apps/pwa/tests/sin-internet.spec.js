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

test('instalable: se abre sin internet después de la primera visita', async ({ page, app, context }) => {
  await page.goto(app.url);
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    const keys = await caches.keys();
    return { scope: reg.scope, keys };
  });
  await expect.poll(() => page.evaluate(async () => (await caches.keys()).includes('battery-v5'))).toBe(true);
  await context.setOffline(true);
  await page.reload();
  await expect(page.locator('#appVer')).toContainText('1.3');
  await expect(page.locator('#n-f1')).not.toHaveText('–');
});
