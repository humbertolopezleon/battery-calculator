// Casos encontrados en las rondas de QA.
const { test, expect, type } = require('./fixtures');

test.describe('QA ronda 1', () => {
  test.use({ locale: 'es-ES' });

  test('porciento por debajo de la reserva: el paso a paso no hace una resta falsa', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '3');
    const pasos = page.locator('#n-steps');
    await expect(pasos).toContainText('3% no pasa de la reserva del 6%: queda 0% útil');
    await expect(pasos).not.toContainText('3% − 6%');
    await expect(page.locator('#n-headline')).toContainText('no queda energía para usar');
  });

  test('paso a paso de carga larga: horas que suman, y los días entre paréntesis', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#cap', '100');
    await type(page, '#c-watts', '1000');
    const pasos = page.locator('#c-steps');
    await expect(pasos).toContainText('De 30% a 90%: 60 kWh ÷ 1 kW = 60 h');
    await expect(pasos).toContainText('De 90% a 100%, a mitad de potencia: 10 kWh ÷ 0,5 kW = 20 h');
    await expect(pasos).toContainText('Total: 60 h + 20 h = 80 h (unos 3,3 días)');
  });

  test('paso a paso de noche larga: horas y días', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '35');
    await expect(page.locator('#n-steps')).toContainText('6210 Wh ÷ 35 W de consumo = 177 h 26 min (unos 7,4 días)');
  });

  test('cada campo inválido se marca con su aviso', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '1,5,5');
    await expect(page.locator('#cap-msg')).toHaveText('Escribe un número.');
    await expect(page.locator('#cap')).toHaveAttribute('aria-invalid', 'true');
    await type(page, '#cap', '0');
    await expect(page.locator('#cap-msg')).toHaveText('Debe ser mayor que 0.');
    await type(page, '#cap', '10');
    await expect(page.locator('#cap')).not.toHaveAttribute('aria-invalid', 'true');
    await type(page, '#n-pctNum', '120');
    await expect(page.locator('#n-pctNum-msg')).toHaveText('Escribe un número del 0 al 100.');
    await type(page, '#n-watts', '');
    await expect(page.locator('#n-watts-msg')).toHaveText('Escribe un número.');
    await page.click('#tab-carga');
    await type(page, '#c-watts', '0');
    await expect(page.locator('#c-watts-msg')).toHaveText('Debe ser mayor que 0.');
  });

  test('el botón de batería común queda marcado cuando coincide', async ({ page, app }) => {
    await app.open();
    const b = page.locator('[data-kwh="5.12"]');
    await expect(b).toHaveAttribute('aria-pressed', 'false');
    await b.click();
    await expect(b).toHaveAttribute('aria-pressed', 'true');
    await type(page, '#cap', '7');
    await expect(b).toHaveAttribute('aria-pressed', 'false');
    await type(page, '#cap', '5.12');
    await expect(b).toHaveAttribute('aria-pressed', 'true');
  });

  test('carga muy lenta: "sube cada hora" no dice 0%', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#c-watts', '1');
    await expect(page.locator('#c-f3')).toHaveText('< 0,1%');
    await type(page, '#c-watts', '250');
    await expect(page.locator('#c-f3')).toHaveText('≈ 2,5%');
  });
});

