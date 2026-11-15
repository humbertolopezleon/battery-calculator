// Pruebas: npx playwright test   (antes: node build.js)
const { defineConfig } = require('@playwright/test');
const path = require('path');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 30000,
  fullyParallel: true,
  reporter: [['list']],
  use: { trace: 'off', viewport: { width: 414, height: 900 } },
  projects: [
    // Archivo único (el que se manda por WhatsApp), abierto como archivo local
    { name: 'archivo-unico', use: { appUrl: 'file://' + path.join(__dirname, 'dist', 'Battery-Calculator.html') } },
    // Versión instalable, servida por http
    { name: 'instalable', use: { appUrl: 'http://127.0.0.1:4173/index.html' } },
  ],
  webServer: {
    command: 'python3 -m http.server 4173 --bind 127.0.0.1',
    url: 'http://127.0.0.1:4173/index.html',
    reuseExistingServer: true,
    cwd: __dirname,
    stdout: 'ignore',
    stderr: 'ignore',
  },
});
