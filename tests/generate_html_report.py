import os
import datetime
import requests
import time
import json

# Load all 300 test results from the JSON dumped by test_suite.py
results_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results.json")
try:
    with open(results_file, "r", encoding="utf-8") as f:
        results = json.load(f)
except Exception as e:
    print(f"Error loading {results_file}: {e}")
    results = []

from collections import defaultdict

total = len(results)
passed = sum(1 for r in results if r["status"] == "PASS")
failed = total - passed
pass_rate = passed / total * 100

cat_stats = defaultdict(lambda: {"total": 0, "passed": 0})
for r in results:
    cat_stats[r["category"]]["total"] += 1
    if r["status"] == "PASS":
        cat_stats[r["category"]]["passed"] += 1

CATEGORY_COLORS = {
    "UI/UX Testing": "#7C3AED",
    "Functional Testing": "#2563EB",
    "Unit & Integration Testing": "#0891B2",
    "Validation & Boundary Testing": "#D97706",
    "Vulnerability & Security Testing": "#DC2626",
    "Deployment & Infrastructure": "#059669",
}

rows_html = ""
for i, t in enumerate(results):
    bg = "#ffffff" if i % 2 == 0 else "#f8fafc"
    st = t["status"]
    badge_cls = "pass-badge" if st == "PASS" else "fail-badge"
    cat_color = CATEGORY_COLORS.get(t["category"], "#64748b")
    rows_html += f"""
    <tr style="background:{bg}">
      <td class="mono" style="color:#64748b;font-size:11px;">{t['id']}</td>
      <td><span class="cat-pill" style="background:{cat_color}22;color:{cat_color};border:1px solid {cat_color}44">{t['category']}</span></td>
      <td style="font-size:12px;color:#475569">{t['module']}</td>
      <td style="font-weight:600;color:#1e293b">{t['title']}</td>
      <td style="font-size:12px;color:#64748b">{t['description']}</td>
      <td style="font-size:12px;color:#64748b;white-space:pre-line">{t['steps']}</td>
      <td style="font-size:12px;color:#059669">{t['expected']}</td>
      <td style="font-size:12px;color:#334155">{t['actual']}</td>
      <td><span class="{badge_cls}">{st}</span></td>
      <td class="mono" style="text-align:center;font-size:12px">{t['priority']}</td>
    </tr>"""

cat_rows_html = ""
for cat, stats in cat_stats.items():
    ct = stats["total"]
    cp = stats["passed"]
    cf = ct - cp
    cr = cp / ct * 100
    col = CATEGORY_COLORS.get(cat, "#64748b")
    status_lbl = "HEALTHY" if cr >= 90 else "WARNING"
    status_col = "#059669" if cr >= 90 else "#d97706"
    cat_rows_html += f"""
    <tr>
      <td><span class="cat-pill" style="background:{col}22;color:{col};border:1px solid {col}44">{cat}</span></td>
      <td style="text-align:center;font-weight:700">{ct}</td>
      <td style="text-align:center;color:#059669;font-weight:700">{cp}</td>
      <td style="text-align:center;color:#dc2626;font-weight:700">{cf}</td>
      <td style="text-align:center;font-weight:700">{cr:.1f}%</td>
      <td style="text-align:center"><span style="color:{status_col};font-weight:700;font-size:12px">{status_lbl}</span></td>
    </tr>"""

now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
deploy_status = "✅ DEPLOYABLE" if pass_rate >= 90 else "⚠️ NEEDS ATTENTION"
deploy_color = "#059669" if pass_rate >= 90 else "#d97706"

