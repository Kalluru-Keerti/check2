// Headless browser smoke test: loads every route, captures console/network errors,
// screenshots each page, and runs the full "analyse a sample resume" flow.
// Usage: URL=http://localhost:5173 CHROME="/path/to/chrome" node e2e.js
const puppeteer = require('puppeteer-core');
const OUT = process.env.OUT || __dirname;
const URL = process.env.URL || 'http://localhost:5173';
const CHROME = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const browser = await puppeteer.launch({ executablePath: CHROME, headless: 'new', args: ['--no-sandbox'], defaultViewport: { width: 1920, height: 1080 } });
  const page = await browser.newPage();
  const problems = [];
  page.on('console', (m) => { if (['error', 'warning'].includes(m.type())) problems.push(`[console.${m.type()}] ${m.text()}`); });
  page.on('pageerror', (e) => problems.push(`[pageerror] ${e.message}`));
  page.on('requestfailed', (r) => problems.push(`[requestfailed] ${r.url()} ${r.failure()?.errorText}`));
  page.on('response', (r) => { if (r.status() >= 400) problems.push(`[http ${r.status()}] ${r.url()}`); });

  const route = async (path, name) => {
    await page.goto(URL + path, { waitUntil: 'networkidle0' });
    await sleep(600);
    await page.screenshot({ path: `${OUT}/${name}.png` });
    const info = await page.evaluate(() => ({
      font: getComputedStyle(document.body).fontFamily.slice(0, 40),
      bg: getComputedStyle(document.body).backgroundColor,
      h1: document.querySelector('h1')?.textContent,
      banner: !!document.querySelector('.demo-banner'),
    }));
    console.log(name.padEnd(14), JSON.stringify(info));
  };
  await route('/', '1-analyzer');
  await route('/roles', '2-roles');
  await route('/architecture', '3-architecture');

  await page.goto(URL + '/', { waitUntil: 'networkidle0' });
  await page.click('#sample-toggle-button, #sample');
  await page.waitForSelector('[role="option"]');
  await page.click('[role="option"]');
  await sleep(300);
  console.log('role field:', (await page.$eval('#role', (el) => el.textContent)).slice(0, 70));
  await page.evaluate(() => [...document.querySelectorAll('button')].find((b) => b.textContent.trim().startsWith('Analyse')).click());
  await page.waitForSelector('.result-score__value', { timeout: 15000 });
  await sleep(500);
  console.log('result:', await page.$eval('.result-score', (el) => el.textContent));
  await page.screenshot({ path: `${OUT}/4-result.png` });

  await page.click('#category');
  await page.waitForSelector('[role="option"]');
  console.log('categories:', JSON.stringify(await page.$$eval('[role="option"]', (o) => o.map((x) => x.textContent))));
  await browser.close();
  console.log('\nPROBLEMS:', problems.length ? '\n' + problems.join('\n') : 'none');
  process.exit(problems.length ? 1 : 0);
})().catch((e) => { console.error('E2E FAILED', e); process.exit(1); });
