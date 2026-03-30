#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# test-alert.sh — Fire a test alert to Alertmanager
# Usage: ./scripts/test-alert.sh [--resolve]
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
RESOLVE=false
[[ "${1:-}" == "--resolve" ]] && RESOLVE=true

AM_URL="http://localhost:9093"
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENDS_AT=$(date -u -d "+1 hour" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
          date -u -v+1H +"%Y-%m-%dT%H:%M:%SZ")

if $RESOLVE; then
  ENDS_AT="$NOW"
  echo -e "${YELLOW}▶ Resolving test alert...${NC}"
else
  echo -e "${YELLOW}▶ Firing test alert to Alertmanager at ${AM_URL}...${NC}"
fi

PAYLOAD=$(cat << EOF
[{
  "labels": {
    "alertname": "TestAlert",
    "severity":  "warning",
    "instance":  "localhost:9090",
    "job":       "test"
  },
  "annotations": {
    "summary":     "This is a test alert from monitoring-stack",
    "description": "Fired via test-alert.sh at ${NOW}"
  },
  "startsAt": "${NOW}",
  "endsAt":   "${ENDS_AT}"
}]
EOF
)

HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" \
  -X POST "${AM_URL}/api/v2/alerts" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if [[ "$HTTP_CODE" == "200" ]]; then
  if $RESOLVE; then
    echo -e "${GREEN}✓ Alert resolved${NC}"
  else
    echo -e "${GREEN}✓ Test alert fired (HTTP $HTTP_CODE)${NC}"
    echo ""
    echo "  View at: ${AM_URL}/#/alerts"
    echo "  Resolve: ./scripts/test-alert.sh --resolve"
  fi
else
  echo "✗ Failed (HTTP $HTTP_CODE) — is Alertmanager running?"
  exit 1
fi
