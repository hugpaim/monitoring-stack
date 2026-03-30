#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# setup.sh — One-command setup for monitoring-stack
# Usage: ./scripts/setup.sh
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[setup]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; exit 1; }

command -v docker &>/dev/null || err "Docker not found"
docker info &>/dev/null 2>&1  || err "Docker daemon not running"

log "Starting monitoring stack..."
docker compose up -d

log "Waiting for Grafana to be ready..."
MAX=20
for i in $(seq 1 $MAX); do
  if curl -sf http://localhost:3000/api/health &>/dev/null; then
    log "Grafana is ready ✓"; break
  fi
  [[ $i -eq $MAX ]] && err "Grafana did not become ready. Check: docker compose logs grafana"
  sleep 3
done

log "Waiting for Prometheus to be ready..."
for i in $(seq 1 $MAX); do
  if curl -sf http://localhost:9090/-/healthy &>/dev/null; then
    log "Prometheus is ready ✓"; break
  fi
  [[ $i -eq $MAX ]] && err "Prometheus did not become ready"
  sleep 3
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  monitoring-stack is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  📈 Grafana:      http://localhost:3000  (admin / admin)"
echo "  📊 Prometheus:   http://localhost:9090"
echo "  🔔 Alertmanager: http://localhost:9093"
echo "  🖥️  Node Exporter: http://localhost:9100/metrics"
echo "  🐳 cAdvisor:     http://localhost:8080"
echo ""
warn "Change the Grafana admin password after first login!"
echo ""
