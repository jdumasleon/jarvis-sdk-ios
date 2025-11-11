#!/bin/bash

# =============================================================================
# Jarvis iOS SDK Release Script
# =============================================================================
# This script automates the release process for both SPM and CocoaPods
#
# Usage:
#   ./scripts/publish.sh [version] [--skip-tests] [--skip-spm] [--skip-cocoapods]
#
# Example:
#   ./scripts/publish.sh 1.1.0
#   ./scripts/publish.sh 1.1.0 --skip-tests
#   ./scripts/publish.sh 1.1.0 --skip-cocoapods
#
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Files to update
PODSPEC_FILE="$PROJECT_ROOT/JarvisSDK.podspec"
PACKAGE_FILE="$PROJECT_ROOT/Package.swift"
README_FILE="$PROJECT_ROOT/README.md"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "${BLUE}===================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get current version from podspec
get_current_version() {
    if [ -f "$PODSPEC_FILE" ]; then
        grep -m 1 "spec.version" "$PODSPEC_FILE" | sed 's/.*"\(.*\)".*/\1/'
    else
        echo "0.0.0"
    fi
}

# Validate version format (semantic versioning)
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $1"
        print_info "Version must follow semantic versioning (e.g., 1.0.0)"
        exit 1
    fi
}

# Update version in podspec
update_podspec_version() {
    local version=$1
    if [ ! -f "$PODSPEC_FILE" ]; then
        print_warning "JarvisSDK.podspec not found. Skipping podspec version update."
        return
    fi

    print_info "Updating JarvisSDK.podspec to version $version..."
    sed -i '' "s/spec.version *= *\".*\"/spec.version = \"$version\"/" "$PODSPEC_FILE"
    print_success "Updated JarvisSDK.podspec"
}

# Update version in README
update_readme_version() {
    local version=$1
    print_info "Updating README.md to version $version..."

    # Update SPM dependency example
    sed -i '' "s/from: \"[0-9.]*\"/from: \"$version\"/" "$README_FILE" 2>/dev/null || true

    # Update CocoaPods example
    sed -i '' "s/pod 'JarvisSDK', '~> [0-9.]*'/pod 'JarvisSDK', '~> $version'/" "$README_FILE" 2>/dev/null || true

    print_success "Updated README.md"
}

# Run tests
run_tests() {
    print_header "Running Tests"

    print_info "Running Swift tests..."
    swift test || {
        print_error "Tests failed!"
        exit 1
    }

    print_success "All tests passed!"
}

# Build project
build_project() {
    print_header "Building Project"

    print_info "Building with Swift..."
    swift build || {
        print_error "Build failed!"
        exit 1
    }

    print_success "Build successful!"
}

# Validate podspec (usa el tag remoto)
validate_podspec() {
    print_header "Validating Podspec"

    if [ ! -f "$PODSPEC_FILE" ]; then
        print_warning "JarvisSDK.podspec not found. Skipping CocoaPods validation."
        return 0
    fi

    if ! command_exists pod; then
        print_warning "CocoaPods not installed. Skipping podspec validation."
        return 0
    fi

    print_info "Validating JarvisSDK.podspec..."
    pod spec lint "$PODSPEC_FILE" --allow-warnings || {
        print_error "Podspec validation failed!"
        print_info "Try: pod spec lint JarvisSDK.podspec --verbose --allow-warnings"
        exit 1
    }

    print_success "Podspec validation passed!"
}

# Create git tag (local)
create_git_tag() {
    local version=$1

    print_header "Creating Git Tag"

    # Check if tag already exists
    if git rev-parse "$version" >/dev/null 2>&1; then
        print_warning "Tag $version already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$version"
            git push origin ":refs/tags/$version" 2>/dev/null || true
            print_info "Deleted existing tag $version"
        else
            print_error "Release aborted"
            exit 1
        fi
    fi

    # Create tag
    print_info "Creating tag $version..."
    git tag -a "$version" -m "Release version $version"
    print_success "Created tag $version"
}

# Push changes (commits + tag)
push_changes() {
    local version=$1

    print_header "Pushing Changes"

    print_info "Pushing commits to origin..."
    git push origin main || git push origin master || {
        print_error "Failed to push to main/master branch"
        exit 1
    }

    print_info "Pushing tag $version to origin..."
    git push origin "$version"

    print_success "Pushed all changes to remote!"
}

