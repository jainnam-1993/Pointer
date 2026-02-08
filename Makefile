# Pointer App - Build & Test Commands
# Usage: make <target>

.PHONY: help run test test-unit test-e2e test-all build-android build-ios install-maestro

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
	@echo "  make test-e2e         Run Maestro E2E tests"
	@echo "  make test-e2e-smoke   Run quick smoke test only (~30s)"
	@echo "  make test-all         Run unit + E2E tests"
	@echo "  make test-golden      Run golden visual tests"
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

test-e2e-smoke:
	@echo "Running Maestro smoke test..."
	~/.maestro/bin/maestro test maestro/flows/00_smoke_test.yaml

test-e2e:
	@echo "Running all Maestro E2E tests..."
	~/.maestro/bin/maestro test maestro/flows/

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
