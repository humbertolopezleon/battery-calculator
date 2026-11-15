// Pruebas de la versión instalable: npx playwright test
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 30000,
  fullyParallel: true,
  reporter: [['list']],
  use: { trace: 'off', viewport: { width: 414, height: 900 } },
  projects: [
    // Servida por http, como en un hosting (el service worker lo necesita)
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
