#!/usr/bin/env bash
# Stop non-essential services at the end of a work session to free up VPS
# resources. The system (ssh, fail2ban, qemu-guest-agent, systemd core) is
# left running, and so is the opencode process used for development.

SERVICES=(docker.socket docker containerd hello postgresql@17-main)

# Gracefully stop any running containers first, so no orphaned processes are
# left behind when the docker daemon goes down.
if command -v docker >/dev/null 2>&1 && docker ps -q >/dev/null 2>&1; then
  local_ids=$(docker ps -q)
  if [ -n "$local_ids" ]; then
    echo "Stopping running containers..."
    docker stop -t 5 $local_ids >/dev/null 2>&1 || true
  fi
fi

for svc in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    echo "Stopping $svc..."
    sudo systemctl stop "$svc" || echo "  warning: could not stop $svc"
  fi
done

# Clean up leftovers from containers that were stopped after the docker daemon
# went away (e.g. container shims and their JVM processes still holding RAM).
if pgrep -f containerd-shim-runc >/dev/null 2>&1; then
  echo "Killing leftover container shims..."
  sudo pkill -9 -f containerd-shim-runc || true
fi
if pgrep -f '/opensearch/jdk/bin/java' >/dev/null 2>&1; then
  echo "Killing leftover OpenSearch processes..."
  sudo pkill -9 -f '/opensearch/jdk/bin/java' || true
fi

echo "Services stopped."
