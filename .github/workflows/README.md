# GitHub Actions Workflows

This directory contains automated CI/CD workflows for the Jarvis iOS SDK.

## Workflows

### 🔍 PR Checks (`pr-checks.yml`)

**Triggers:** When pull requests are opened, synchronized, or reopened against `main`

**Purpose:** Validates code quality and ensures builds work before merging

**Jobs:**

1. **Validate** - Validates PR title format for version bumping
2. **Build** - Compiles, tests, and creates build artifacts
3. **CodeQL** - Runs security analysis
4. **Preview** - Posts preview build comment on PR

**What it does:**
- ✅ Validates PR title (MAJOR|MINOR|PATCH prefix)
- ✅ Runs SwiftLint and SwiftFormat (when configured)
- ✅ Executes unit tests with code coverage
- ✅ Builds debug and release configurations
- ✅ Creates XCFramework
- ✅ Performs security scan with CodeQL
- ✅ Uploads build artifacts
- ✅ Comments on PR with download links

**Duration:** ~10-15 minutes

---

### 🚀 Release and Publish (`release.yml`)

**Triggers:** When pull requests are merged to `main`

**Purpose:** Automatically releases new SDK versions

**Jobs:**

1. **Release** - Creates release, publishes artifacts, and tags version
2. **Notify** - Sends notifications to analytics and communication channels

**What it does:**
- 🔢 Automatically determines version bump (MAJOR/MINOR/PATCH)
- 📝 Updates version in podspec and README
- 🧪 Runs tests to ensure stability
- 📦 Builds XCFramework
- 🔍 Validates podspec
- 🚀 Publishes to CocoaPods (if configured)
- 🏷️ Creates git tag and GitHub release
- 📋 Generates comprehensive release notes
- 📢 Sends notifications (PostHog, Sentry, Discord, Slack)

**Duration:** ~15-20 minutes

---

## Version Bumping

The workflows use PR title prefixes to determine version bumps:

- **`MAJOR:`** - Breaking changes (e.g., `MAJOR: Redesign API`)
  - Version: `1.2.3` → `2.0.0`
- **`MINOR:`** - New features, backward compatible (e.g., `MINOR: Add performance monitoring`)
  - Version: `1.2.3` → `1.3.0`
- **`PATCH:`** - Bug fixes, patches (e.g., `PATCH: Fix shake detection`)
  - Version: `1.2.3` → `1.2.4`
- **No prefix** - Defaults to PATCH

### Examples

```
✅ MAJOR: Remove deprecated API methods
✅ MINOR: Add UIKit integration support
✅ PATCH: Fix FAB not appearing on shake
✅ Fix memory leak (defaults to PATCH)
```

---

## Secrets & Variables

### Required Secrets

None required for basic functionality. Optional secrets for extended features:

| Secret | Purpose | Required |
|--------|---------|----------|
| `COCOAPODS_TRUNK_TOKEN` | Publish to CocoaPods | No |
| `SENTRY_AUTH_TOKEN` | Update Sentry releases | No |

### Optional Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `POSTHOG_PROJECT_API_KEY` | Analytics tracking | - |
| `SENTRY_ORG` | Sentry organization | - |
| `SENTRY_PROJECT` | Sentry project name | - |
| `DISCORD_WEBHOOK_URL` | Discord notifications | - |
| `SLACK_WEBHOOK_URL` | Slack notifications | - |

### Setting Secrets

1. Go to repository Settings
2. Navigate to Secrets and variables > Actions
3. Click "New repository secret"
4. Add secret name and value

---

## Usage Examples

### Creating a Release

**Step 1:** Create a PR with proper title prefix

```bash
# For a new feature
git checkout -b feature/performance-monitoring
# ... make changes ...
git commit -m "Add performance monitoring"
git push origin feature/performance-monitoring

# Create PR with title: "MINOR: Add performance monitoring"
```

