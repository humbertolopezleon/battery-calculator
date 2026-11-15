// Que nada se salga de la pantalla.
const { test, expect, type } = require('./fixtures');

async function overflow(page) {
  return page.evaluate(() => {
    const W = document.documentElement.clientWidth;
    const out = [];
    if (document.documentElement.scrollWidth > W) out.push(`scrollWidth ${document.documentElement.scrollWidth} > ${W}`);
    for (const el of document.querySelectorAll('body *')) {
      const r = el.getBoundingClientRect();
      if (!r.width || !r.height) continue;
      if (r.right > W + 0.5 || r.left < -0.5) out.push(`${el.tagName}#${el.id}.${el.className} [${Math.round(r.left)}, ${Math.round(r.right)}]`);
    }
    return out;
  });
}

for (const width of [320, 360, 414, 768, 1280]) {
  for (const lang of ['es', 'en']) {
    for (const big of [false, true]) {
      test(`${width}px ${lang}${big ? ' texto grande' : ''}`, async ({ page, app }) => {
        await page.setViewportSize({ width, height: 900 });
        await app.open();
        await page.click(`#langGroup [data-lang="${lang}"]`);
        if (big) await page.click('#textBtn');
        // valores largos: avisos, días, reserva abierta
        await page.locator('#rsvOn').check();
        await type(page, '#n-watts', '1.200');
        await type(page, '#cap', '150');
        expect(await overflow(page)).toEqual([]);
        await page.click('#modeAh');
        expect(await overflow(page)).toEqual([]);
        await page.click('#modeKwh');
        await page.click('#tab-carga');
        await type(page, '#c-watts', '12000');
        expect(await overflow(page)).toEqual([]);
        await page.click('#c-modeA');
        expect(await overflow(page)).toEqual([]);
      });
    }
  }
}
