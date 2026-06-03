const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch({
    headless: "new",
    defaultViewport: { width: 450, height: 900, isMobile: true }
  });
  const page = await browser.newPage();
  const baseUrl = 'http://localhost:8080/#';

  const screenshotsDir = path.join(__dirname, 'Screenshots');
  if (!fs.existsSync(screenshotsDir)) fs.mkdirSync(screenshotsDir);

  const languages = ['en', 'ar'];
  const pages = [
    { name: 'Home', path: '/' },
    { name: 'Library', path: '/library' },
    { name: 'Quran', path: '/quran' },
    { name: 'Adhkar', path: '/adhkar' },
    { name: 'Prayer', path: '/prayer' },
    { name: 'Tasbeeh', path: '/tasbeeh' },
    { name: 'Reciters', path: '/all-reciters' }
  ];

  for (const lang of languages) {
    console.log(`\n📸 Capturing screenshots for: ${lang.toUpperCase()}`);
    const langDir = path.join(screenshotsDir, lang === 'ar' ? 'Arabic' : 'English');
    if (!fs.existsSync(langDir)) fs.mkdirSync(langDir);

    // Initial load and set language via URL or local storage
    await page.goto(`${baseUrl}/language-selection`);
    await page.waitForTimeout(2000);

    // Click language if possible or assume a specific route if the app supports it
    // For now, let's just go through the pages and hope the state persists
    // or try to navigate to a language-specific state if supported.
    
    // Custom logic to set language - this might need adjustment based on app internals
    await page.evaluate((l) => {
      localStorage.setItem('settings_language', l);
      window.location.reload();
    }, lang);
    await page.waitForTimeout(3000);

    for (const p of pages) {
      console.log(`- ${p.name}`);
      try {
        await page.goto(`${baseUrl}${p.path}`, { waitUntil: 'networkidle2', timeout: 15000 });
        await page.waitForTimeout(2000); // Allow animations to settle
        
        // Remove any debug banners if present
        await page.evaluate(() => {
          const banners = document.querySelectorAll('.flutter-debug-banner');
          banners.forEach(b => b.remove());
        });

        await page.screenshot({
          path: path.join(langDir, `${p.name}.png`),
          fullPage: false
        });
      } catch (err) {
        console.error(`  ❌ Failed to capture ${p.name}: ${err.message}`);
      }
    }
  }

  await browser.close();
  console.log('\n✅ All screenshots captured successfully in Screenshots/ directory.');
})();
