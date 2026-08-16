#!/usr/bin/env bash
# Full matrix test runner

set -euo pipefail

BINARY="/home/bruno/CorsixTH/build/CorsixTH/corsix-th"
SMOKETEST="/home/bruno/CorsixTH/smoketest.lua"
CONFIG="/home/bruno/.config/CorsixTH/config.txt"
FULL_PATH="/home/bruno/ThemeHospitalFull/HOSP"
DEMO_PATH="/home/bruno/ThemeHospitalDemo/demo/HOSP"
OUTDIR="/home/bruno/CorsixTH/.octo/parallel/matrix_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "=== Full Matrix Test ==="
echo "Output dir: $OUTDIR"

# Ensure config is full data
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${FULL_PATH}]]|" "$CONFIG"
grep -n "theme_hospital_install" "$CONFIG"

# Test variants
# 1. Headless (no render, no xvfb)
# 2. Offscreen (SDL_VIDEODRIVER=offscreen SMOKE_RENDER=1)
# 3. xvfb (xvfb-run -a env SMOKE_RENDER=1)
# 4. Negative control (run last, expects HANG)
# 5. Demo control (config → demo, xvfb-run)

run_variant() {
    local name="$1"
    local env_vars="$2"
    local cmd_prefix="$3"
    local runs="$4"
    local timeout_sec="$5"
    
    echo ""
    echo "=== Variant: $name ($runs runs) ==="
    
    for run in $(seq 1 $runs); do
        echo "  Run $run/$runs..."
        OUTFILE="$OUTDIR/${name}_run${run}.log"
        ERRFILE="$OUTDIR/${name}_run${run}.err"
        
        timeout -s INT -k 30 $timeout_sec stdbuf -oL -eL \
            env $env_vars SMOKE_HEARTBEAT=1 \
            $cmd_prefix "$BINARY" --interpreter="$SMOKETEST" \
            >"$OUTFILE" 2>"$ERRFILE" || EXIT_CODE=$?
        
        if grep -q "SMOKE: ALL CHECKS PASSED" "$OUTFILE"; then
            echo "    GREEN"
            echo "GREEN" > "$OUTDIR/${name}_run${run}.result"
        elif [[ ${EXIT_CODE:-0} -eq 124 ]]; then
            echo "    TIMEOUT"
            echo "TIMEOUT" > "$OUTDIR/${name}_run${run}.result"
        else
            echo "    RED"
            echo "RED" > "$OUTDIR/${name}_run${run}.result"
        fi
    done
}

# Headless: 3 runs, 5 min timeout
run_variant "headless" "" "" 3 300

# Offscreen: 3 runs, 5 min timeout
run_variant "offscreen" "SDL_VIDEODRIVER=offscreen SMOKE_RENDER=1" "" 3 300

# xvfb: 3 runs, 5 min timeout
run_variant "xvfb" "SMOKE_RENDER=1" "xvfb-run -a" 3 300

# Negative control: 1 run, 5 min timeout (expects HANG)
echo ""
echo "=== Variant: negative_control (1 run) ==="
OUTFILE="$OUTDIR/negative_control_run1.log"
ERRFILE="$OUTDIR/negative_control_run1.err"

# Apply negative control
cp /home/bruno/CorsixTH/CorsixTH/Lua/world.lua /home/bruno/CorsixTH/.octo/negative_control_backup/world.lua.$(date +%s).bak
sed -i 's|if self.current_tick_entity then|if false and self.current_tick_entity then|' /home/bruno/CorsixTH/CorsixTH/Lua/world.lua

timeout -s INT -k 30 300 stdbuf -oL -eL \
    env SMOKE_HEARTBEAT=1 \
    xvfb-run -a "$BINARY" --interpreter="$SMOKETEST" \
    >"$OUTFILE" 2>"$ERRFILE" || EXIT_CODE=$?

# Restore
LATEST=$(ls -t /home/bruno/CorsixTH/.octo/negative_control_backup/world.lua.*.bak 2>/dev/null | head -1)
cp "$LATEST" /home/bruno/CorsixTH/CorsixTH/Lua/world.lua

if [[ ${EXIT_CODE:-0} -eq 124 ]]; then
    echo "  HANG (expected)"
    echo "HANG" > "$OUTDIR/negative_control_run1.result"
elif grep -q "SMOKE: ALL CHECKS PASSED" "$OUTFILE"; then
    echo "  GREEN (UNEXPECTED - fix not exercised)"
    echo "GREEN" > "$OUTDIR/negative_control_run1.result"
else
    echo "  RED (crash/error)"
    echo "RED" > "$OUTDIR/negative_control_run1.result"
fi

# Demo control: 2 runs, 3 min timeout
echo ""
echo "=== Variant: demo_control (2 runs) ==="
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${DEMO_PATH}]]|" "$CONFIG"

run_variant "demo_control" "SMOKE_HEARTBEAT=1" "xvfb-run -a" 2 180

# Restore config to full
sed -i "s|theme_hospital_install = \[\[.*\]\]|theme_hospital_install = [[${FULL_PATH}]]|" "$CONFIG"

# Summary
echo ""
echo "=== Matrix Summary ==="
for f in "$OUTDIR"/*.result; do
    if [[ -f "$f" ]]; then
        name=$(basename "$f" .result)
        result=$(cat "$f")
        echo "  $name: $result"
    fi
done

# Check overall
FAIL=0
for f in "$OUTDIR"/*.result; do
    if [[ -f "$f" ]]; then
        result=$(cat "$f")
        if [[ "$result" == "RED" || "$result" == "TIMEOUT" ]]; then
            # Negative control should be HANG, not RED/TIMEOUT
            if [[ $(basename "$f") == negative_control* ]]; then
                if [[ "$result" != "HANG" ]]; then
                    echo "FAIL: negative_control should be HANG, got $result"
                    FAIL=1
                fi
            else
                echo "FAIL: $f is $result"
                FAIL=1
            fi
        fi
    fi
done

if [[ $FAIL -eq 0 ]]; then
    echo "MATRIX: ALL PASSED"
    exit 0
else
    echo "MATRIX: FAILED"
    exit 1
fi
