#!/usr/bin/env bash
# Check GitHub achievements against the log in achievements.md.
# Usage: scripts/check-achievements.sh [username]
set -euo pipefail

USER_NAME="${1:-BrunosGits}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/achievements.md"

python3 - "$USER_NAME" "$LOG" <<'PYEOF'
import re
import sys
import urllib.request

user, log_path = sys.argv[1], sys.argv[2]
url = f"https://github.com/users/{user}/achievements"
req = urllib.request.Request(url, headers={"User-Agent": "curl/8.7"})
raw = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "replace")

earned = sorted(set(re.sub(r"\s*x\d+$", "", n) for n in re.findall(r'alt="Achievement: ([^"]+)"', raw)))

log = ""
try:
    with open(log_path) as f:
        log = f.read()
except FileNotFoundError:
    pass

print("Achievements shown on the GitHub profile right now:")
if not earned:
    print("  (none found)")
for name in earned:
    print(f"  - {name}")

new = [n for n in earned if n not in log]
if new:
    print()
    print("New, not yet in achievements.md:")
    for name in new:
        print(f"  - {name}")
else:
    print("(all already logged)")
PYEOF
