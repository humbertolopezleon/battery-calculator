// Accesibilidad con axe-core en tema claro y oscuro: cero fallas.
const { test, expect, type } = require('./fixtures');
const AXE = require.resolve('axe-core/axe.min.js');

async function axe(page) {
  await page.addScriptTag({ path: AXE });
  const res = await page.evaluate(() => window.axe.run(document, { resultTypes: ['violations'] }));
  return res.violations.map(v => `${v.id}: ${v.nodes.map(n => n.target.join(' ')).join(', ')}`);
}

const modos = [
  { name: 'claro (auto)', scheme: 'light', theme: null },
  { name: 'oscuro (auto)', scheme: 'dark', theme: null },
  { name: 'oscuro (botón)', scheme: 'light', theme: 'dark' },
  { name: 'claro (botón)', scheme: 'dark', theme: 'light' },
];

for (const m of modos) {
  for (const lang of ['es', 'en']) {
    test(`${m.name} ${lang}`, async ({ page, app }) => {
      await page.emulateMedia({ colorScheme: m.scheme });
      await app.open();
      await page.click(`#langGroup [data-lang="${lang}"]`);
      if (m.theme) await page.click(`#themeGroup [data-theme-set="${m.theme}"]`);
      // Noche, con aviso de "se entendió", aviso raro y error de reserva visibles
      await type(page, '#n-watts', '1.200');
      await type(page, '#cap', '150');
      await page.locator('#rsvOn').check();
      await type(page, '#rsv', '95');
      expect(await axe(page)).toEqual([]);
      await type(page, '#rsv', '6');
      expect(await axe(page)).toEqual([]);
      // Carga
      await page.click('#tab-carga');
      await type(page, '#c-watts', '12000');
      expect(await axe(page)).toEqual([]);
      // Texto grande
      await page.click('#textBtn');
      expect(await axe(page)).toEqual([]);
    });
  }
}
