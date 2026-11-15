// Mejoras de UI (v1.4): Ajustes, batería en una línea, respuesta fija, "Probar con N W", "Ahora" y cifra protagonista.
const { test, expect, type } = require('./fixtures');

test.use({ locale: 'es-ES' });

test.describe('hoja de Ajustes', () => {
  test('se abre, se cierra con Esc y devuelve el foco', async ({ page, app }) => {
    await app.open();
    await expect(page.locator('#settings')).toBeHidden();
    await page.click('#settingsBtn');
    await expect(page.locator('#settings')).toBeVisible();
    await expect(page.locator('#settings [role=dialog]')).toHaveAttribute('aria-modal', 'true');
    // el foco entra en la hoja (en el tema elegido)
    await expect(page.locator('#themeGroup [data-theme-set="auto"]')).toBeFocused();
    // el fondo queda inerte mientras está abierta
    expect(await page.evaluate(() => document.getElementById('main').inert)).toBe(true);
    await page.keyboard.press('Escape');
    await expect(page.locator('#settings')).toBeHidden();
    await expect(page.locator('#settingsBtn')).toBeFocused();
    expect(await page.evaluate(() => document.getElementById('main').inert)).toBe(false);
  });

  test('Tab no se sale de la hoja', async ({ page, app }) => {
    await app.open();
    await page.click('#settingsBtn');
    for (let i = 0; i < 12; i++) {
      await page.keyboard.press('Tab');
      expect(await page.evaluate(() => !!document.activeElement.closest('#settings'))).toBe(true);
    }
  });

  test('el fondo oscuro también la cierra', async ({ page, app }) => {
    await app.open();
    await page.click('#settingsBtn');
    await page.mouse.click(10, 10);
    await expect(page.locator('#settings')).toBeHidden();
  });
});

test.describe('tarjeta de batería', () => {
  test('"Listo" la resume en una línea y se recuerda', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '7,5');
    await page.click('#batDone');
    await expect(page.locator('#batFull')).toBeHidden();
    await expect(page.locator('#batSumVal')).toHaveText('7,5 kWh');
    await expect(page.locator('#batEdit')).toBeFocused();
    await expect(page.locator('#batEdit')).toHaveAttribute('aria-expanded', 'false');
    await page.reload();
    await expect(page.locator('#batFull')).toBeHidden();
    await expect(page.locator('#batSumVal')).toHaveText('7,5 kWh');
    await page.click('#batEdit');
    await expect(page.locator('#batFull')).toBeVisible();
    await expect(page.locator('#cap')).toBeFocused();
  });

  test('con un tamaño inválido no se cierra', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '');
    await page.click('#batDone');
    await expect(page.locator('#batFull')).toBeVisible();
    await expect(page.locator('#cap')).toBeFocused();
  });

  test('en modo V y Ah resume los kWh calculados', async ({ page, app }) => {
    await app.open();
    await page.click('#modeAh');
    await page.click('#batDone');
    await expect(page.locator('#batSumVal')).toHaveText('10,24 kWh');
  });
});

test.describe('respuesta fija abajo', () => {
  test('en el teléfono se ve mientras la respuesta queda abajo', async ({ page, app }) => {
    await page.setViewportSize({ width: 375, height: 700 });
    await app.open();
    await page.fill('#n-now', '20:00');
    await page.evaluate(() => scrollTo(0, 0));
    const bar = page.locator('#answer');
    await expect(bar).toBeVisible();
    await expect(page.locator('#answerText')).toHaveText('Dura hasta las 6:21 a. m.');
    await expect(page.locator('#answerTag')).toHaveText('No llegas');
    // no recibe toques: no tapa los campos
    expect(await bar.evaluate(e => getComputedStyle(e).pointerEvents)).toBe('none');
    await page.locator('#n-results').scrollIntoViewIfNeeded();
    await expect(bar).toBeHidden();
  });

  test('en la vista de carga muestra la hora de llegada y el tiempo', async ({ page, app }) => {
    await page.setViewportSize({ width: 375, height: 700 });
    await app.open();
    await page.click('#tab-carga');
    await page.fill('#c-now', '04:35');
    await page.evaluate(() => scrollTo(0, 0));
    await expect(page.locator('#answerText')).toHaveText('Al 100% a las 7:47 a. m.');
    await expect(page.locator('#answerTag')).toHaveText('3 h 12 min');
  });

  test('en escritorio no hace falta', async ({ page, app }) => {
    await page.setViewportSize({ width: 1280, height: 700 });
    await app.open();
    await expect(page.locator('#answer')).toBeHidden();
  });
});

test('"Probar con N W" aplica el consumo que sí alcanza', async ({ page, app }) => {
  await app.open();
  await page.fill('#n-now', '20:00');
  await expect(page.locator('#n-verdict')).toContainText('No llegas al amanecer.');
  await expect(page.locator('#n-try')).toHaveText('Probar con 560 W');
  await page.click('#n-try');
  await expect(page.locator('#n-watts')).toHaveValue('560');
  await expect(page.locator('#n-verdict')).toContainText('Llegas al amanecer.');
  await expect(page.locator('#n-try')).toBeHidden();
  await expect(page.locator('#n-verdict')).toBeFocused();
});

test('el veredicto se distingue por ícono y fondo, no solo por color', async ({ page, app }) => {
  await app.open();
  await page.fill('#n-now', '04:35');
  await expect(page.locator('#n-verdict svg')).toHaveCount(1);
  const ok = await page.locator('#n-verdict svg').innerHTML();
  await page.fill('#n-now', '20:00');
  await expect(page.locator('#n-verdict')).toHaveClass(/short/);
  expect(await page.locator('#n-verdict svg').innerHTML()).not.toBe(ok);
});

test('"Ahora" vuelve a poner la hora actual', async ({ page, app }) => {
  await app.open();
  await page.fill('#n-now', '01:00');
  await page.click('[data-now="n-now"]');
  const now = await page.evaluate(() => { const d = new Date(); return String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0'); });
  await expect(page.locator('#n-now')).toHaveValue(now);
  await page.fill('#n-now', '16:05');
  await expect(page.locator('#n-now-fmt')).toHaveText('4:05 p. m.');
});

test('la duración es la cifra protagonista', async ({ page, app }) => {
  await app.open();
  const f1 = await page.locator('#n-f1').boundingBox(), f2 = await page.locator('#n-f2').boundingBox();
  expect(f2.y).toBeLessThan(f1.y);
  const size = id => page.locator(id).evaluate(e => parseFloat(getComputedStyle(e).fontSize));
  expect(await size('#n-f2')).toBeGreaterThan((await size('#n-f1')) * 1.3);
  await page.click('#tab-carga');
  expect(await size('#c-f1')).toBeGreaterThan((await size('#c-f2')) * 1.3);
});

test('los bordes de los campos tienen contraste de 3:1', async ({ page, app }) => {
  await app.open();
  expect(await page.locator('#n-watts').evaluate(e => getComputedStyle(e).borderTopColor)).toBe('rgb(124, 138, 155)');
});
