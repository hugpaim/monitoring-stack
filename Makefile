.PHONY: up down logs health reload test-alert clean ps

GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
RESET  := \033[0m

help:
	@echo ""
	@echo "$(BLUE)monitoring-stack$(RESET) — available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-14s$(RESET) %s\n", $$1, $$2}'
	@echo ""

up: ## Start full monitoring stack
	@echo "$(GREEN)▶ Starting monitoring stack...$(RESET)"
	docker compose up -d
	@echo ""
	@echo "  Grafana:      http://localhost:3000  (admin / admin)"
	@echo "  Prometheus:   http://localhost:9090"
	@echo "  Alertmanager: http://localhost:9093"
	@echo "  Node Exporter: http://localhost:9100"
	@echo "  cAdvisor:     http://localhost:8080"

down: ## Stop all services
	docker compose down

logs: ## Tail all logs
	docker compose logs -f

ps: ## Show running containers
	docker compose ps

health: ## Check all services are up
	@echo "$(BLUE)▶ Health checks...$(RESET)"
	@curl -sf http://localhost:9090/-/healthy  && echo "$(GREEN)✓ Prometheus$(RESET)"    || echo "$(RED)✗ Prometheus$(RESET)"
	@curl -sf http://localhost:3000/api/health && echo "$(GREEN)✓ Grafana$(RESET)"       || echo "$(RED)✗ Grafana$(RESET)"
	@curl -sf http://localhost:9093/-/healthy  && echo "$(GREEN)✓ Alertmanager$(RESET)"  || echo "$(RED)✗ Alertmanager$(RESET)"
	@curl -sf http://localhost:9100/metrics    && echo "$(GREEN)✓ Node Exporter$(RESET)" || echo "$(RED)✗ Node Exporter$(RESET)"
	@curl -sf http://localhost:8080/healthz    && echo "$(GREEN)✓ cAdvisor$(RESET)"      || echo "$(RED)✗ cAdvisor$(RESET)"

reload: ## Hot-reload Prometheus config (no restart)
	@echo "$(YELLOW)▶ Reloading Prometheus config...$(RESET)"
	@curl -sf -X POST http://localhost:9090/-/reload && echo "$(GREEN)✓ Reloaded$(RESET)"

test-alert: ## Fire a test alert to Alertmanager
	./scripts/test-alert.sh

clean: ## Remove containers and volumes
	@echo "$(YELLOW)▶ Cleaning up...$(RESET)"
	docker compose down -v
	@echo "$(GREEN)✓ Done$(RESET)"
