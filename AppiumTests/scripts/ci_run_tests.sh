#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# AI Beauty Genius — Appium CI Runner Script
# Runs inside GitHub Actions Android Emulator Runner
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIUM_DIR="$(dirname "$SCRIPT_DIR")"
APK_PATH="${APK_PATH:-/home/runner/work/appbeauty/appbeauty/app/build/outputs/apk/debug/app-debug.apk}"

echo "════════════════════════════════════════════════════════"
echo "  AI Beauty Genius — Mobile Appium E2E CI Runner"
echo "  1,111 Android Tests | 11 Categories × 101 Tests"
echo "════════════════════════════════════════════════════════"

# ── Step 1: Inject Node.js into PATH from GITHUB_PATH ────────────────────────
echo "→ Injecting Node.js path from GITHUB_PATH..."
if [ -f "${GITHUB_PATH:-/dev/null}" ]; then
  while IFS= read -r p; do
    export PATH="$p:$PATH"
  done < "$GITHUB_PATH"
fi

# Verify node is available
node --version || { echo "❌ Node.js not found in PATH!"; exit 1; }
echo "✅ Node.js version: $(node --version)"

# ── Step 2: Wait for emulator to be fully ready ───────────────────────────────
echo "→ Waiting for Android emulator to boot..."
adb wait-for-device
boot_status=""
attempts=0
until [[ "$boot_status" == *"stopped"* ]]; do
  boot_status=$(adb shell getprop init.svc.bootanim 2>/dev/null || echo "")
  echo "   Boot status: ${boot_status:-pending}"
  sleep 3
  ((attempts++))
  if [ $attempts -gt 60 ]; then
    echo "❌ Emulator did not boot in 3 minutes. Aborting."
    exit 1
  fi
done
echo "✅ Emulator booted successfully!"

# ── Step 3: Install APK ───────────────────────────────────────────────────────
echo "→ Installing APK: ${APK_PATH}"
if [ -f "${APK_PATH}" ]; then
  adb install -r "${APK_PATH}"
  echo "✅ APK installed: ${APK_PATH}"
else
  echo "⚠️  APK not found at ${APK_PATH} — tests will use mock mode"
fi

# Unlock screen
adb shell input keyevent 82 || true

# ── Step 4: Start Appium Server ───────────────────────────────────────────────
echo "→ Starting Appium server..."
cd "${APPIUM_DIR}"
npx appium --log-level warn --port 4723 > /tmp/appium.log 2>&1 &
APPIUM_PID=$!
echo "   Appium PID: $APPIUM_PID"

# Wait for Appium to be ready (poll /status)
echo "→ Waiting for Appium to start on port 4723..."
appium_ready=false
for i in $(seq 1 30); do
  if curl -sf http://localhost:4723/status > /dev/null 2>&1; then
    appium_ready=true
    break
  fi
  echo "   Attempt $i/30 — waiting 2s..."
  sleep 2
done

if [ "$appium_ready" = false ]; then
  echo "❌ Appium did not start in 60 seconds. Generating fallback report..."
  node "${APPIUM_DIR}/utils/generateFallbackReport.js" || true
  exit 1
fi
echo "✅ Appium server is ready on port 4723"

# ── Step 5: Run WDIO Tests ───────────────────────────────────────────────────
echo "→ Running AI Beauty Genius Appium Test Suite..."
WDIO_CI_SPEC="tests/mega_android_1111.test.js" \
APPIUM_HOST="localhost" \
APPIUM_PORT="4723" \
  node "${APPIUM_DIR}/node_modules/@wdio/cli/bin/wdio.js" \
    run "${APPIUM_DIR}/wdio.conf.js"
WDIO_EXIT=$?

# ── Step 6: Handle WDIO Exit ─────────────────────────────────────────────────
if [ $WDIO_EXIT -ne 0 ]; then
  echo "⚠️  WDIO exited with code $WDIO_EXIT — generating fallback report..."
  node "${APPIUM_DIR}/utils/generateFallbackReport.js" || true
fi

# ── Step 7: Stop Appium ───────────────────────────────────────────────────────
echo "→ Stopping Appium server (PID: $APPIUM_PID)..."
kill $APPIUM_PID 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════"
echo "  AI Beauty Genius Appium CI Run COMPLETE"
echo "════════════════════════════════════════════════════════"

exit $WDIO_EXIT
