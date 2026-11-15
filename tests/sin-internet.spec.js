// Carga sin internet y sin peticiones externas.
const { test, expect, readNum, setting } = require('./fixtures');

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
  await expect.poll(() => page.evaluate(async () => (await caches.keys()).some(k => /^battery-1\.4-[0-9a-f]{8}$/.test(k)))).toBe(true);
  await context.setOffline(true);
  await page.reload();
  await expect(page.locator('#appVer')).toContainText('1.4');
  await expect(page.locator('#n-f1')).not.toHaveText('–');
});

test.describe('el archivo único es 100% autónomo', () => {
  const fs = require('fs');
  const path = require('path');
  const FILE = path.join(__dirname, '..', 'dist', 'Battery-Calculator.html');

  test('no contiene ninguna referencia externa (revisión estática)', async ({}, info) => {
    test.skip(info.project.name !== 'archivo-unico');
    const html = fs.readFileSync(FILE, 'utf8').replace(/base64,[A-Za-z0-9+/=]+/g, 'base64,');
    expect(html).not.toMatch(/https?:\/\//i);
    expect(html).not.toMatch(/<link\b(?![^>]*\shref="data:)/i);
    expect(html).not.toMatch(/<script[^>]*\ssrc\s*=/i);
    expect(html).not.toMatch(/@import\b/i);
    expect(html).not.toMatch(/(?<![A-Za-z])url\(\s*["']?(?!data:)/);
    expect(html).not.toMatch(/\bfetch\s*\(|XMLHttpRequest|WebSocket|EventSource|sendBeacon/);
    expect(html).not.toMatch(/serviceWorker|manifest/i);
    expect(fs.statSync(FILE).size).toBeLessThan(150 * 1024);
  });

  test('con la red totalmente bloqueada: calcula, cambia de idioma y tema, y genera el PNG', async ({ browser }, info) => {
    test.skip(info.project.name !== 'archivo-unico');
    const ctx = await browser.newContext({ locale: 'es-ES', acceptDownloads: true, offline: true });
    const intentos = [];
    // Cualquier cosa que no sea el propio archivo (o datos incrustados) se bloquea y se anota
    await ctx.route('**/*', route => {
      const u = route.request().url();
      if (u.startsWith('file://')) return route.continue();
      intentos.push(u); return route.abort();
    });
    const page = await ctx.newPage();
    await page.addInitScript(() => { window.showSaveFilePicker = undefined; });
    const errores = [];
    page.on('pageerror', e => errores.push(e.message));
    page.on('console', m => { if (m.type() === 'error') errores.push(m.text()); });
    await page.goto('file://' + FILE);
    // Las fuentes salen del propio archivo
    await page.evaluate(() => document.fonts.ready);
    expect(await page.evaluate(() => document.fonts.check('700 20px "Atkinson Hyperlegible"') && document.fonts.check('400 20px "Atkinson Hyperlegible"'))).toBe(true);
    const familias = await page.evaluate(() => [...document.fonts].filter(f => f.status === 'loaded').map(f => f.family + f.weight));
    expect(familias.length).toBeGreaterThanOrEqual(2);
    // Todo lo principal funciona
    await page.fill('#n-watts', '800');
    await expect(page.locator('#n-f1')).not.toHaveText('–');
    await page.click('#tab-carga');
    await expect(page.locator('#c-f1')).not.toHaveText('–');
    await setting(page, '#langGroup [data-lang="en"]');
    await expect(page.locator('h1')).toHaveText('Battery Calculator');
    await setting(page, '#themeGroup [data-theme-set="dark"]');
    await setting(page, '#textBtn');
    // Reporte PNG (usa las fuentes incrustadas)
    const [d] = await Promise.all([page.waitForEvent('download'), page.click('#c-save')]);
    const buf = fs.readFileSync(await d.path());
    expect(buf.subarray(0, 8).toString('hex')).toBe('89504e470d0a1a0a');
    expect(buf.readUInt32BE(16)).toBe(1080);
    expect(intentos).toEqual([]);
    expect(errores).toEqual([]);
    await ctx.close();
  });
});
