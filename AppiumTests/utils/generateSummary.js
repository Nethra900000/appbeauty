// ─────────────────────────────────────────────────────────────────────────────
// AI Beauty Genius — GitHub Actions Summary Generator
// ─────────────────────────────────────────────────────────────────────────────
const fs   = require('fs');
const path = require('path');

module.exports = function generateSummary(resultsJsonlPath) {
  let results = [];

  if (fs.existsSync(resultsJsonlPath)) {
    const lines = fs.readFileSync(resultsJsonlPath, 'utf-8').trim().split('\n').filter(Boolean);
    results = lines.map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
  }

  const total  = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = total - passed;
  const rate   = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';

  // Group by category
  const categories = {};
  results.forEach(r => {
    if (!categories[r.category]) categories[r.category] = [];
    categories[r.category].push(r);
  });

  const summaryPath = process.env.GITHUB_STEP_SUMMARY;
  const summaryLines = [];

  summaryLines.push('# 🌟 AI Beauty Genius — Android Appium E2E Test Results\n');
  summaryLines.push(`> **Generated:** ${new Date().toLocaleString()}\n`);
  summaryLines.push('---\n');

  // Stats table
  summaryLines.push('## 📊 Summary Statistics\n');
  summaryLines.push('| Metric | Value |');
  summaryLines.push('|--------|-------|');
  summaryLines.push(`| 📱 Total Tests | **${total.toLocaleString()}** |`);
  summaryLines.push(`| ✅ Tests Passed | **${passed.toLocaleString()}** |`);
  summaryLines.push(`| ❌ Tests Failed | **${failed.toLocaleString()}** |`);
  summaryLines.push(`| 📈 Pass Rate | **${rate}%** |`);
  summaryLines.push(`| 📅 Run Date | ${new Date().toLocaleDateString()} |`);
  summaryLines.push('');

  // Category breakdown
  summaryLines.push('## 📁 Results by Category\n');
  summaryLines.push('| Category | Total | ✅ Passed | ❌ Failed | Pass Rate |');
  summaryLines.push('|----------|-------|---------|---------|----------|');

  Object.entries(categories).forEach(([cat, tests]) => {
    const cp = tests.filter(t => t.status === 'PASS').length;
    const cf = tests.length - cp;
    const cr = ((cp / tests.length) * 100).toFixed(1);
    const icon = cf === 0 ? '✅' : '❌';
    summaryLines.push(`| ${icon} ${cat} | ${tests.length} | ${cp} | ${cf} | ${cr}% |`);
  });

  summaryLines.push('');

  // Overall result banner
  if (failed === 0) {
    summaryLines.push('## 🎉 All Tests Passed!\n');
    summaryLines.push(`> ✅ **${total} tests executed — ${passed} passed — 0 failed — ${rate}% pass rate**`);
  } else {
    summaryLines.push('## ⚠️ Some Tests Failed\n');
    summaryLines.push(`> ❌ **${total} tests executed — ${passed} passed — ${failed} failed — ${rate}% pass rate**`);
  }

  const summaryText = summaryLines.join('\n');

  // Write to GitHub Actions Step Summary if available
  if (summaryPath) {
    fs.appendFileSync(summaryPath, summaryText + '\n', 'utf-8');
    console.log('[generateSummary] ✅ Written to GITHUB_STEP_SUMMARY');
  } else {
    // Print to console as fallback
    console.log('\n' + summaryText + '\n');
    console.log('[generateSummary] ℹ️  GITHUB_STEP_SUMMARY not set — printed to console');
  }

  return { total, passed, failed, rate };
};
