// Cálculos de noche y de carga comparados con la fórmula.
const { test, expect, readNum, readMinutes, type } = require('./fixtures');

const close = (a, b, tol) => expect(Math.abs(a - b), `${a} ≈ ${b}`).toBeLessThanOrEqual(tol);

for (const lang of ['en', 'es']) {
  test.describe(`noche (${lang})`, () => {
    test.use({ locale: lang === 'en' ? 'en-US' : 'es-ES' });
    const casos = [
      // capacidad kWh, porciento, consumo W, pérdidas, reserva (null = 6% por defecto)
      { cap: 10, pct: 75, w: 600, loss: true, rsv: null },
      { cap: 10, pct: 75, w: 600, loss: false, rsv: null },
      { cap: 5.12, pct: 100, w: 450, loss: true, rsv: null },
      { cap: 15, pct: 40, w: 1500, loss: true, rsv: 12.5 },
      { cap: 20.48, pct: 63, w: 2200, loss: false, rsv: 20 },
      { cap: 7.5, pct: 30, w: 800, loss: true, rsv: 0 },
    ];
    for (const c of casos) {
      test(`${c.cap} kWh, ${c.pct}%, ${c.w} W, pérdidas ${c.loss}, reserva ${c.rsv ?? 6}`, async ({ page, app }) => {
        await app.open();
        const dec = s => (lang === 'es' ? String(s).replace('.', ',') : String(s));
        await type(page, '#cap', dec(c.cap));
        await type(page, '#n-pctNum', String(c.pct));
        await type(page, '#n-watts', String(c.w));
        await page.locator('#n-loss').setChecked(c.loss);
        if (c.rsv !== null) {
          await page.locator('#rsvOn').check();
          await type(page, '#rsv', dec(c.rsv));
        }
        const reserva = c.rsv ?? 6;
        const util = (c.cap * (c.pct - reserva)) / 100 * (c.loss ? 0.9 : 1);
        const horas = util / (c.w / 1000);
        close(readNum(await page.textContent('#n-f1'), lang), util, 0.0051);
        close(readMinutes(await page.textContent('#n-f2')), horas * 60, 0.51);
        const perPct = c.cap / 100 * 1000 * (c.loss ? 0.9 : 1);
        close(readNum(await page.textContent('#n-f3'), lang), perPct, 0.51);
        // Paso a paso: el porciento útil con un decimal cuando no es entero
        const pasos = await page.textContent('#n-steps');
        const u = c.pct - reserva;
        const uTxt = Number.isInteger(u) ? String(u) : (lang === 'es' ? String(u).replace('.', ',') : String(u));
        expect(pasos).toContain(`= ${uTxt}%`);
      });
    }
  });

  test.describe(`carga (${lang})`, () => {
    test.use({ locale: lang === 'en' ? 'en-US' : 'es-ES' });
    const casos = [
      { cap: 10, pct: 30, tgt: 100, w: 2500 },
      { cap: 10, pct: 30, tgt: 80, w: 2500 },
      { cap: 5.12, pct: 95, tgt: 100, w: 1000 },
      { cap: 15, pct: 0, tgt: 90, w: 3000 },
      { cap: 10, pct: 50, tgt: 100, w: 800 },
      { cap: 10.24, pct: 85, tgt: 95, w: 1200 },
    ];
    for (const c of casos) {
      test(`${c.cap} kWh, ${c.pct}% → ${c.tgt}%, ${c.w} W`, async ({ page, app }) => {
        await app.open();
        await page.click('#tab-carga');
        await type(page, '#cap', lang === 'es' ? String(c.cap).replace('.', ',') : String(c.cap));
        await type(page, '#c-pctNum', String(c.pct));
        await type(page, '#c-tgtNum', String(c.tgt));
        await type(page, '#c-watts', String(c.w));
        const kw = c.w / 1000;
        const rapido = c.cap * Math.max(0, Math.min(c.tgt, 90) - c.pct) / 100;
        const lento = c.cap * Math.max(0, c.tgt - Math.max(c.pct, 90)) / 100;
        const horas = rapido / kw + lento / (kw / 2);
        close(readMinutes(await page.textContent('#c-f1')), horas * 60, 1);
        close(readNum(await page.textContent('#c-f2'), lang), c.cap * (c.tgt - c.pct) / 100, 0.0051);
        const pasos = await page.textContent('#c-steps');
        if (lento > 0) expect(pasos).toContain(lang === 'es' ? 'a mitad de potencia' : 'at half power');
        else expect(pasos).not.toContain(lang === 'es' ? 'a mitad de potencia' : 'at half power');
      });
    }
  });
}

test.describe('carga en amperios', () => {
  test.use({ locale: 'en-US' });
  test('50 A × 51.2 V = 2560 W', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await page.click('#c-modeA');
    await expect(page.locator('#c-aResult')).toContainText('2560 W');
    const horas = 10 * 0.6 / 2.56 + 10 * 0.1 / 1.28;
    close(readMinutes(await page.textContent('#c-f1')), horas * 60, 1);
    await expect(page.locator('#c-steps')).toContainText('50 A × 51.2 V = 2560 W');
  });
});
