# Pointer App - Build & Test Commands
# Usage: make <target>

.PHONY: help run test test-unit test-e2e test-e2e-smoke test-e2e-core test-headless test-gate test-all build-android build-ios install-maestro

# Default target
help:
	@echo "Pointer App Commands"
	@echo "===================="
	@echo ""
	@echo "Development:"
	@echo "  make run              Run on connected device"
	@echo "  make run-web          Run on Chrome (quick testing)"
	@echo ""
	@echo "Testing:"
	@echo "  make test             Run unit tests (parallel)"
	@echo "  make test-e2e-smoke   Quick smoke test (~30s, needs device)"
	@echo "  make test-e2e-core    Core confidence flows (~3 min, needs device)"
	@echo "  make test-e2e         All Maestro E2E tests (needs device)"
	@echo "  make test-headless    Analyze + unit tests (no device needed)"
	@echo "  make test-gate        Full gate: headless + all E2E"
	@echo "  make test-all         Unit + E2E tests"
	@echo "  make test-golden      Golden visual tests (Mac only)"
	@echo ""
	@echo "Build:"
	@echo "  make build-android    Build debug APK"
	@echo "  make build-ios        Build iOS (simulator)"
	@echo "  make build-release    Build release APK + AAB"
	@echo ""
	@echo "E2E Setup:"
	@echo "  make install-maestro  Install Maestro CLI"
	@echo "  make install-app      Build & install APK on emulator"

# ============== Development ==============

run:
	flutter run

run-web:
	flutter run -d chrome

# ============== Testing ==============

test:
	flutter test --concurrency=8

test-golden:
	flutter test test/golden/

# Quick confidence check (~30s) — THE go-to command after every change
test-e2e-smoke:
	@echo "Running smoke test..."
	~/.maestro/bin/maestro test maestro/flows/00_smoke_test.yaml

# Core confidence flows — high-signal tests that catch real regressions
test-e2e-core:
	@echo "Running core E2E flows..."
	~/.maestro/bin/maestro test maestro/flows/00_smoke_test.yaml
	~/.maestro/bin/maestro test maestro/flows/01_navigation.yaml
	~/.maestro/bin/maestro test maestro/flows/04_home_interactions.yaml
	~/.maestro/bin/maestro test maestro/flows/11_zen_mode.yaml
	~/.maestro/bin/maestro test maestro/flows/12_save_favorites.yaml
	~/.maestro/bin/maestro test maestro/flows/20_inquiry_player.yaml
	~/.maestro/bin/maestro test maestro/flows/21_article_reader.yaml
	~/.maestro/bin/maestro test maestro/flows/25_favorites_to_library.yaml

# All Maestro E2E tests
test-e2e:
	@echo "Running all Maestro E2E tests..."
	~/.maestro/bin/maestro test maestro/flows/

# Headless tests (no device needed) — fast feedback on devdesk
test-headless:
	flutter analyze
	flutter test --concurrency=8

# Full gate: headless + E2E (needs device/emulator)
test-gate: test-headless test-e2e
	@echo "All gates passed!"

test-all: test test-e2e
	@echo "All tests complete!"

# ============== Build ==============

build-android:
	flutter build apk --debug

build-ios:
	flutter build ios --debug --simulator

build-release:
	flutter build apk --release
	flutter build appbundle --release

# ============== E2E Setup ==============

install-maestro:
	@which ~/.maestro/bin/maestro > /dev/null 2>&1 || curl -Ls "https://get.maestro.mobile.dev" | bash
	@echo "Maestro installed: $$(~/.maestro/bin/maestro --version)"

install-app: build-android
	@echo "Installing APK on connected device..."
	adb install -r build/app/outputs/flutter-apk/app-debug.apk
	@echo "App installed. Run 'make test-e2e' to test."

# ============== Combined Workflows ==============

# Full CI workflow: build, install, test
ci-android: build-android install-app test-e2e
	@echo "Android CI complete!"

# Pre-commit check
precommit: test
	flutter analyze
	@echo "Pre-commit checks passed!"