test.describe('QA ronda 2 (hallazgos del revisor)', () => {
  test.use({ locale: 'es-ES' });
  const set = (page, id, v) => page.fill('#' + id, v);

  test('"la 1:00", no "las 1:00"', async ({ page, app }) => {
    await app.open();
    await set(page, 'n-now', '00:00');
    await type(page, '#n-pctNum', '16');
    await type(page, '#n-watts', '900');
    await expect(page.locator('#n-headline')).toHaveText('Con 900 W de consumo, la batería dura hasta cerca de la 1:00 a. m.');
    await set(page, 'n-sunrise', '01:30');
    await type(page, '#n-watts', '100');
    await expect(page.locator('#n-verdict')).toContainText('a la 1:30');
    await set(page, 'n-sunrise', '07:00');
    await expect(page.locator('#n-verdict')).toContainText('a las 7:00');
  });

  test('el paso a paso usa "h min", sin "1 horas"', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '16');
    await type(page, '#n-watts', '900');
    await expect(page.locator('#n-steps')).toContainText('900 Wh ÷ 900 W de consumo = 1 h');
    await expect(page.locator('#n-steps')).not.toContainText('horas');
    await page.click('#tab-carga');
    await type(page, '#c-pctNum', '50');
    await type(page, '#c-tgtNum', '75');
    await expect(page.locator('#c-steps')).toContainText('2,5 kWh ÷ 2,5 kW de carga = 1 h');
  });

  test('si falta casi nada, no se contradice: llega al amanecer', async ({ page, app }) => {
    await app.open();
    await set(page, 'n-now', '21:00');
    await set(page, 'n-sunrise', '07:00');
    await type(page, '#n-watts', '621,2');
    await expect(page.locator('#n-verdict')).toContainText('Llegas al amanecer.');
    await expect(page.locator('#n-verdict')).not.toContainText('Faltan');
  });

  test('nunca aconseja "0 W o menos"', async ({ page, app }) => {
    await app.open();
    await set(page, 'n-now', '19:00');
    await type(page, '#cap', '0,5');
    await type(page, '#n-pctNum', '7');
    const v = page.locator('#n-verdict');
    await expect(v).toContainText('No llegas al amanecer.');
    await expect(v).not.toContainText('0 W o menos');
    await expect(v).toContainText('Casi no queda energía para usar.');
    await expect(page.locator('#n-headline')).toHaveText('Queda energía para menos de un minuto.');
  });

  test('consumo muy pequeño no se muestra como 0 W', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '0,04');
    await expect(page.locator('#n-headline')).toContainText('Con 0,04 W de consumo');
    await expect(page.locator('#n-steps')).toContainText('÷ 0,04 W');
  });

  test('sin hora: "cerca de 36 min"', async ({ page, app }) => {
    await app.open();
    await set(page, 'n-now', '');
    await type(page, '#n-pctNum', '8');
    await type(page, '#n-watts', '300');
    await expect(page.locator('#n-headline')).toHaveText('Con 300 W de consumo, la batería dura cerca de 36 min.');
  });

  test('los números se muestran sin separador de miles', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '12000');
    await expect(page.locator('#n-headline')).toContainText('Con 12000 W de consumo');
  });

  test('la ayuda de potencia de carga cambia con el modo', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await expect(page.locator('#chgHint')).toHaveText('Es la potencia de carga desde la red configurada en el inversor.');
    await page.click('#c-modeA');
    await expect(page.locator('#chgHint')).toContainText('50 A en una batería de 51,2 V');
    await expect(page.locator('label[for="c-amps"]')).toHaveText('Amperios de carga (A)');
  });

  test('"No hace falta cargar" no se muestra como error', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#c-pctNum', '100');
    await expect(page.locator('#c-headline')).toContainText('No hace falta cargar.');
    await expect(page.locator('#c-headline .error')).toHaveCount(0);
  });

  test('datos guardados dañados no rompen la pantalla', async ({ page, app }) => {
    await app.open();
    await page.evaluate(() => localStorage.setItem('calc-bateria-v2', JSON.stringify({ mode: 'xx', cMode: 'zz' })));
    await page.reload();
    await expect(page.locator('#cap')).toBeVisible();
    await page.click('#tab-carga');
    await expect(page.locator('#c-watts')).toBeVisible();
  });

  test('cambiar de pestaña no llena el historial', async ({ page, app }) => {
    await app.open();
    const n0 = await page.evaluate(() => history.length);
    await page.click('#tab-carga');
    await page.click('#tab-noche');
    await page.click('#tab-carga');
    expect(await page.evaluate(() => history.length)).toBe(n0);
    expect(await page.evaluate(() => location.hash)).toBe('#carga');
    await page.reload();
    await expect(page.locator('#view-carga')).toBeVisible();
  });

  test('pestañas con teclado: flechas, Inicio y Fin', async ({ page, app }) => {
    await app.open();
    await page.locator('#tab-noche').focus();
    await page.keyboard.press('End');
    await expect(page.locator('#tab-carga')).toBeFocused();
    await expect(page.locator('#view-carga')).toBeVisible();
    await page.keyboard.press('Home');
    await expect(page.locator('#view-noche')).toBeVisible();
    await page.keyboard.press('ArrowRight');
    await expect(page.locator('#view-carga')).toBeVisible();
  });

  test('el consumo de la casa se recuerda', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '850');
    await page.reload();
    await expect(page.locator('#n-watts')).toHaveValue('850');
  });

  test('"Más opciones" viene cerrado y se abre solo si hay algo cambiado', async ({ page, app }) => {
    await app.open({ closed: true });
    await expect(page.locator('#n-loss')).toBeHidden();
    await page.click('#n-more summary');
    await expect(page.locator('#n-loss')).toBeVisible();
    await page.locator('#rsvOn').check();
    await page.reload();
    await expect(page.locator('#rsvOn')).toBeVisible();
    await expect(page.locator('#rsvOn')).toBeChecked();
  });

  test('el aviso de "solo números" se quita al salir del campo', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '600x');
    await expect(page.locator('#n-watts-msg')).toHaveText('Solo se pueden escribir números.');
    await page.locator('#cap').focus();
    await expect(page.locator('#n-watts-msg')).toBeHidden();
  });

  test('el dibujo de la batería no redondea 75,5 a 76', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '75,5');
    await expect(page.locator('#n-label')).toHaveText('75,5%');
  });
});

