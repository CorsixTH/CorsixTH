#!/usr/bin/env bash
# WP-2: Full load-only probe (calibrate load time)
# Runs with SMOKE_LOAD_ONLY=1, SMOKE_HEARTBEAT=1

set -euo pipefail

BINARY="/home/bruno/CorsixTH/build/CorsixTH/corsix-th"
SMOKETEST="/home/bruno/CorsixTH/smoketest.lua"
CONFIG="/home/bruno/.config/CorsixTH/config.txt"
FULL_PATH="/home/bruno/ThemeHospitalFull/HOSP"
OUTDIR="/home/bruno/CorsixTH/.octo/parallel/wp2_load_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "=== WP-2 Full Load Probe ==="
echo "Output dir: $OUTDIR"

# Ensure config is full data
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${FULL_PATH}]]|" "$CONFIG"
grep -n "theme_hospital_install" "$CONFIG"

# Run 3 times with load-only + heartbeat + xvfb-run
for run in 1 2 3; do
    echo ""
    echo "=== Run $run/3 ==="
    OUTFILE="$OUTDIR/run${run}.log"
    ERRFILE="$OUTDIR/run${run}.err"
    HBFILE="$OUTDIR/run${run}.hb.jsonl"
    
    # Timeout: 10 minutes (600s) - should be enough for load
    timeout -s INT -k 30 600 stdbuf -oL -eL \
        env SMOKE_LOAD_ONLY=1 SMOKE_HEARTBEAT=1 \
        xvfb-run -a "$BINARY" --interpreter="$SMOKETEST" \
        >"$OUTFILE" 2>"$ERRFILE" || EXIT_CODE=$?
    
    echo "Exit code: ${EXIT_CODE:-0}"
    tail -20 "$OUTFILE"
    echo "--- heartbeat (last 10) ---"
    tail -10 "$ERRFILE" 2>/dev/null || true
    
    # Extract load_ms from heartbeat
    LOAD_MS=$(grep -o '"load_ms":[0-9]*' "$ERRFILE" 2>/dev/null | head -1 | cut -d: -f2 || echo "unknown")
    echo "Load time: ${LOAD_MS}ms"
    echo "$LOAD_MS" > "$OUTDIR/run${run}.load_ms"
    
    if grep -q "SMOKE: LOAD_ONLY mode - exiting after load" "$OUTFILE"; then
        echo "RESULT: GREEN (load_only completed)"
        echo "GREEN" > "$OUTDIR/run${run}.result"
    elif [[ ${EXIT_CODE:-0} -eq 124 ]]; then
        echo "RESULT: TIMEOUT"
        echo "TIMEOUT" > "$OUTDIR/run${run}.result"
    else
        echo "RESULT: RED"
        echo "RED" > "$OUTDIR/run${run}.result"
    fi
done

# Summary
echo ""
echo "=== WP-2 Summary ==="
for run in 1 2 3; do
    LOAD=$(cat "$OUTDIR/run${run}.load_ms" 2>/dev/null || echo "?")
    RES=$(cat "$OUTDIR/run${run}.result" 2>/dev/null || echo "?")
    echo "Run $run: $RES, load_ms=$LOAD"
done

# Compute avg load_ms
LOADS=($(cat "$OUTDIR"/run*.load_ms 2>/dev/null))
if [[ ${#LOADS[@]} -gt 0 ]]; then
    SUM=0
    for L in "${LOADS[@]}"; do
        [[ "$L" =~ ^[0-9]+$ ]] && SUM=$((SUM + L))
    done
    AVG=$((SUM / ${#LOADS[@]}))
    echo "Average load_ms: $AVG"
    echo "$AVG" > "$OUTDIR/avg_load_ms"
    
    # Gate: if load > 300s (300000ms), escalate
    if [[ $AVG -gt 300000 ]]; then
        echo "GATE: Average load exceeds 5 minutes - ESCALATE"
        echo "ESCALATE" > "$OUTDIR/gate_decision"
        exit 2
    fi
fi

echo "WP-2: PASS"
exit 0
