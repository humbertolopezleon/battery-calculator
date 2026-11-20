// Coma decimal, datos inválidos, reserva, horas límite, más de 24 h, textos.
const { test, expect, readNum, readMinutes, type } = require('./fixtures');

test.describe('coma decimal con el teclado (español)', () => {
  test.use({ locale: 'es-ES' });

  test('10,5 kWh se lee como 10,5 y no como 105', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '10,5');
    // 10,5 × (75 − 6)% × 0,9
    expect(readNum(await page.textContent('#n-f1'), 'es')).toBeCloseTo(10.5 * 0.69 * 0.9, 2);
    await expect(page.locator('#cap-msg')).toBeHidden();
  });

  test('10.5 con punto también vale', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '10.5');
    expect(readNum(await page.textContent('#n-f1'), 'es')).toBeCloseTo(10.5 * 0.69 * 0.9, 2);
  });

  test('"1.200" W es dudoso: se muestra cómo se entendió', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '1.200');
    await expect(page.locator('#n-watts-msg')).toHaveText('Se entendió: 1,2 W. Si querías 1200 W, escríbelo sin punto.');
    await expect(page.locator('#n-headline')).toContainText('1,2 W');
  });

  test('"1.200,5" usa el punto como miles y lo muestra', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '1.200,5');
    await expect(page.locator('#n-watts-msg')).toHaveText('Se entendió: 1200,5 W.');
  });

  test('todos los campos de números son de texto con teclado decimal', async ({ page, app }) => {
    await app.open();
    expect(await page.locator('input[type=number]').count()).toBe(0);
    const ids = ['cap', 'volt', 'ah', 'n-pctNum', 'n-watts', 'rsv', 'c-pctNum', 'c-tgtNum', 'c-watts', 'c-amps', 'c-volt'];
    for (const id of ids) {
      await expect(page.locator('#' + id)).toHaveAttribute('type', 'text');
      await expect(page.locator('#' + id)).toHaveAttribute('inputmode', 'decimal');
    }
  });

  test('voltios y Ah con coma', async ({ page, app }) => {
    await app.open();
    await page.click('#modeAh');
    await type(page, '#volt', '51,2');
    await type(page, '#ah', '100');
    await expect(page.locator('#ahResult')).toHaveText('Tu batería es de unos 5,12 kWh.');
  });

  test('carga en amperios con coma', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await page.click('#c-modeA');
    await type(page, '#c-amps', '25,5');
    await type(page, '#c-volt', '48');
    await expect(page.locator('#c-aResult')).toHaveText('Equivale a unos 1224 W de carga.');
  });
});

test.describe('datos inválidos', () => {
  test.use({ locale: 'es-ES' });
  for (const [id, val] of [['cap', ''], ['cap', '0'], ['cap', ','], ['n-pctNum', '120'], ['n-pctNum', '1.2.3'], ['n-watts', '']]) {
    test(`${id} = "${val}" no calcula`, async ({ page, app }) => {
      await app.open();
      await type(page, '#' + id, val);
      await expect(page.locator('#n-headline .error')).toBeVisible();
      await expect(page.locator('#n-f1')).toHaveText('–');
      await expect(page.locator('#n-save')).toBeDisabled();
    });
  }
  test('carga sin potencia', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#c-watts', '0');
    await expect(page.locator('#c-headline')).toHaveText('Pon la potencia de carga: debe ser mayor que 0.');
    await expect(page.locator('#c-save')).toBeDisabled();
  });
});

