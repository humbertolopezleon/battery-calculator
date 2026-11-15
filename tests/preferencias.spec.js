// Idioma, tema y letra grande: cambian y se recuerdan al recargar.
const { test, expect } = require('./fixtures');

test.describe('idioma del dispositivo', () => {
  test.describe('es', () => {
    test.use({ locale: 'es-MX' });
    test('arranca en español', async ({ page, app }) => {
      await app.open();
      await expect(page.locator('html')).toHaveAttribute('lang', 'es');
      await expect(page.locator('h1')).toHaveText('Calculadora de Watts');
    });
  });
  test.describe('en', () => {
    test.use({ locale: 'en-GB' });
    test('arranca en inglés', async ({ page, app }) => {
      await app.open();
      await expect(page.locator('html')).toHaveAttribute('lang', 'en');
      await expect(page.locator('h1')).toHaveText('Watt Calculator');
    });
  });
});

test.describe('se recuerda al recargar', () => {
  test.use({ locale: 'es-ES' });

  test('cambio de idioma', async ({ page, app }) => {
    await app.open();
    await page.click('#langGroup [data-lang="en"]');
    await expect(page.locator('h1')).toHaveText('Watt Calculator');
    await expect(page.locator('#volt')).toHaveValue('51.2'); // el número cambia al formato del idioma
    await page.reload();
    await expect(page.locator('h1')).toHaveText('Watt Calculator');
    await expect(page.locator('#langGroup [data-lang="en"]')).toHaveAttribute('aria-pressed', 'true');
    await page.click('#langGroup [data-lang="es"]');
    await page.reload();
    await expect(page.locator('h1')).toHaveText('Calculadora de Watts');
    await expect(page.locator('#volt')).toHaveValue('51,2');
  });

  test('tema Auto / Claro / Oscuro', async ({ page, app }) => {
    await page.emulateMedia({ colorScheme: 'light' });
    await app.open();
    const bg = () => page.evaluate(() => getComputedStyle(document.body).backgroundColor);
    const light = 'rgb(237, 241, 245)', dark = 'rgb(15, 26, 43)';
    await expect(page.locator('#themeGroup [data-theme-set="auto"]')).toHaveAttribute('aria-pressed', 'true');
    await expect.poll(bg).toBe(light);
    await page.click('#themeGroup [data-theme-set="dark"]');
    await expect.poll(bg).toBe(dark);
    await page.reload();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
    await expect(page.locator('#themeGroup [data-theme-set="dark"]')).toHaveAttribute('aria-pressed', 'true');
    await expect.poll(bg).toBe(dark);
    // Claro gana aunque el teléfono esté en oscuro
    await page.emulateMedia({ colorScheme: 'dark' });
    await page.click('#themeGroup [data-theme-set="light"]');
    await page.reload();
    await expect.poll(bg).toBe(light);
    // Auto sigue al teléfono
    await page.click('#themeGroup [data-theme-set="auto"]');
    await page.reload();
    await expect(page.locator('html')).not.toHaveAttribute('data-theme', /.+/);
    await expect.poll(bg).toBe(dark);
  });

  test('texto grande (Aa)', async ({ page, app }) => {
    await app.open();
    const size = sel => page.evaluate(s => parseFloat(getComputedStyle(document.querySelector(s)).fontSize), sel);
    const body0 = await size('body'), h10 = await size('h1');
    await page.click('#textBtn');
    await expect(page.locator('#textBtn')).toHaveAttribute('aria-pressed', 'true');
    expect((await size('body')) / body0).toBeCloseTo(1.2, 2);
    expect((await size('h1')) / h10).toBeGreaterThan(1.1);
    await page.reload();
    await expect(page.locator('#textBtn')).toHaveAttribute('aria-pressed', 'true');
    expect((await size('body')) / body0).toBeCloseTo(1.2, 2);
    await page.click('#textBtn');
    await page.reload();
    expect(await size('body')).toBeCloseTo(body0, 2);
  });

  test('los datos se recuerdan', async ({ page, app }) => {
    await app.open();
    await page.fill('#cap', '7,5');
    await page.fill('#n-sunrise', '06:30');
    await page.reload();
    await expect(page.locator('#cap')).toHaveValue('7,5');
    await expect(page.locator('#n-sunrise')).toHaveValue('06:30');
  });
});

test.describe('botones de al menos 44 px', () => {
  for (const big of [false, true]) {
    test(`texto grande: ${big}`, async ({ page, app }) => {
      await page.setViewportSize({ width: 320, height: 800 });
      await app.open();
      if (big) await page.click('#textBtn');
      for (const b of await page.locator('button:visible').all()) {
        const box = await b.boundingBox();
        expect(box.height, await b.textContent()).toBeGreaterThanOrEqual(44);
        expect(box.width, await b.textContent()).toBeGreaterThanOrEqual(44);
      }
    });
  }
});
