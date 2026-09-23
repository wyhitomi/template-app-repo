# =============================================================================
# Makefile - the single, stack-agnostic interface for humans AND CI.
# Workflows only call `make <target>`, so swapping the app stack means editing
# the recipes below, never the pipelines.
# =============================================================================
SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

# --- Project -----------------------------------------------------------------
APP_NAME    ?= template-app
REGISTRY    ?= ghcr.io
IMAGE_REPO  ?= $(REGISTRY)/$(shell git config --get remote.origin.url 2>/dev/null | sed -E 's#(.*github.com[:/])##; s#\.git$$##' | tr '[:upper:]' '[:lower:]')
GIT_SHA     ?= $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
IMAGE_TAG   ?= sha-$(shell git rev-parse HEAD 2>/dev/null || echo unknown)
IMAGE       ?= $(APP_NAME):local

# --- Environments ------------------------------------------------------------
ENV         ?= dev
ENVS        := dev stg prd
BASE_URL    ?= http://localhost:8080
TG_DIR      := infra/live/$(ENV)
CHART_DIR   := infra/deploy/helm/app
NAMESPACE   ?= $(APP_NAME)-$(ENV)

COMPOSE     := docker compose
UP_FLAGS    ?= --build
K6_IMAGE    ?= grafana/k6:2.3.0
PYTHON      ?= python3

export APP_NAME IMAGE VERSION GIT_SHA BASE_URL

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m [VAR=value]\n"} \
	  /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } \
	  /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Setup
.PHONY: setup
setup: ## Install git hooks and create .env
	@command -v pre-commit >/dev/null || $(PYTHON) -m pip install --user pre-commit
	pre-commit install --install-hooks
	@[ -f .env ] || cp .env.example .env

##@ Quality
.PHONY: lint
lint: ## Run all pre-commit hooks on every file
	pre-commit run --all-files --show-diff-on-failure

.PHONY: fmt
fmt: ## Format code and IaC
	-pre-commit run ruff-format --all-files
	-pre-commit run terraform_fmt --all-files
	-pre-commit run terragrunt-hcl-fmt --all-files

##@ Build & unit test
.PHONY: build
build: ## Build/package the application (stack-specific; sample: byte-compile)
	$(PYTHON) -m compileall -q app/src

.PHONY: image
image: ## Build the application container image locally
	docker build -f app/Dockerfile \
	  --build-arg VERSION=$(VERSION) --build-arg GIT_SHA=$(GIT_SHA) \
	  -t $(IMAGE) .

.PHONY: test
test: ## Run unit tests
	cd app && PYTHONPATH=src $(PYTHON) -m unittest discover -s tests -v

##@ Local stack
.PHONY: up
up: ## Start the local stack (CI sets UP_FLAGS to run a pre-built IMAGE)
	$(COMPOSE) up -d --wait $(UP_FLAGS) app

.PHONY: down
down: ## Stop the local stack and remove volumes
	$(COMPOSE) down -v --remove-orphans

.PHONY: logs
logs: ## Tail stack logs
	$(COMPOSE) logs -f

##@ Post-merge suites - target BASE_URL (default: local stack from `make up`)
.PHONY: test-integration
test-integration: ## Run integration tests against BASE_URL
	$(PYTHON) -m unittest discover -s tests/integration -v

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests against BASE_URL
	$(PYTHON) -m unittest discover -s tests/e2e -v

.PHONY: test-perf
test-perf: ## Run k6 load test against BASE_URL (SLO thresholds gate the result)
	@mkdir -p reports
	docker run --rm --network host -u "$$(id -u):$$(id -g)" -e BASE_URL \
	  -v "$(CURDIR)/tests/performance:/scripts:ro" -v "$(CURDIR)/reports:/reports" \
	  $(K6_IMAGE) run --summary-export=/reports/k6-summary.json /scripts/load.js

##@ Infrastructure (Terragrunt) - ENV=dev|stg|prd
.PHONY: tf-check-env
tf-check-env:
	@echo " $(ENVS) " | grep -q " $(ENV) " || { echo "ENV must be one of: $(ENVS)"; exit 1; }

.PHONY: tf-validate
tf-validate: tf-check-env ## terragrunt validate for ENV
	cd $(TG_DIR) && terragrunt run --all --non-interactive -- validate

.PHONY: tf-plan
tf-plan: tf-check-env ## terragrunt plan for ENV
	cd $(TG_DIR) && terragrunt run --all --non-interactive -- plan -input=false

.PHONY: tf-apply
tf-apply: tf-check-env ## terragrunt apply for ENV
	cd $(TG_DIR) && terragrunt run --all --non-interactive -- apply -input=false -auto-approve

##@ Deployment (Helm) - ENV=dev|stg|prd IMAGE_TAG=<tag>
.PHONY: deploy
deploy: tf-check-env ## Deploy IMAGE_REPO:IMAGE_TAG to ENV
	helm upgrade --install $(APP_NAME) $(CHART_DIR) \
	  --namespace $(NAMESPACE) --create-namespace \
	  -f $(CHART_DIR)/values.yaml -f $(CHART_DIR)/values-$(ENV).yaml \
	  --set image.repository=$(IMAGE_REPO) --set image.tag=$(IMAGE_TAG) \
	  --atomic --wait --timeout 10m

.PHONY: deploy-diff
deploy-diff: tf-check-env ## Render manifests for ENV without applying
	helm template $(APP_NAME) $(CHART_DIR) --namespace $(NAMESPACE) \
	  -f $(CHART_DIR)/values.yaml -f $(CHART_DIR)/values-$(ENV).yaml \
	  --set image.repository=$(IMAGE_REPO) --set image.tag=$(IMAGE_TAG)

.PHONY: rollback
rollback: tf-check-env ## Roll back the last Helm release in ENV
	helm rollback $(APP_NAME) --namespace $(NAMESPACE) --wait

##@ Housekeeping
.PHONY: clean
clean: down ## Remove build/test artefacts
	rm -rf reports dist build .pytest_cache
	find . -type d \( -name __pycache__ -o -name .terragrunt-cache \) -prune -exec rm -rf {} +