test.describe('los campos de números no admiten letras', () => {
  test.use({ locale: 'es-ES' });
  const ids = ['cap', 'volt', 'ah', 'n-pctNum', 'n-watts', 'rsv', 'c-pctNum', 'c-tgtNum', 'c-watts', 'c-amps', 'c-volt'];

  test('al escribir solo quedan números, coma y punto', async ({ page, app }) => {
    await app.open();
    await page.click('#modeAh');          // muestra volt y ah
    await page.locator('#rsvOn').check(); // muestra rsv
    for (const id of ids) {
      if (id === 'cap') { await page.click('#modeKwh'); }
      if (id === 'volt') { await page.click('#modeAh'); }
      if (id.startsWith('c-')) { await page.click('#tab-carga'); if (id === 'c-amps') await page.click('#c-modeA'); }
      await type(page, '#' + id, 'a1b2-,e5 x');
      await expect(page.locator('#' + id), id).toHaveValue('12,5');
      await expect(page.locator('#' + id + '-msg'), id).toContainText('Solo se pueden escribir números.');
    }
  });

  test('el aviso se quita al seguir escribiendo bien', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '6x');
    await expect(page.locator('#n-watts')).toHaveValue('6');
    await expect(page.locator('#n-watts-msg')).toHaveText('Solo se pueden escribir números.');
    await page.locator('#n-watts').pressSequentially('00');
    await expect(page.locator('#n-watts')).toHaveValue('600');
    await expect(page.locator('#n-watts-msg')).toBeHidden();
  });

  test('pegar "1 500 W" deja 1500', async ({ page, app }) => {
    await app.open();
    await page.locator('#n-watts').fill('1 500 W');
    await expect(page.locator('#n-watts')).toHaveValue('1500');
    await expect(page.locator('#n-headline')).toContainText('1500 W');
  });

  test('solo letras deja el campo vacío y no calcula', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', 'abc');
    await expect(page.locator('#cap')).toHaveValue('');
    await expect(page.locator('#n-headline .error')).toBeVisible();
    await expect(page.locator('#n-save')).toBeDisabled();
  });

  test('no se puede escribir un signo menos', async ({ page, app }) => {
    await app.open();
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '-3');
    await expect(page.locator('#rsv')).toHaveValue('3');
  });

  test('datos viejos guardados con letras se limpian al abrir', async ({ page, app }) => {
    await app.open();
    await page.evaluate(() => localStorage.setItem('calc-bateria-v2', JSON.stringify({ cap: '12kWh', 'c-watts': 'w2000' })));
    await page.reload();
    await expect(page.locator('#cap')).toHaveValue('12');
    await expect(page.locator('#c-watts')).toHaveValue('2000');
  });
});

test.describe('reserva', () => {
  test.use({ locale: 'es-ES' });
  for (const val of ['', '91', '150', '90,5']) {
    test(`reserva "${val}" muestra aviso y no calcula`, async ({ page, app }) => {
      await app.open();
      await page.locator('#rsvOn').check();
      await type(page, '#rsv', val);
      await expect(page.locator('#rsv-msg')).toHaveText('Escribe un número del 0 al 90.');
      await expect(page.locator('#rsv')).toHaveAttribute('aria-invalid', 'true');
      await expect(page.locator('#n-headline .error')).toHaveText('Revisa la reserva: debe ser un número del 0 al 90.');
      await expect(page.locator('#n-f1')).toHaveText('–');
      await expect(page.locator('#n-save')).toBeDisabled();
    });
  }
  test('reserva 90 y 0 son válidas; al corregir vuelve a calcular', async ({ page, app }) => {
    await app.open();
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '95');
    await expect(page.locator('#n-f1')).toHaveText('–');
    await type(page, '#rsv', '0');
    await expect(page.locator('#rsv')).not.toHaveAttribute('aria-invalid', 'true');
    expect(readNum(await page.textContent('#n-f1'), 'es')).toBeCloseTo(10 * 0.75 * 0.9, 2);
    await type(page, '#n-pctNum', '100');
    await type(page, '#rsv', '90');
    expect(readNum(await page.textContent('#n-f1'), 'es')).toBeCloseTo(10 * 0.1 * 0.9, 2);
  });
  test('reserva 12,5%: el paso a paso muestra 87,5% útil', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '100');
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '12,5');
    await expect(page.locator('#n-steps')).toContainText('100% − 12,5% de reserva = 87,5% útil');
  });
});

test.describe('horas límite y duraciones largas', () => {
  test.use({ locale: 'es-ES' });

  test('hora actual igual a la hora del sol: sin aviso del amanecer', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '07:00');
    await page.fill('#n-sunrise', '07:00');
    await expect(page.locator('#n-verdict')).toBeHidden();
    await expect(page.locator('#n-headline')).not.toContainText('No llegas');
  });

  test('un minuto antes del sol sí hay aviso', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '06:59');
    await page.fill('#n-sunrise', '07:00');
    await expect(page.locator('#n-verdict')).toContainText('Llegas al amanecer.');
  });

  test('cruce de medianoche 23:59 → 00:00', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '23:59');
    await page.fill('#n-sunrise', '00:00');
    await expect(page.locator('#n-verdict')).toContainText('Llegas al amanecer.');
  });

  test('no hay doble punto tras "a. m."', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '22:00');
    await page.fill('#n-sunrise', '07:00');
    await type(page, '#n-watts', '300');
    const t = await page.textContent('#n-verdict');
    expect(t).toMatch(/a\. m\.$/);
    expect(t).not.toContain('..');
    await type(page, '#n-watts', '3000');
    const t2 = await page.textContent('#n-verdict');
    expect(t2).toContain('No llegas al amanecer.');
    expect(t2).not.toContain('..');
    expect(await page.textContent('#n-headline')).not.toContain('..');
  });

  test('más de 24 h se muestra en días y sin hora del día', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '100');
    await type(page, '#cap', '1000');
    await type(page, '#n-watts', '600');
    // 1000 × 0,94 × 0,9 / 0,6 = 1410 h ≈ 59 días
    await expect(page.locator('#n-f2')).toHaveText('unos 59 días');
    await expect(page.locator('#n-headline')).toHaveText('Con 600 W de consumo, la batería dura unos 59 días.');
    await expect(page.locator('#n-headline')).not.toContainText('m.');
  });

  test('carga de más de 24 h en días', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#cap', '100');
    await type(page, '#c-watts', '1000');
    await expect(page.locator('#c-f1')).toHaveText('unos 3,3 días');
    await expect(page.locator('#c-headline')).toHaveText('Cargando a 1000 W, la batería tarda unos 3,3 días en llegar al 100%.');
  });

  test('justo menos de 24 h sigue en horas', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '100');
    await page.locator('#n-loss').uncheck();
    // 10 × 0,94 = 9,4 kWh; a 400 W = 23,5 h
    await type(page, '#n-watts', '400');
    await expect(page.locator('#n-f2')).toHaveText('23 h 30 min');
  });
});