**Step 2:** PR Checks run automatically
- Review the automated checks
- Fix any issues
- Download preview builds from PR comment

**Step 3:** Merge PR
- Once approved and checks pass, merge to `main`
- Release workflow runs automatically
- SDK is published with new version

**Step 4:** Verify Release
- Check GitHub Releases page
- Verify CocoaPods: `pod search JarvisSDK`
- Test installation in a project

### Testing Workflows Locally

You can test builds locally before pushing:

```bash
# Test build
cd JarvisSDK
swift test
swift build -c release

# Test XCFramework creation (macOS only)
xcodebuild archive \
  -scheme Jarvis \
  -destination 'generic/platform=iOS' \
  -archivePath './build/ios.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -scheme Jarvis \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath './build/ios-simulator.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework './build/ios.xcarchive/Products/Library/Frameworks/Jarvis.framework' \
  -framework './build/ios-simulator.xcarchive/Products/Library/Frameworks/Jarvis.framework' \
  -output './build/Jarvis.xcframework'
```

---

## Workflow Diagram

```
┌─────────────┐
│   PR Open   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│  🔍 PR Checks Workflow     │
├─────────────────────────────┤
│ • Validate PR title         │
│ • Run linters               │
│ • Run tests                 │
│ • Build debug/release       │
│ • Create XCFramework        │
│ • Security scan (CodeQL)    │
│ • Post preview comment      │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────┐
│ Review & Fix│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Merge PR   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│  🚀 Release Workflow       │
├─────────────────────────────┤
│ • Determine version bump    │
│ • Update version files      │
│ • Run tests                 │
│ • Build XCFramework         │
│ • Publish to CocoaPods      │
│ • Create git tag            │
│ • Create GitHub release     │
│ • Send notifications        │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────┐
│  Published  │
└─────────────┘
```

---

## Troubleshooting

### PR Checks Failing

**Build Errors:**
```bash
# Run locally to reproduce
cd JarvisSDK
swift build
swift test
```

**Linter Errors:**
```bash
swiftlint --strict
swiftformat --lint JarvisSDK/Sources
```

**XCFramework Creation Fails:**
- Ensure you're on macOS runner
- Check Xcode version compatibility
- Verify scheme exists and is shared

### Release Workflow Failing

**Version Update Fails:**
- Check `JarvisSDK.podspec` exists
- Verify version format in podspec: `spec.version = "1.2.3"`

**CocoaPods Push Fails:**
- Verify `COCOAPODS_TRUNK_TOKEN` is set
- Run locally: `pod trunk push JarvisSDK.podspec --allow-warnings`
- Check podspec validation: `pod spec lint JarvisSDK.podspec`

**Tag Already Exists:**
```bash
# Delete local and remote tag
git tag -d 1.2.3
git push origin :refs/tags/1.2.3

# Merge PR again to recreate
```

---

## Maintenance

### Updating Xcode Version

Edit both workflow files:

```yaml
- name: 🍎 Set up Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.4'  # Update this version
```

### Adding New Build Steps

Add to the `build` job in `pr-checks.yml`:

```yaml
- name: 🔍 Custom Check
  run: |
    # Your custom check here
    ./scripts/custom-check.sh
```

### Modifying Release Notes

Edit the release notes template in `release.yml`:

```bash
cat > release-notes.md << EOF
## 🚀 What's Changed
# Add custom sections here
EOF
```

---

## Best Practices

1. **Always prefix PRs** with version bump type (MAJOR|MINOR|PATCH)
2. **Review PR checks** before requesting review
3. **Test locally** before pushing to save CI minutes
4. **Use draft releases** for testing release process
5. **Monitor workflow runs** in the Actions tab
6. **Keep secrets secure** - never commit or log them

---

## Support

For workflow issues:
- Check [GitHub Actions documentation](https://docs.github.com/en/actions)
- Review workflow run logs in Actions tab
- Open an issue in the repository

---

**Last Updated:** 2024-11-10