# Publish to CocoaPods
publish_to_cocoapods() {
    print_header "Publishing to CocoaPods"

    if [ ! -f "$PODSPEC_FILE" ]; then
        print_warning "JarvisSDK.podspec not found. Skipping CocoaPods publication."
        return 0
    fi

    if ! command_exists pod; then
        print_warning "CocoaPods not installed. Skipping CocoaPods publishing."
        return 0
    fi

    print_info "Publishing to CocoaPods Trunk..."
    print_warning "This will make the release public!"
    read -p "Continue with CocoaPods publication? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipped CocoaPods publication"
        return 0
    fi

    pod trunk push "$PODSPEC_FILE" --allow-warnings || {
        print_error "CocoaPods publication failed!"
        print_info "You can retry manually: pod trunk push JarvisSDK.podspec --allow-warnings"
        exit 1
    }

    print_success "Published to CocoaPods!"
}

# Generate changelog (solo imprime commits)
generate_changelog() {
    local version=$1
    local previous_version=$(get_current_version)

    print_header "Generating Changelog"

    print_info "Changes since $previous_version:"
    echo ""

    if git rev-parse "$previous_version" >/dev/null 2>&1; then
        git log "$previous_version"..HEAD --pretty=format:"  - %s" --no-merges
    else
        git log --pretty=format:"  - %s" --no-merges --max-count=10
    fi

    echo ""
    echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    print_header "Jarvis iOS SDK Release Script"

    # Parse arguments
    VERSION=""
    SKIP_TESTS=false
    SKIP_SPM=false
    SKIP_COCOAPODS=false

    for arg in "$@"; do
        case $arg in
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --skip-spm)
                SKIP_SPM=true
                shift
                ;;
            --skip-cocoapods)
                SKIP_COCOAPODS=true
                shift
                ;;
            *)
                if [[ -z "$VERSION" ]]; then
                    VERSION=$arg
                fi
                shift
                ;;
        esac
    done

    if [ -z "$VERSION" ]; then
        print_error "Version number required!"
        echo ""
        echo "Usage: $0 [version] [options]"
        echo ""
        echo "Options:"
        echo "  --skip-tests       Skip running tests"
        echo "  --skip-spm         Skip SPM release steps"
        echo "  --skip-cocoapods   Skip CocoaPods publication"
        echo ""
        echo "Example: $0 1.1.0"
        exit 1
    fi

    validate_version "$VERSION"

    CURRENT_VERSION=$(get_current_version)
    print_info "Current version: $CURRENT_VERSION"
    print_info "New version: $VERSION"
    echo ""

    read -p "Continue with release? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Release aborted"
        exit 1
    fi

    cd "$PROJECT_ROOT" || exit 1

    if [[ -n $(git status -s) ]]; then
        print_warning "You have uncommitted changes:"
        git status -s
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Release aborted"
            exit 1
        fi
    fi

    generate_changelog "$VERSION"

    cd "$PROJECT_ROOT/JarvisSDK" || exit 1
    
    if [ "$SKIP_TESTS" = false ]; then
        run_tests
    else
        print_warning "Skipping tests (--skip-tests flag)"
    fi

    build_project

    print_header "Updating Version Files"
    update_podspec_version "$VERSION"
    update_readme_version "$VERSION"
    print_success "All version files updated!"

    print_header "Committing Changes"
    git add "$PODSPEC_FILE" "$README_FILE" 2>/dev/null || true
    git commit -m "Release version $VERSION

🤖 Generated by jdumas<jdumasleon@gmail.com>" || print_warning "No changes to commit"
    print_success "Changes committed!"

    # 🔁 NUEVO ORDEN: primero tag + push, luego lint y trunk

    # 1) Crear tag local
    create_git_tag "$VERSION"

    # 2) Push de commit + tag a origin (para que exista el tag 1.2.0 en GitHub)
    push_changes "$VERSION"

    # 3) Validar podspec contra el remoto (ya con tag)
    if [ "$SKIP_COCOAPODS" = false ]; then
        validate_podspec
    else
        print_warning "Skipping podspec validation (--skip-cocoapods flag)"
    fi

    # 4) Publicar en CocoaPods
    if [ "$SKIP_COCOAPODS" = false ]; then
        publish_to_cocoapods
    else
        print_warning "Skipping CocoaPods publication (--skip-cocoapods flag)"
    fi

    print_header "Release Complete!"
    print_success "Version $VERSION released successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Verify SPM: https://github.com/jdumasleon/jarvis-sdk-ios/releases"
    if [ "$SKIP_COCOAPODS" = false ]; then
        echo "  2. Verify CocoaPods: pod search JarvisSDK"
        echo "  3. Verify pod info: pod trunk info JarvisSDK"
    fi
    echo ""
    print_info "Changelog for release notes:"
    generate_changelog "$VERSION"
}

main "$@"