test.describe('textos y paso a paso', () => {
  test('35 W usa W y Wh, no 0,04 kW', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '35');
    const pasos = await page.textContent('#n-steps');
    expect(pasos).not.toMatch(/0[,.]04 kW/);
    expect(pasos).toMatch(/Wh ÷ 35 W/);
  });

  test.describe('en español', () => {
    test.use({ locale: 'es-ES' });
    test('etiqueta "útil por cada 1%"', async ({ page, app }) => {
      await app.open();
      await expect(page.locator('#view-noche .fig small').nth(2)).toHaveText('útil por cada 1%');
    });
    test('carga: tramo 90–100% en el paso a paso', async ({ page, app }) => {
      await app.open();
      await page.click('#tab-carga');
      const pasos = page.locator('#c-steps');
      await expect(pasos).toContainText('De 30% a 90%: 6 kWh ÷ 2,5 kW = 2 h 24 min');
      await expect(pasos).toContainText('De 90% a 100%, a mitad de potencia: 1 kWh ÷ 1,25 kW = 48 min');
      await expect(pasos).toContainText('Total: 2 h 24 min + 48 min = 3 h 12 min');
      await expect(page.locator('#c-f1')).toHaveText('3 h 12 min');
    });
    test('botones de baterías comunes', async ({ page, app }) => {
      await app.open();
      const btns = page.locator('[data-kwh]');
      await expect(btns).toHaveText(['5,12 kWh', '10,24 kWh', '15 kWh']);
      await btns.nth(1).click();
      await expect(page.locator('#cap')).toHaveValue('10,24');
      expect(readNum(await page.textContent('#n-f1'), 'es')).toBeCloseTo(10.24 * 0.69 * 0.9, 2);
      for (let i = 0; i < 3; i++) {
        const box = await btns.nth(i).boundingBox();
        expect(box.height).toBeGreaterThanOrEqual(44);
      }
    });
    test('avisos de valores raros sin bloquear', async ({ page, app }) => {
      await app.open();
      const aviso = '¿Seguro? Es más de lo normal en una casa.';
      await type(page, '#n-watts', '12000');
      await expect(page.locator('#n-watts-msg')).toHaveText(aviso);
      await expect(page.locator('#n-save')).toBeEnabled();
      await type(page, '#n-watts', '10000');
      await expect(page.locator('#n-watts-msg')).toBeHidden();
      await type(page, '#cap', '150');
      await expect(page.locator('#cap-msg')).toHaveText(aviso);
      await page.click('#tab-carga');
      await type(page, '#c-watts', '11000');
      await expect(page.locator('#c-watts-msg')).toHaveText(aviso);
      await expect(page.locator('#c-save')).toBeEnabled();
    });
    test('versión y aviso sin internet', async ({ page, app }) => {
      await app.open();
      await expect(page.locator('#appVer')).toHaveText('Versión 1.4 · noviembre 2026');
      await expect(page.locator('.offline')).toHaveText('Funciona sin internet.');
    });
  });

  test.describe('en inglés', () => {
    test.use({ locale: 'en-US' });
    test('etiquetas, versión y botones', async ({ page, app }) => {
      await app.open();
      await expect(page.locator('#view-noche .fig small').nth(2)).toHaveText('usable per 1%');
      await expect(page.locator('#appVer')).toHaveText('Version 1.4 · November 2026');
      await expect(page.locator('.offline')).toHaveText('Works without internet.');
      await expect(page.locator('[data-kwh]')).toHaveText(['5.12 kWh', '10.24 kWh', '15 kWh']);
      await type(page, '#n-watts', '1,200');
      await expect(page.locator('#n-watts-msg')).toHaveText('Read as: 1.2 W. If you meant 1200 W, type it without the comma.');
    });
  });
});
