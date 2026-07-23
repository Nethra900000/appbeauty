// ─────────────────────────────────────────────────────────────────────────────
// AI Beauty Genius — HTML Report Generator
// ─────────────────────────────────────────────────────────────────────────────
const fs   = require('fs');
const path = require('path');

module.exports = async function generateHtmlReport(resultsJsonlPath, outputHtmlPath) {
  let results = [];

  if (fs.existsSync(resultsJsonlPath)) {
    const lines = fs.readFileSync(resultsJsonlPath, 'utf-8').trim().split('\n').filter(Boolean);
    results = lines.map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
  }

  const total   = results.length;
  const passed  = results.filter(r => r.status === 'PASS').length;
  const failed  = total - passed;
  const rate    = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';

  // Group by category
  const categories = {};
  results.forEach(r => {
    if (!categories[r.category]) categories[r.category] = [];
    categories[r.category].push(r);
  });

  const categoryRows = Object.entries(categories).map(([cat, tests]) => {
    const cp = tests.filter(t => t.status === 'PASS').length;
    const cf = tests.length - cp;
    const cr = ((cp / tests.length) * 100).toFixed(1);
    const statusBadge = cf === 0
      ? `<span class="badge pass">✅ PASS</span>`
      : `<span class="badge fail">❌ ${cf} FAIL</span>`;
    return `
      <tr>
        <td>${cat}</td>
        <td class="center">${tests.length}</td>
        <td class="center pass-text">${cp}</td>
        <td class="center fail-text">${cf}</td>
        <td class="center">${cr}%</td>
        <td class="center">${statusBadge}</td>
      </tr>`;
  }).join('');

  const testRows = results.map((r, i) => {
    const statusBadge = r.status === 'PASS'
      ? `<span class="badge pass">PASS</span>`
      : `<span class="badge fail">FAIL</span>`;
    const errorText = r.error ? `<span class="error-text">${escapeHtml(r.error)}</span>` : '—';
    const rowClass  = i % 2 === 0 ? 'row-alt' : '';
    return `
      <tr class="${rowClass}">
        <td class="center mono">${i + 1}</td>
        <td class="mono id-col">${r.id}</td>
        <td>${escapeHtml(r.category || '')}</td>
        <td>${escapeHtml(r.title || '')}</td>
        <td class="center">${statusBadge}</td>
        <td class="center">${r.duration}ms</td>
        <td>${errorText}</td>
      </tr>`;
  }).join('');

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Beauty Genius — Android Appium E2E Test Report</title>
  <style>
    :root {
      --bg: #0D0D1A;
      --surface: #16213E;
      --surface2: #1A1A2E;
      --accent: #E94560;
      --pass: #27AE60;
      --fail: #E74C3C;
      --gold: #F39C12;
      --text: #ECF0F1;
      --muted: #BDC3C7;
      --border: rgba(233,69,96,0.3);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: 'Segoe UI', system-ui, sans-serif;
      font-size: 14px;
      line-height: 1.5;
    }
    .header {
      background: linear-gradient(135deg, #1A1A2E 0%, #16213E 50%, #0F3460 100%);
      border-bottom: 3px solid var(--accent);
      padding: 32px 40px;
      text-align: center;
    }
    .header h1 { font-size: 2rem; color: var(--accent); margin-bottom: 8px; }
    .header p  { color: var(--muted); font-size: 0.95rem; }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      padding: 32px 40px;
      max-width: 1400px;
      margin: 0 auto;
    }
    .stat-card {
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 24px;
      text-align: center;
      transition: transform 0.2s;
    }
    .stat-card:hover { transform: translateY(-2px); }
    .stat-value { font-size: 2.4rem; font-weight: 800; margin-bottom: 6px; }
    .stat-label { color: var(--muted); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }
    .stat-total  .stat-value { color: var(--gold); }
    .stat-pass   .stat-value { color: var(--pass); }
    .stat-fail   .stat-value { color: var(--fail); }
    .stat-rate   .stat-value { color: ${passed === total ? 'var(--pass)' : 'var(--gold)'}; }
    .section { max-width: 1400px; margin: 0 auto 40px; padding: 0 40px; }
    .section-title {
      font-size: 1.3rem;
      font-weight: 700;
      color: var(--accent);
      margin-bottom: 16px;
      padding-bottom: 8px;
      border-bottom: 2px solid var(--border);
    }
    table { width: 100%; border-collapse: collapse; }
    thead tr { background: #1A1A2E; }
    thead th {
      padding: 12px 14px;
      text-align: left;
      font-weight: 700;
      color: var(--accent);
      font-size: 0.8rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      border-bottom: 2px solid var(--accent);
    }
    tbody tr { transition: background 0.15s; }
    tbody tr:hover { background: rgba(233,69,96,0.08) !important; }
    tbody td {
      padding: 9px 14px;
      border-bottom: 1px solid rgba(255,255,255,0.04);
      color: var(--text);
    }
    .row-alt { background: rgba(22,33,62,0.5); }
    .center { text-align: center; }
    .mono { font-family: 'Courier New', monospace; font-size: 12px; }
    .id-col { color: var(--accent); font-weight: 600; }
    .pass-text { color: var(--pass); font-weight: 700; }
    .fail-text { color: var(--fail); font-weight: 700; }
    .error-text { color: var(--fail); font-size: 12px; }
    .badge {
      display: inline-block;
      padding: 2px 10px;
      border-radius: 12px;
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
    }
    .badge.pass { background: rgba(39,174,96,0.2); color: var(--pass); border: 1px solid var(--pass); }
    .badge.fail { background: rgba(231,76,60,0.2); color: var(--fail); border: 1px solid var(--fail); }
    .progress-bar {
      height: 12px;
      background: var(--surface2);
      border-radius: 6px;
      overflow: hidden;
      margin: 20px 0 32px;
    }
    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, var(--pass), #2ECC71);
      border-radius: 6px;
      transition: width 0.6s ease;
      width: ${rate}%;
    }
    .search-box {
      width: 100%;
      padding: 10px 16px;
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 8px;
      color: var(--text);
      font-size: 14px;
      margin-bottom: 16px;
      outline: none;
    }
    .search-box:focus { border-color: var(--accent); }
    .footer {
      text-align: center;
      padding: 32px;
      color: var(--muted);
      border-top: 1px solid var(--border);
      font-size: 0.85rem;
    }
    .tag {
      display: inline-block;
      background: rgba(233,69,96,0.15);
      color: var(--accent);
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 600;
      margin-right: 6px;
    }
    @media (max-width: 768px) {
      .stats-grid { grid-template-columns: repeat(2, 1fr); }
      .section, .stats-grid { padding: 0 16px; }
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>🌟 AI Beauty Genius — Android Appium E2E</h1>
    <p>Mobile Test Suite Report &nbsp;|&nbsp; Generated: ${new Date().toLocaleString()}</p>
    <p style="margin-top:8px;">
      <span class="tag">📱 Android</span>
      <span class="tag">🤖 Appium UIAutomator2</span>
      <span class="tag">🧪 ${total} Tests</span>
      <span class="tag">11 Categories</span>
    </p>
  </div>

  <div class="stats-grid">
    <div class="stat-card stat-total">
      <div class="stat-value">${total.toLocaleString()}</div>
      <div class="stat-label">📱 Total Tests</div>
    </div>
    <div class="stat-card stat-pass">
      <div class="stat-value">${passed.toLocaleString()}</div>
      <div class="stat-label">✅ Passed</div>
    </div>
    <div class="stat-card stat-fail">
      <div class="stat-value">${failed.toLocaleString()}</div>
      <div class="stat-label">❌ Failed</div>
    </div>
    <div class="stat-card stat-rate">
      <div class="stat-value">${rate}%</div>
      <div class="stat-label">📈 Pass Rate</div>
    </div>
  </div>

  <div class="section">
    <div class="progress-bar">
      <div class="progress-fill"></div>
    </div>
  </div>

  <div class="section">
    <div class="section-title">📁 Results by Category</div>
    <table>
      <thead>
        <tr>
          <th>Category</th>
          <th>Total</th>
          <th>Passed</th>
          <th>Failed</th>
          <th>Pass Rate</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>${categoryRows}</tbody>
    </table>
  </div>

  <div class="section">
    <div class="section-title">🧪 All Test Cases (${total})</div>
    <input class="search-box" type="text" id="searchBox" placeholder="🔍 Search test ID, title, category, status..." oninput="filterTable()">
    <table id="testTable">
      <thead>
        <tr>
          <th>#</th>
          <th>Test ID</th>
          <th>Category</th>
          <th>Test Title</th>
          <th>Status</th>
          <th>Duration</th>
          <th>Error</th>
        </tr>
      </thead>
      <tbody id="testBody">${testRows}</tbody>
    </table>
  </div>

  <div class="footer">
    AI Beauty Genius Android Appium E2E Test Suite &nbsp;|&nbsp;
    ${total} Tests | ${passed} Passed | ${failed} Failed | Pass Rate: ${rate}%<br>
    <small>Generated by Mobile Appium E2E CI Pipeline • ${new Date().toISOString()}</small>
  </div>

  <script>
    function filterTable() {
      const q = document.getElementById('searchBox').value.toLowerCase();
      const rows = document.querySelectorAll('#testBody tr');
      rows.forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
      });
    }
  </script>
</body>
</html>`;

  fs.writeFileSync(outputHtmlPath, html, 'utf-8');
  console.log(`[generateHtmlReport] ✅ HTML report saved → ${outputHtmlPath}`);
};

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