test.describe('QA ronda 3 (segunda revisión)', () => {
  test.use({ locale: 'es-ES' });

  test('reserva inválida: la pantalla vuelve a mostrar 6%, no un valor a medias', async ({ page, app }) => {
    await app.open();
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '95');
    await expect(page.locator('#view-noche .lead .rv')).toHaveText('6');
    await expect(page.locator('#rsv-msg')).toHaveText('Escribe un número del 0 al 90.');
  });

  test('reserva inválida reabre "Más opciones" para que se vea el campo en rojo', async ({ page, app }) => {
    await app.open();
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '95');
    await page.evaluate(() => { document.getElementById('n-more').open = false; });
    await type(page, '#n-watts', '500');
    await expect(page.locator('#rsv')).toBeVisible();
  });

  test('volver a la app no borra el mensaje del reporte', async ({ page, app }) => {
    await page.addInitScript(() => { window.showSaveFilePicker = undefined; });
    await app.open();
    await Promise.all([page.waitForEvent('download'), page.click('#n-save')]);
    await expect(page.locator('#n-msg')).toContainText('Reporte descargado');
    await page.evaluate(() => {
      document.getElementById('n-now').value = '00:00'; // como si hubiera pasado el tiempo
      document.dispatchEvent(new Event('visibilitychange'));
    });
    await expect(page.locator('#n-now')).not.toHaveValue('00:00'); // la hora se refrescó
    await expect(page.locator('#n-msg')).toContainText('Reporte descargado');
    await type(page, '#n-watts', '700'); // al cambiar un dato sí se limpia
    await expect(page.locator('#n-msg')).toHaveText('');
  });

  test('titular y aviso del amanecer no se contradicen con consumos bajos', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '22:00');
    await page.fill('#n-sunrise', '07:00');
    await type(page, '#cap', '5');
    await type(page, '#n-pctNum', '15,9');
    await type(page, '#n-watts', '50');
    await expect(page.locator('#n-headline')).toContainText('6:55');
    await expect(page.locator('#n-verdict')).toContainText('No llegas al amanecer.');
    await expect(page.locator('#n-verdict')).not.toContainText('unos 0 ');
  });

  test('paso a paso con cifras pequeñas: usa Wh y dos decimales en el porciento', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-pctNum', '6,5');
    await type(page, '#n-watts', '5000');
    await expect(page.locator('#n-steps')).toContainText('6,5% − 6% de reserva = 0,5% útil');
    await expect(page.locator('#n-steps')).toContainText('10 kWh × 0,5% = 50 Wh, y quitando el 10% de pérdidas quedan 45 Wh');
    await expect(page.locator('#n-steps')).toContainText('45 Wh ÷ 5000 W de consumo = 1 min');
    await type(page, '#n-pctNum', '75');
    await page.locator('#rsvOn').check();
    await type(page, '#rsv', '6,55');
    await expect(page.locator('#n-steps')).toContainText('75% − 6,55% de reserva = 68,45% útil');
  });

  test('carga desde 90%: el paso a paso también dice los días', async ({ page, app }) => {
    await app.open();
    await page.click('#tab-carga');
    await type(page, '#c-pctNum', '90');
    await type(page, '#c-watts', '5');
    await expect(page.locator('#c-steps')).toContainText('1000 Wh ÷ 2,5 W = 400 h (unos 17 días)');
  });

  test('los campos no dejan escribir más de 12 caracteres', async ({ page, app }) => {
    const errores = [];
    page.on('pageerror', e => errores.push(e.message));
    await app.open();
    await type(page, '#cap', '9'.repeat(40));
    await expect(page.locator('#cap')).toHaveValue('9'.repeat(12));
    await page.evaluate(() => localStorage.setItem('calc-bateria-v2', JSON.stringify({ cap: '9'.repeat(400) })));
    await page.reload();
    await expect(page.locator('#cap')).toHaveValue('9'.repeat(12));
    expect(errores).toEqual([]);
  });

  test('un campo vacío no se guarda: al recargar vuelve el último valor bueno', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '7,5');
    await type(page, '#cap', '');
    await page.reload();
    await expect(page.locator('#cap')).toHaveValue('7,5');
  });

  test('solo el titular y el aviso se anuncian al lector de pantalla', async ({ page, app }) => {
    await app.open();
    await expect(page.locator('section.results[aria-live]')).toHaveCount(0);
    await expect(page.locator('#n-headline')).toHaveAttribute('aria-live', 'polite');
    await expect(page.locator('#n-verdict')).toHaveAttribute('aria-live', 'polite');
  });
});

