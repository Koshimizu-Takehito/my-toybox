.PHONY: clean xcode-deep-clean help new-screen open setup sync lint lint-fix lint-strict format format-check fix fastlane-setup metadata-pull metadata-push metadata-precheck

# Auto-load local environment variables (e.g. ASC_KEY_ID, ASC_ISSUER_ID)
# from `.env` if present. `.env` is gitignored; copy `.env.template` to start.
ifneq (,$(wildcard .env))
include .env
export
endif

# ============================================================================
# Default target
# ============================================================================
help:
	@echo "Available commands:"
	@echo "  make open                          - Open project in Xcode"
	@echo "  make setup                         - Install Mint and dependencies"
	@echo "  make sync                          - Pull latest changes and update dependencies"
	@echo "  make new-screen                    - Create a new screen (interactive)"
	@echo "  make new-screen NAME=Foo           - Create a new screen named Foo"
	@echo "  make new-screen NAME=Foo SHADER=yes - With Metal shader"
	@echo "  make lint                          - Run SwiftLint"
	@echo "  make lint-fix                      - Run SwiftLint with auto-correction"
	@echo "  make lint-strict                   - Run SwiftLint treating warnings as errors (CI)"
	@echo "  make format                        - Format code with SwiftFormat"
	@echo "  make format-check                  - Check code formatting (no changes)"
	@echo "  make fix                           - Format and auto-fix all code"
	@echo "  make clean                         - Remove build artifacts"
	@echo ""
	@echo "System-wide (destructive):"
	@echo "  make xcode-deep-clean              - Wipe Xcode/Simulator caches"
	@echo ""
	@echo "App Store metadata (fastlane deliver):"
	@echo "  make fastlane-setup                - Install fastlane and download current metadata from ASC"
	@echo "  make metadata-pull                 - Pull latest metadata & screenshots from ASC"
	@echo "  make metadata-precheck             - Validate local metadata without uploading"
	@echo "  make metadata-push                 - Upload metadata, screenshots, and release notes to ASC"
	@echo ""
	@echo "Note: Metal shaders are automatically compiled by SPM plugins during build."

# ============================================================================
# Setup
# ============================================================================

setup: ## Install Mint (if needed) and dependencies via Mint
	@echo "📦 Checking Mint installation..."
	@if ! command -v mint >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			echo "🍺 Mint not found. Installing via Homebrew..."; \
			brew install mint; \
		else \
			echo "❌ Mint is not installed and Homebrew is not available."; \
			echo "   Please install Mint manually: https://github.com/yonaskolb/Mint"; \
			exit 1; \
		fi; \
	fi
	@echo "📦 Installing packages from Mintfile..."
	@mint bootstrap
	@echo "✅ Setup complete!"

sync: ## Pull latest changes and update all dependencies
	@echo "🔄 Pulling latest changes..."
	@git pull
	@echo "📦 Updating Mint packages..."
	@mint bootstrap
	@echo "📦 Resolving Swift packages..."
	@swift package --package-path Packages resolve
	@echo "✅ Sync complete!"

# ============================================================================
# Linting & Formatting
# ============================================================================

lint: ## Run SwiftLint
	@echo "🔍 Running SwiftLint..."
	@mint run swiftlint lint

lint-fix: ## Run SwiftLint with auto-correction
	@echo "🔧 Running SwiftLint auto-fix..."
	@mint run swiftlint lint --fix
	@echo "✅ Auto-fix complete!"

lint-strict: ## Run SwiftLint treating warnings as errors (for CI)
	@echo "🔍 Running SwiftLint (strict mode)..."
	@mint run swiftlint lint --strict

format: ## Format code with SwiftFormat
	@echo "✨ Formatting code..."
	@mint run swiftformat App/MyToybox Packages/Sources Packages/Tests Packages/Plugins
	@echo "✅ Formatting complete!"

format-check: ## Check code formatting (no changes)
	@echo "🔍 Checking code format..."
	@mint run swiftformat App/MyToybox Packages/Sources Packages/Tests Packages/Plugins --lint

fix: format lint-fix ## Format and auto-fix all code
	@echo "✅ All fixes applied!"

# ============================================================================
# Create a new screen
# ============================================================================
new-screen:
ifdef NAME
ifdef SHADER
	@./Scripts/new_screen.sh $(NAME) --shader
else
	@./Scripts/new_screen.sh $(NAME)
endif
else
	@./Scripts/new_screen.sh
endif

# ============================================================================
# Open project in Xcode
# ============================================================================
open:
	@xed .

# ============================================================================
# App Store metadata (fastlane deliver)
# ============================================================================

fastlane-setup: ## Install fastlane and pull current metadata from App Store Connect
	@command -v bundle >/dev/null 2>&1 || (echo "❌ bundler is missing. Run: gem install bundler" && exit 1)
	@echo "📦 Installing fastlane via bundler..."
	@bundle install
	@echo "🔐 Verifying App Store Connect API credentials..."
	@test -n "$$ASC_KEY_ID"    || (echo "❌ ASC_KEY_ID is not set"    && exit 1)
	@test -n "$$ASC_ISSUER_ID" || (echo "❌ ASC_ISSUER_ID is not set" && exit 1)
	@ls fastlane/AuthKey_*.p8 >/dev/null 2>&1 || (echo "❌ fastlane/AuthKey_<KEYID>.p8 not found" && exit 1)
	@echo "⬇️  Pulling current metadata & screenshots from App Store Connect..."
	@bundle exec fastlane pull
	@echo "✅ fastlane setup complete."

metadata-pull: ## Pull latest metadata & screenshots from App Store Connect
	@bundle exec fastlane pull

metadata-precheck: ## Validate local metadata without uploading
	@bundle exec fastlane precheck_metadata

metadata-push: ## Upload metadata, screenshots, and release notes (no binary)
	@bundle exec fastlane push

# ============================================================================
# Clean build artifacts
# ============================================================================
clean: ## Remove project-scoped build artifacts (DerivedData prefix + Packages/.build)
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf ~/Library/Developer/Xcode/DerivedData/MyToybox-*
	@rm -rf Packages/.build
	@echo "✅ Clean complete"

xcode-deep-clean: ## Wipe Xcode/Simulator caches machine-wide (destructive; affects all projects)
	@echo "🧹 Deep-cleaning Xcode/Simulator caches (machine-wide)..."
	@./Scripts/xcode_deep_clean.sh
