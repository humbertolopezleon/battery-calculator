// Pruebas del archivo único: node build.js && npx playwright test
const { defineConfig } = require('@playwright/test');
const path = require('path');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 30000,
  fullyParallel: true,
  reporter: [['list']],
  use: { trace: 'off', viewport: { width: 414, height: 900 } },
  projects: [
    // El archivo único se abre como archivo local, igual que en el teléfono
    { name: 'archivo-unico', use: { appUrl: 'file://' + path.join(__dirname, 'Battery-Calculator.html') } },
  ],
});
