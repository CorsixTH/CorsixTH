#!/usr/bin/env bash
# Negative control: disable ENTIRE deferral mechanism at world.lua:1849
# This must make the test HANG (since fix is disabled)
# Usage: ./negative_control.sh [apply|restore|run]

set -euo pipefail

WORLD_LUA="/home/bruno/CorsixTH/CorsixTH/Lua/world.lua"
BACKUP_DIR="/home/bruno/CorsixTH/.octo/negative_control_backup"
mkdir -p "$BACKUP_DIR"

ORIGINAL_LINE='if self.current_tick_entity then'
DISABLED_LINE='if false and self.current_tick_entity then'

case "${1:-run}" in
    apply)
        echo "Applying negative control (disabling deferral)..."
        cp "$WORLD_LUA" "$BACKUP_DIR/world.lua.$(date +%s).bak"
        sed -i "s|$ORIGINAL_LINE|$DISABLED_LINE|" "$WORLD_LUA"
        echo "Applied. Verifying..."
        grep -n "$DISABLED_LINE" "$WORLD_LUA"
        ;;
    restore)
        echo "Restoring world.lua from latest backup..."
        LATEST=$(ls -t "$BACKUP_DIR"/world.lua.*.bak 2>/dev/null | head -1)
        if [[ -n "$LATEST" ]]; then
            cp "$LATEST" "$WORLD_LUA"
            echo "Restored from $LATEST"
            grep -n "$ORIGINAL_LINE" "$WORLD_LUA"
        else
            echo "ERROR: No backup found"
            exit 1
        fi
        ;;
    run)
        BINARY="/home/bruno/CorsixTH/build/CorsixTH/corsix-th"
        SMOKETEST="/home/bruno/CorsixTH/smoketest.lua"
        OUTDIR="/home/bruno/CorsixTH/.octo/parallel/negative_control_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$OUTDIR"
        
        echo "Applying negative control..."
        $0 apply
        
        echo "Running with negative control (expect HANG)..."
        OUTFILE="$OUTDIR/run.log"
        ERRFILE="$OUTDIR/run.err"
        timeout -s INT -k 30 300 stdbuf -oL -eL \
            env SMOKE_HEARTBEAT=1 \
            xvfb-run -a "$BINARY" --interpreter="$SMOKETEST" \
            >"$OUTFILE" 2>"$ERRFILE" || EXIT_CODE=$?
        
        echo "Exit code: ${EXIT_CODE:-0}"
        tail -30 "$OUTFILE"
        
        echo "Restoring..."
        $0 restore
        
        # Negative control should TIMEOUT (HANG) - that means fix is exercised
        if [[ ${EXIT_CODE:-0} -eq 124 ]]; then
            echo "NEGATIVE CONTROL: TIMEOUT (HANG) - EXPECTED - fix is exercised"
            echo "HANG" > "$OUTDIR/result"
            exit 0
        elif grep -q "SMOKE: ALL CHECKS PASSED" "$OUTFILE"; then
            echo "NEGATIVE CONTROL: GREEN - UNEXPECTED! Fix NOT exercised"
            echo "GREEN" > "$OUTDIR/result"
            exit 1
        else
            echo "NEGATIVE CONTROL: RED (crash/error)"
            echo "RED" > "$OUTDIR/result"
            exit 2
        fi
        ;;
    verify)
        if grep -q "$ORIGINAL_LINE" "$WORLD_LUA"; then
            echo "VERIFIED: world.lua has original line (fix ACTIVE)"
            exit 0
        else
            echo "ERROR: world.lua does not have original line"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [apply|restore|run|verify]"
        exit 1
        ;;
esac
