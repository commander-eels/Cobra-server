// Renders ersatztv-live-tv-guide.html to PDF. Usage: node docs/ersatztv/build.mjs [out.pdf]
import { createRequire } from 'node:module';
const { chromium } = createRequire(import.meta.url)('playwright');
import { fileURLToPath } from 'node:url';
import path from 'node:path';
const here = path.dirname(fileURLToPath(import.meta.url));
const out = process.argv[2] || path.join(here, 'cobra-ersatztv-live-tv-guide.pdf');
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('file://' + path.join(here, 'ersatztv-live-tv-guide.html'));
await page.pdf({ path: out, format: 'Letter', printBackground: true, preferCSSPageSize: true });
await browser.close();
console.log('wrote', out);