test.describe('QA ronda 4 (verificación final)', () => {
  test.use({ locale: 'es-ES' });

  test('si alcanza justo, lo dice así y no "sobrarían 0"', async ({ page, app }) => {
    await app.open();
    await page.fill('#n-now', '21:00');
    await page.fill('#n-sunrise', '07:00');
    for (const w of ['621', '621,2']) {
      await type(page, '#n-watts', w);
      const v = page.locator('#n-verdict');
      await expect(v).toHaveText('Llegas al amanecer. La energía alcanza justo hasta las 7:00\u00a0a.\u00a0m.');
    }
  });

  test('cada línea del paso a paso parte del número de la línea anterior', async ({ page, app }) => {
    await app.open();
    // caso realista: 5 kWh, 15,9 %, 50 W
    await type(page, '#cap', '5');
    await type(page, '#n-pctNum', '15,9');
    await type(page, '#n-watts', '50');
    const p = page.locator('#n-steps');
    await expect(p).toContainText('5 kWh × 9,9% = 495 Wh, y quitando el 10% de pérdidas quedan 446 Wh');
    await expect(p).toContainText('446 Wh ÷ 50 W de consumo = 8 h 55 min');
    // valores por defecto
    await type(page, '#cap', '10');
    await type(page, '#n-pctNum', '75');
    await type(page, '#n-watts', '600');
    await expect(p).toContainText('10 kWh × 69% = 6900 Wh, y quitando el 10% de pérdidas quedan 6210 Wh');
    await expect(p).toContainText('6210 Wh ÷ 600 W de consumo = 10 h 21 min');
    // más de 1 kW: todo en kWh y kW
    await type(page, '#n-pctNum', '75,5');
    await type(page, '#n-watts', '1500');
    await expect(p).toContainText('quedan 6,255 kWh');
    await expect(p).toContainText('6,255 kWh ÷ 1,5 kW de consumo = 4 h 10 min');
    // cifras diminutas
    await type(page, '#cap', '0,5');
    await type(page, '#n-pctNum', '7');
    await type(page, '#n-watts', '3');
    await expect(p).toContainText('quedan 4,5 Wh');
    await expect(p).toContainText('4,5 Wh ÷ 3 W de consumo = 1 h 30 min');
    await expect(page.locator('#n-f1')).toHaveText('0,0045');
  });

  test('un valor fuera de rango no se guarda', async ({ page, app }) => {
    await app.open();
    await type(page, '#cap', '8');
    await type(page, '#cap', '0');
    await page.click('#tab-carga');
    await type(page, '#c-tgtNum', '80');
    await page.fill('#c-tgtNum', '150'); // de una vez (al teclear pasaría por "15", que sí es válido)
    await expect(page.locator('#c-tgtNum-msg')).toHaveText('Escribe un número del 0 al 100.');
    await page.reload();
    await expect(page.locator('#cap')).toHaveValue('8');
    await expect(page.locator('#c-tgtNum')).toHaveValue('80');
  });

  test('cifras enormes no se salen de su tarjeta', async ({ page, app }) => {
    await page.setViewportSize({ width: 320, height: 800 });
    await app.open();
    await page.click('#textBtn');
    await type(page, '#cap', '999999999999');
    await type(page, '#n-watts', '1');
    for (const tab of ['noche', 'carga']) {
      await page.click('#tab-' + tab);
      if (tab === 'carga') await type(page, '#c-watts', '1');
      const fuera = await page.evaluate(() => [...document.querySelectorAll('.fig b')].filter(b => {
        const r = b.getBoundingClientRect(), c = b.closest('.fig').getBoundingClientRect();
        return r.width && (r.right > c.right + 0.5 || r.left < c.left - 0.5);
      }).length);
      expect(fuera).toBe(0);
    }
  });

  test('consumo diminuto no sale como "0 W"', async ({ page, app }) => {
    await app.open();
    await type(page, '#n-watts', '0,001');
    await expect(page.locator('#n-headline')).toContainText('Con 0,001 W de consumo');
  });
});