html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI Beauty Genius — E2E Test Report</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
  *{{margin:0;padding:0;box-sizing:border-box}}
  body{{font-family:'Inter',sans-serif;background:#f1f5f9;color:#1e293b;min-height:100vh}}

  /* HEADER */
  .hero{{background:linear-gradient(135deg,#1e1b4b 0%,#312e81 40%,#4c1d95 70%,#6d28d9 100%);padding:40px 48px;color:#fff;position:relative;overflow:hidden}}
  .hero::before{{content:'';position:absolute;top:-80px;right:-80px;width:320px;height:320px;border-radius:50%;background:rgba(255,255,255,0.05)}}
  .hero::after{{content:'';position:absolute;bottom:-60px;left:200px;width:200px;height:200px;border-radius:50%;background:rgba(255,255,255,0.04)}}
  .hero-badge{{display:inline-block;background:rgba(255,255,255,0.15);border:1px solid rgba(255,255,255,0.25);border-radius:20px;padding:4px 14px;font-size:12px;font-weight:600;letter-spacing:.5px;margin-bottom:16px}}
  .hero h1{{font-size:28px;font-weight:800;line-height:1.3;margin-bottom:8px}}
  .hero p{{opacity:.75;font-size:13px;margin-bottom:4px}}
  .hero-meta{{display:flex;gap:24px;margin-top:20px;flex-wrap:wrap}}
  .hero-meta span{{background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.2);border-radius:8px;padding:6px 14px;font-size:12px;font-weight:500}}

  /* KPI CARDS */
  .kpi-grid{{display:grid;grid-template-columns:repeat(5,1fr);gap:16px;padding:28px 48px 0;position:relative;z-index:1;margin-top:-24px}}
  .kpi-card{{background:#fff;border-radius:16px;padding:20px 24px;box-shadow:0 4px 24px rgba(0,0,0,0.08);border:1px solid #e2e8f0;text-align:center}}
  .kpi-num{{font-size:36px;font-weight:800;line-height:1}}
  .kpi-label{{font-size:11px;font-weight:600;color:#94a3b8;text-transform:uppercase;letter-spacing:.6px;margin-top:6px}}

  /* CONTENT */
  .content{{padding:32px 48px 60px}}
  .section-title{{font-size:18px;font-weight:700;color:#1e293b;margin-bottom:16px;padding-bottom:10px;border-bottom:2px solid #e2e8f0;display:flex;align-items:center;gap:10px}}
  .section-title span{{width:4px;height:20px;border-radius:2px;display:inline-block}}

  /* CATEGORY TABLE */
  .card{{background:#fff;border-radius:16px;box-shadow:0 2px 16px rgba(0,0,0,0.06);border:1px solid #e2e8f0;overflow:hidden;margin-bottom:32px}}
  table{{width:100%;border-collapse:collapse}}
  thead tr{{background:linear-gradient(90deg,#1e1b4b,#4c1d95)}}
  thead th{{color:#fff;padding:12px 16px;font-size:12px;font-weight:600;text-align:left;letter-spacing:.4px}}
  tbody td{{padding:12px 16px;border-bottom:1px solid #f1f5f9;font-size:13px;vertical-align:top}}
  tbody tr:last-child td{{border-bottom:none}}
  tbody tr:hover{{background:#f8fafc!important}}

  /* BADGES */
  .pass-badge{{display:inline-block;background:#dcfce7;color:#15803d;border:1px solid #86efac;border-radius:20px;padding:3px 12px;font-size:11px;font-weight:700;letter-spacing:.3px}}
  .fail-badge{{display:inline-block;background:#fee2e2;color:#dc2626;border:1px solid #fca5a5;border-radius:20px;padding:3px 12px;font-size:11px;font-weight:700;letter-spacing:.3px}}
  .cat-pill{{display:inline-block;border-radius:20px;padding:3px 10px;font-size:11px;font-weight:600}}
  .mono{{font-family:'Courier New',monospace}}

  /* PROGRESS BAR */
  .progress-wrap{{background:#e2e8f0;border-radius:100px;height:8px;overflow:hidden;margin-top:12px}}
  .progress-bar{{height:100%;border-radius:100px;background:linear-gradient(90deg,#7c3aed,#06b6d4);transition:width .3s}}

  /* SUMMARY FOOTER */
  .summary-footer{{background:linear-gradient(135deg,#0f172a,#1e1b4b);color:#fff;padding:32px 48px;border-radius:16px;margin-top:8px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:20px}}
  .footer-stat{{text-align:center}}
  .footer-stat-num{{font-size:28px;font-weight:800}}
  .footer-stat-lbl{{font-size:11px;color:#94a3b8;font-weight:600;margin-top:4px;text-transform:uppercase}}

  /* PRINT BUTTON */
  .btn-print{{position:fixed;bottom:28px;right:28px;background:linear-gradient(135deg,#7c3aed,#4c1d95);color:#fff;border:none;border-radius:14px;padding:14px 24px;font-family:'Inter',sans-serif;font-size:14px;font-weight:600;cursor:pointer;box-shadow:0 8px 24px rgba(124,58,237,.4);z-index:999;transition:.2s}}
  .btn-print:hover{{transform:translateY(-2px);box-shadow:0 12px 32px rgba(124,58,237,.5)}}

  @media print{{.btn-print{{display:none}};body{{background:#fff}}}}
</style>
</head>
<body>

<button class="btn-print" onclick="window.print()">🖨️ Print / Save PDF</button>

<!-- HERO HEADER -->
<div class="hero">
  <div class="hero-badge">🤖 AI BEAUTY GENIUS — APPBEAUTY</div>
  <h1>Automated E2E Test Report</h1>
  <p>Selenium · PyTest · HTTP API · Security · Deployment</p>
  <div class="hero-meta">
    <span>📅 Generated: {now_str}</span>
    <span>🌐 Target: nethra900000.github.io/appbeauty</span>
    <span>🔁 CI/CD: GitHub Actions (auto on every push)</span>
    <span>📦 Repository: Nethra900000/appbeauty</span>
  </div>
</div>

<!-- KPI CARDS -->
<div class="kpi-grid">
  <div class="kpi-card">
    <div class="kpi-num" style="color:#1e1b4b">{total}</div>
    <div class="kpi-label">Total Test Cases</div>
  </div>
  <div class="kpi-card">
    <div class="kpi-num" style="color:#059669">{passed}</div>
    <div class="kpi-label">Tests Passed</div>
  </div>
  <div class="kpi-card">
    <div class="kpi-num" style="color:#dc2626">{failed}</div>
    <div class="kpi-label">Tests Failed</div>
  </div>
  <div class="kpi-card">
    <div class="kpi-num" style="color:#7c3aed">{pass_rate:.1f}%</div>
    <div class="kpi-label">Pass Rate</div>
    <div class="progress-wrap"><div class="progress-bar" style="width:{pass_rate:.1f}%"></div></div>
  </div>
  <div class="kpi-card">
    <div class="kpi-num" style="color:{deploy_color};font-size:22px;margin-top:6px">{deploy_status}</div>
    <div class="kpi-label">Deployment Status</div>
  </div>
</div>

<div class="content">

  <!-- CATEGORY BREAKDOWN -->
  <div class="section-title"><span style="background:#7c3aed"></span>Category Breakdown</div>
  <div class="card">
    <table>
      <thead>
        <tr>
          <th>Test Category</th><th style="text-align:center">Total</th>
          <th style="text-align:center">Passed</th><th style="text-align:center">Failed</th>
          <th style="text-align:center">Pass Rate</th><th style="text-align:center">Status</th>
        </tr>
      </thead>
      <tbody>{cat_rows_html}</tbody>
    </table>
  </div>

  <!-- DETAILED RESULTS -->
  <div class="section-title"><span style="background:#2563eb"></span>Detailed Test Cases — All {total} Tests</div>
  <div class="card" style="overflow-x:auto">
    <table>
      <thead>
        <tr>
          <th>Test ID</th><th>Category</th><th>Module/Route</th>
          <th>Test Case Title</th><th>Description</th>
          <th>Test Steps</th><th>Expected Result</th>
          <th>Actual Result</th><th>Status</th><th>Priority</th>
        </tr>
      </thead>
      <tbody>{rows_html}</tbody>
    </table>
  </div>

  <!-- FOOTER SUMMARY -->
  <div class="summary-footer">
    <div>
      <div style="font-size:20px;font-weight:800;margin-bottom:6px">🧪 AI Beauty Genius — AppBeauty</div>
      <div style="color:#94a3b8;font-size:13px">Automated E2E Test Suite · Selenium + PyTest + GitHub Actions</div>
      <div style="color:#64748b;font-size:12px;margin-top:4px">Generated: {now_str} | Nethra900000/appbeauty</div>
    </div>
    <div style="display:flex;gap:40px;flex-wrap:wrap">
      <div class="footer-stat">
        <div class="footer-stat-num" style="color:#a5f3fc">{total}</div>
        <div class="footer-stat-lbl">Total Tests</div>
      </div>
      <div class="footer-stat">
        <div class="footer-stat-num" style="color:#86efac">{passed}</div>
        <div class="footer-stat-lbl">Passed</div>
      </div>
      <div class="footer-stat">
        <div class="footer-stat-num" style="color:#fca5a5">{failed}</div>
        <div class="footer-stat-lbl">Failed</div>
      </div>
      <div class="footer-stat">
        <div class="footer-stat-num" style="color:#c4b5fd">{pass_rate:.1f}%</div>
        <div class="footer-stat-lbl">Pass Rate</div>
      </div>
    </div>
  </div>

</div>
</body>
</html>"""

output_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "E2E_Test_Report_AppBeauty.html")
with open(output_path, "w", encoding="utf-8") as f:
    f.write(html)

print(f"[SUCCESS] HTML Test Report generated: {output_path}")
print(f"Total: {total} | Passed: {passed} | Failed: {failed} | Pass Rate: {pass_rate:.1f}%")
