# Makefile for iOS SDK linting and formatting

# Variables
SWIFT_FORMAT_VERSION = 0.53.8
SWIFT_LINT_VERSION = 0.54.0
PERIPHERY_VERSION = 2.17.0

# Default target
.PHONY: all
all: install-tools lint format

# Install required tools
.PHONY: install-tools
install-tools:
	@echo "Installing SwiftLint..."
	@if ! command -v swiftlint &> /dev/null; then \
		echo "SwiftLint not found. Installing via Homebrew..."; \
		brew install swiftlint; \
	else \
		echo "SwiftLint is already installed"; \
	fi
	
	@echo "Installing SwiftFormat..."
	@if ! command -v swiftformat &> /dev/null; then \
		echo "SwiftFormat not found. Installing via Homebrew..."; \
		brew install swiftformat; \
	else \
		echo "SwiftFormat is already installed"; \
	fi
	
	@echo "Installing Periphery..."
	@if ! command -v periphery &> /dev/null; then \
		echo "Periphery not found. Installing via Homebrew..."; \
		brew install peripheryapp/periphery/periphery; \
	else \
		echo "Periphery is already installed"; \
	fi

# Lint code with SwiftLint
.PHONY: lint
lint:
	@echo "Running SwiftLint..."
	@swiftlint lint --config .swiftlint.yml

# Auto-fix linting issues
.PHONY: lint-fix
lint-fix:
	@echo "Running SwiftLint with auto-fix..."
	@swiftlint lint --config .swiftlint.yml --fix

# Format code with SwiftFormat
.PHONY: format
format:
	@echo "Running SwiftFormat..."
	@swiftformat --config .swiftformat Sources

# Check formatting without making changes
.PHONY: format-check
format-check:
	@echo "Checking code formatting..."
	@swiftformat --config .swiftformat Sources --lint

# Run Periphery to detect dead code
.PHONY: periphery
periphery:
	@echo "Running Periphery to detect dead code..."
	@periphery scan --config .periphery.yml

# Run all quality checks
.PHONY: check
check: lint format-check periphery

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf .swiftpm
	@rm -rf DerivedData

# Build the package
.PHONY: build
build:
	@echo "Building Swift package..."
	@swift build

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@swift test

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "Running tests with coverage..."
	@swift test --enable-code-coverage

# Full CI workflow
.PHONY: ci
ci: install-tools build test check

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all          - Install tools, lint, and format"
	@echo "  install-tools - Install SwiftLint, SwiftFormat, and Periphery"
	@echo "  lint         - Run SwiftLint"
	@echo "  lint-fix     - Run SwiftLint with auto-fix"
	@echo "  format       - Format code with SwiftFormat"
	@echo "  format-check - Check formatting without making changes"
	@echo "  periphery    - Run Periphery to detect dead code"
	@echo "  check        - Run all quality checks"
	@echo "  build        - Build the Swift package"
	@echo "  test         - Run tests"
	@echo "  test-coverage - Run tests with coverage"
	@echo "  clean        - Clean build artifacts"
	@echo "  ci           - Full CI workflow"
	@echo "  help         - Show this help message"