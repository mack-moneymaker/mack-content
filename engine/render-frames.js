const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const outputDir = process.argv[2] || path.join(__dirname, '..', 'output', '001');
const htmlPath = process.argv[3] || path.join(__dirname, 'generate-frames.html');
const slideCount = parseInt(process.argv[4] || '7');

(async () => {
  fs.mkdirSync(outputDir, { recursive: true });
  
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1080, height: 1920 },
    deviceScaleFactor: 2
  });
  const page = await context.newPage();
  
  await page.goto(`file://${path.resolve(htmlPath)}`);
  await page.waitForTimeout(2000); // Let fonts load
  
  for (let i = 1; i <= slideCount; i++) {
    const slide = page.locator(`#slide-${i}`);
    await slide.screenshot({ 
      path: path.join(outputDir, `frame-${String(i).padStart(3, '0')}.png`),
      type: 'png'
    });
    console.log(`Rendered frame ${i}/${slideCount}`);
  }
  
  await browser.close();
  console.log(`All frames saved to ${outputDir}`);
})();
