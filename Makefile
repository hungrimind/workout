# Variables
FLUTTER_VERSION := 3.29.0
PROJECT_DIRS := $(shell find . -maxdepth 1 -type d -not -path "*/\.*" -not -path "./_initial" -not -path "." -exec test -f '{}/pubspec.yaml' \; -print)

# Local development commands
.PHONY: get-all
get-all:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Getting dependencies for $$d ==="; \
		cd $$d && flutter pub get && cd -; \
	done

.PHONY: test-all
test-all:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Testing $$d ==="; \
		cd $$d && flutter test --exclude-tags=golden && cd -; \
	done

.PHONY: format
format:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Formatting $$d ==="; \
		cd $$d && dart format lib test && cd -; \
	done

.PHONY: format-check
format-check:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Checking format for $$d ==="; \
		cd $$d && dart format $$(find lib -name "*.dart" -not \( -name "*.*freezed.dart" -o -name "*.*g.dart" \) ) --set-exit-if-changed && cd -; \
	done

.PHONY: analyze-all
analyze-all:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Analyzing $$d ==="; \
		cd $$d && dart analyze . --no-fatal-warnings && cd -; \
	done

.PHONY: build-web-all
build-web-all:
	@for d in $(PROJECT_DIRS); do \
		echo "=== Building web for $$d ==="; \
		cd $$d && flutter build web && cd -; \
	done

# Individual project commands
.PHONY: get-project
get-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make get-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Getting dependencies for $(PROJECT) ==="; 
	@cd $(PROJECT) && flutter pub get

.PHONY: format-project
format-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make format-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Formatting $(PROJECT) ==="; 
	@cd $(PROJECT) && dart format lib test

.PHONY: format-check-project
format-check-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make format-check-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Checking format for $(PROJECT) ==="; 
	@cd $(PROJECT) && dart format $$(find lib -name "*.dart" -not \( -name "*.*freezed.dart" -o -name "*.*g.dart" \) ) --set-exit-if-changed

.PHONY: analyze-project
analyze-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make analyze-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Analyzing $(PROJECT) ==="; 
	@cd $(PROJECT) && dart analyze . --no-fatal-warnings

.PHONY: test-project
test-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make test-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Testing $(PROJECT) ==="; 
	@cd $(PROJECT) && flutter test --exclude-tags=golden

.PHONY: build-web-project
build-web-project:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Error: PROJECT parameter is required. Usage: make build-web-project PROJECT=<project_dir>"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROJECT)" ] || [ ! -f "$(PROJECT)/pubspec.yaml" ]; then \
		echo "Error: $(PROJECT) is not a valid Flutter/Dart project directory"; \
		exit 1; \
	fi
	@echo "=== Building web for $(PROJECT) ==="; 
	@cd $(PROJECT) && flutter build web

# CI commands for individual projects
.PHONY: ci-lint-project
ci-lint-project: get-project analyze-project format-check-project

.PHONY: ci-test-project
ci-test-project: get-project test-project

.PHONY: ci-build-project
ci-build-project: get-project build-web-project

# CI commands
.PHONY: ci-lint
ci-lint: get-all analyze-all format-check

.PHONY: ci-test
ci-test: get-all test-all

.PHONY: ci-build
ci-build: get-all build-web-all

# Run all checks (useful for pre-commit)
.PHONY: check-all
check-all: get-all format analyze-all test-all

# Help command
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make get-all          - Get dependencies for all projects"
	@echo "  make test-all         - Run tests for all projects"
	@echo "  make format           - Format code in all projects"
	@echo "  make format-check     - Check if code is properly formatted (used in CI)"
	@echo "  make analyze-all      - Analyze code in all projects"
	@echo "  make build-web-all    - Build web for all projects"
	@echo "  make ci-lint          - Run all lint-related checks (used in CI)"
	@echo "  make ci-test          - Run all tests (used in CI)"
	@echo "  make check-all        - Run all checks locally"
	@echo "  make help             - Show this help message"
	@echo ""
	@echo "Individual project commands:"
	@echo "  make get-project PROJECT=<dir>          - Get dependencies for a specific project"
	@echo "  make test-project PROJECT=<dir>         - Run tests for a specific project"
	@echo "  make format-project PROJECT=<dir>       - Format code in a specific project"
	@echo "  make format-check-project PROJECT=<dir> - Check if code is properly formatted in a specific project"
	@echo "  make analyze-project PROJECT=<dir>      - Analyze code in a specific project"
	@echo "  make build-web-project PROJECT=<dir>    - Build web for a specific project"
	@echo "  make ci-lint-project PROJECT=<dir>      - Run lint-related checks for a specific project"
	@echo "  make ci-test-project PROJECT=<dir>      - Run tests for a specific project"
	@echo "  make ci-build-project PROJECT=<dir>     - Build web for a specific project"