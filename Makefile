.PHONY: help build clean update server server-debug stop docker-up docker-down docker-logs lint test validate

# Colors for help output
BLUE = \033[1;34m
RESET = \033[0m

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "$(BLUE)Ullama Build System$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Build Targets ---

build: ## Build llama.cpp from source
	./scripts/update_llama_cpp.sh

clean: ## Clean build artifacts
	rm -rf ~/workspace/machine-learning/llama.cpp/build

update: ## Update and rebuild llama.cpp
	./scripts/update_llama_cpp.sh

# --- Run Targets ---

server: ## Start llama-server with router
	./scripts/run-server.sh

server-debug: ## Start with debug logging
	./scripts/run-server.sh --log-colors on

stop: ## Stop running services (tmux session)
	./scripts/stop-server-tmux.sh

# --- Docker Targets ---

docker-up: ## Start docker-compose services
	docker-compose up -d

docker-down: ## Stop docker-compose services
	docker-compose down

docker-logs: ## View service logs
	docker-compose logs -f openwebui

# --- Maintenance Targets ---

lint: ## Lint all shell scripts
	find scripts/ -name "*.sh" -exec shellcheck {} +

test: ## Test script syntax
	bash -n scripts/*.sh

validate: ## Full validation pipeline
	bash -n scripts/*.sh && find scripts/ -name "*.sh" -exec shellcheck {} +
