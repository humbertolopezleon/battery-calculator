// Reporte en imagen PNG, en los dos idiomas.
const { test, expect, setting } = require('./fixtures');
const fs = require('fs');

function pngSize(buf) {
  expect(buf.subarray(0, 8).toString('hex')).toBe('89504e470d0a1a0a');
  return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20) };
}

test.beforeEach(async ({ page }) => {
  // Sin la ventana "Guardar como" de la computadora: se usa la descarga normal
  await page.addInitScript(() => { delete window.showSaveFilePicker; window.showSaveFilePicker = undefined; });
});

async function download(page, btn) {
  const [d] = await Promise.all([page.waitForEvent('download'), page.click(btn)]);
  const file = await d.path();
  return { name: d.suggestedFilename(), buf: fs.readFileSync(file) };
}

for (const [lang, noche, carga, msg] of [
  ['es', 'reporte-noche-', 'reporte-carga-', 'Reporte descargado'],
  ['en', 'battery-night-report-', 'battery-charging-report-', 'Report downloaded'],
]) {
  test(`PNG en ${lang}`, async ({ page, app }) => {
    await app.open();
    await setting(page, `#langGroup [data-lang="${lang}"]`);
    const n = await download(page, '#n-save');
    expect(n.name.startsWith(noche) && n.name.endsWith('.png')).toBe(true);
    const sn = pngSize(n.buf);
    expect(sn.w).toBe(1080);
    expect(sn.h).toBeGreaterThan(1200);
    await expect(page.locator('#n-msg')).toContainText(msg);

    await page.click('#tab-carga');
    const c = await download(page, '#c-save');
    expect(c.name.startsWith(carga)).toBe(true);
    expect(pngSize(c.buf).w).toBe(1080);
  });
}

test('el texto grande no cambia el reporte', async ({ page, app }) => {
  await app.open();
  const a = pngSize((await download(page, '#n-save')).buf);
  await setting(page, '#textBtn');
  const b = pngSize((await download(page, '#n-save')).buf);
  expect(b).toEqual(a);
});

test('el reporte de carga incluye el tramo a mitad de potencia', async ({ page, app }) => {
  await app.open();
  await setting(page, '#langGroup [data-lang="es"]');
  await page.click('#tab-carga');
  // Las líneas del reporte son las del paso a paso: de 30% a 100% hay 2 líneas más (tramo lento y total)
  await expect(page.locator('#c-steps p')).toHaveCount(6);
  const conTramo = pngSize((await download(page, '#c-save')).buf);
  await page.fill('#c-tgtNum', '80');
  await expect(page.locator('#c-steps p')).toHaveCount(4);
  const sinTramo = pngSize((await download(page, '#c-save')).buf);
  expect(conTramo.h).toBeGreaterThan(sinTramo.h);
});
