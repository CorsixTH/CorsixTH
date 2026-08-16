#!/usr/bin/env bash
# WP-1: Demo smoke test (config → demo data)
# Runs 3 times with xvfb-run for headless SDL

set -euo pipefail

BINARY="/home/bruno/CorsixTH/build/CorsixTH/corsix-th"
SMOKETEST="/home/bruno/CorsixTH/smoketest.lua"
CONFIG="/home/bruno/.config/CorsixTH/config.txt"
DEMO_PATH="/home/bruno/ThemeHospitalDemo/demo/HOSP"
FULL_PATH="/home/bruno/ThemeHospitalFull/HOSP"
OUTDIR="/home/bruno/CorsixTH/.octo/parallel/wp1_demo_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "=== WP-1 Demo Smoke ==="
echo "Output dir: $OUTDIR"
echo "Binary: $BINARY"
echo "Config: $CONFIG"

# Switch config to demo
echo "Switching config to demo data..."
cp "$CONFIG" "$CONFIG.bak.$(date +%s)"
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${DEMO_PATH}]]|" "$CONFIG"
grep -n "theme_hospital_install" "$CONFIG"

# Verify demo path exists
if [[ ! -d "$DEMO_PATH" ]]; then
    echo "ERROR: Demo path not found: $DEMO_PATH"
    exit 1
fi

# Run 3 times with xvfb-run
for run in 1 2 3; do
    echo ""
    echo "=== Run $run/3 ==="
    OUTFILE="$OUTDIR/run${run}.log"
    ERRFILE="$OUTDIR/run${run}.err"
    
    # Timeout: 5 minutes (300s) - demo should be fast
    timeout -s INT -k 30 300 stdbuf -oL -eL \
        xvfb-run -a "$BINARY" --interpreter="$SMOKETEST" \
        >"$OUTFILE" 2>"$ERRFILE" || EXIT_CODE=$?
    
    echo "Exit code: ${EXIT_CODE:-0}"
    tail -20 "$OUTFILE"
    echo "--- stderr ---"
    tail -20 "$ERRFILE"
    
    # Classify result
    if grep -q "SMOKE: ALL CHECKS PASSED" "$OUTFILE"; then
        echo "RESULT: GREEN"
        echo "GREEN" > "$OUTDIR/run${run}.result"
    elif [[ ${EXIT_CODE:-0} -eq 124 ]]; then
        echo "RESULT: TIMEOUT (124)"
        echo "TIMEOUT" > "$OUTDIR/run${run}.result"
    else
        echo "RESULT: RED"
        echo "RED" > "$OUTDIR/run${run}.result"
    fi
done

# Summary
echo ""
echo "=== WP-1 Summary ==="
for run in 1 2 3; do
    echo "Run $run: $(cat "$OUTDIR/run${run}.result")"
done

# Restore config to full
echo ""
echo "Restoring config to full data..."
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${FULL_PATH}]]|" "$CONFIG"
grep -n "theme_hospital_install" "$CONFIG"

# Check if all green
if grep -q "RED" "$OUTDIR"/*.result 2>/dev/null || grep -q "TIMEOUT" "$OUTDIR"/*.result 2>/dev/null; then
    echo "WP-1: FAIL (non-green runs)"
    exit 1
else
    echo "WP-1: PASS (all GREEN)"
    exit 0
fi
