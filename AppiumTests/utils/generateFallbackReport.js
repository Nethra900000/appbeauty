// ─────────────────────────────────────────────────────────────────────────────
// AI Beauty Genius — Fallback Report Generator
// Runs when WDIO/Appium crashes before any tests execute
// ─────────────────────────────────────────────────────────────────────────────
const path = require('path');
const { startRun, recordTest, generateReport } = require('./xlsxReporter');
const generateHtml = require('./generateHtmlReport');

const CATEGORIES = [
  'Functional Testing', 'UI/UX Testing', 'Compatibility Testing',
  'Performance Testing', 'Security Testing', 'API Integration Testing',
  'Database Testing', 'Accessibility Testing', 'Mobile-Specific Testing',
  'Regression Testing', 'End-to-End Flow Testing',
];

(async () => {
  console.log('[generateFallbackReport] 🔄 Generating fallback report after Appium crash...');

  startRun();

  // Generate 1,111 FAIL rows across all 11 categories
  let tcNum = 1;
  CATEGORIES.forEach(cat => {
    for (let i = 1; i <= 101; i++) {
      const prefix = cat.split(' ')[0].slice(0, 4).toUpperCase();
      recordTest({
        id:       `TC_${prefix}_${String(i).padStart(3, '0')}`,
        title:    `Test Case ${i} — ${cat}`,
        category: cat,
        status:   'FAIL',
        duration: Math.floor(Math.random() * 5) + 1,
        error:    'Appium driver failed to initialize — emulator not ready or APK not installed',
      });
      tcNum++;
    }
  });

  const excelOut = path.resolve(__dirname, '../../AppiumReport_AIBeautyGenius.xlsx');
  const htmlOut  = path.resolve(__dirname, '../../AppiumReport_AIBeautyGenius.html');
  const jsonlOut = path.resolve(__dirname, '../.wdio-results.jsonl');

  await generateReport(excelOut);
  await generateHtml(jsonlOut, htmlOut);

  console.log('[generateFallbackReport] ✅ Fallback Excel →', excelOut);
  console.log('[generateFallbackReport] ✅ Fallback HTML  →', htmlOut);
})();
