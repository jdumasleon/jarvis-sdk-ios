# Jarvis iOS SDK Scripts

This directory contains automation scripts for releasing and publishing the Jarvis iOS SDK.

## Scripts

### `release.sh` - Automated Release Script

Automates the complete release process for both Swift Package Manager (SPM) and CocoaPods.

#### Features

- ✅ Version validation (semantic versioning)
- ✅ Automated version updates (podspec, README)
- ✅ Test execution
- ✅ Build verification
- ✅ Podspec validation
- ✅ Git tagging
- ✅ Remote push (commits + tags)
- ✅ CocoaPods trunk publication
- ✅ Changelog generation

#### Usage

```bash
# Basic release
./scripts/release.sh 1.1.0

# Skip tests (use for hotfixes)
./scripts/release.sh 1.1.0 --skip-tests

# Skip CocoaPods publication (SPM only)
./scripts/release.sh 1.1.0 --skip-cocoapods

# Dry run (skip both tests and CocoaPods)
./scripts/release.sh 1.1.0 --skip-tests --skip-cocoapods
```

#### Options

- `--skip-tests`: Skip running tests (not recommended)
- `--skip-spm`: Skip SPM-specific steps
- `--skip-cocoapods`: Skip CocoaPods publication

#### Process Flow

1. **Validation**
   - Validates semantic versioning format
   - Checks for uncommitted changes
   - Confirms release with user

2. **Testing & Building**
   - Runs `swift test`
   - Runs `swift build`
   - Validates build succeeds

3. **Version Updates**
   - Updates `JarvisSDK.podspec`
   - Updates `README.md`
   - Commits changes

4. **Pod Validation**
   - Runs `pod spec lint`
   - Ensures podspec is valid

5. **Git Operations**
   - Creates annotated git tag
   - Pushes commits to main/master
   - Pushes tag to remote

6. **Publication**
   - Publishes to CocoaPods Trunk (if not skipped)
   - Generates changelog for release notes

#### Prerequisites

**Required:**
- Git configured with remote access
- Swift toolchain installed
- Write access to the repository

**Optional (for CocoaPods):**
- CocoaPods installed (`sudo gem install cocoapods`)
- CocoaPods Trunk account (`pod trunk register`)

#### Example Output

```
===================================================================
Jarvis iOS SDK Release Script
===================================================================
ℹ Current version: 1.0.0
ℹ New version: 1.1.0

Continue with release? (y/N): y

===================================================================
Generating Changelog
===================================================================
ℹ Changes since 1.0.0:

  - Add PerformanceOverviewChart to dashboard
  - Integrate performance monitoring with SDK lifecycle
  - Create release automation scripts

===================================================================
Running Tests
===================================================================
ℹ Running Swift tests...
✓ All tests passed!

===================================================================
Building Project
===================================================================
ℹ Building with Swift...
✓ Build successful!

===================================================================
Updating Version Files
===================================================================
ℹ Updating JarvisSDK.podspec to version 1.1.0...
✓ Updated JarvisSDK.podspec
ℹ Updating README.md to version 1.1.0...
✓ Updated README.md
✓ All version files updated!

===================================================================
Committing Changes
===================================================================
✓ Changes committed!

===================================================================
Validating Podspec
===================================================================
ℹ Validating JarvisSDK.podspec...
✓ Podspec validation passed!

===================================================================
Creating Git Tag
===================================================================
ℹ Creating tag 1.1.0...
✓ Created tag 1.1.0

===================================================================
Pushing Changes
===================================================================
ℹ Pushing commits to origin...
ℹ Pushing tag 1.1.0 to origin...
✓ Pushed all changes to remote!

===================================================================
Publishing to CocoaPods
===================================================================
ℹ Publishing to CocoaPods Trunk...
⚠ This will make the release public!
Continue with CocoaPods publication? (y/N): y
✓ Published to CocoaPods!

===================================================================
Release Complete!
===================================================================
✓ Version 1.1.0 released successfully!

ℹ Next steps:
  1. Verify SPM: https://github.com/jdumasleon/jarvis-ios-sdk/releases
  2. Verify CocoaPods: pod search JarvisSDK
  3. Verify pod info: pod trunk info JarvisSDK
```

## Manual Release Process

If you prefer to release manually, follow these steps:

### 1. Update Version Numbers

```bash
# Update JarvisSDK.podspec
sed -i '' 's/spec.version = ".*"/spec.version = "1.1.0"/' JarvisSDK.podspec

# Update README.md examples
sed -i '' 's/from: "[0-9.]*"/from: "1.1.0"/' README.md
sed -i '' "s/pod 'JarvisSDK', '~> [0-9.]*'/pod 'JarvisSDK', '~> 1.1.0'/" README.md
```

### 2. Run Tests

```bash
swift test
```

### 3. Validate Build

```bash
swift build
```

### 4. Validate Podspec

```bash
pod spec lint JarvisSDK.podspec --allow-warnings
```

### 5. Commit & Tag

```bash
git add JarvisSDK.podspec README.md
git commit -m "Release version 1.1.0"
git tag -a 1.1.0 -m "Release version 1.1.0"
```

### 6. Push

```bash
git push origin main  # or master
git push origin 1.1.0
```

### 7. Publish to CocoaPods

```bash
pod trunk push JarvisSDK.podspec --allow-warnings
```

### 8. Create GitHub Release

1. Go to https://github.com/jdumasleon/jarvis-ios-sdk/releases
2. Click "Draft a new release"
3. Select tag `1.1.0`
4. Add release notes from changelog
5. Publish release

## Troubleshooting

### "Tag already exists"

```bash
# Delete local tag
git tag -d 1.1.0

# Delete remote tag
git push origin :refs/tags/1.1.0

# Re-run release script
./scripts/release.sh 1.1.0
```

### "Podspec validation failed"

```bash
# Run with verbose output
pod spec lint JarvisSDK.podspec --verbose --allow-warnings

# Common issues:
# - Invalid source URL
# - Missing files
# - Incorrect dependencies
```

### "Tests failed"

```bash
# Run tests with verbose output
swift test --verbose

# Skip tests if hotfix
./scripts/release.sh 1.1.0 --skip-tests
```

### "CocoaPods Trunk not registered"

```bash
# Register your email
pod trunk register your-email@example.com 'Your Name'

# Check registration
pod trunk me
```

## Best Practices

1. **Always test before release**
   ```bash
   swift test && swift build
   ```

2. **Follow semantic versioning**
   - MAJOR.MINOR.PATCH (e.g., 1.0.0)
   - MAJOR: Breaking changes
   - MINOR: New features, backward compatible
   - PATCH: Bug fixes, backward compatible

3. **Write meaningful commit messages**
   ```
   Release version 1.1.0

   - Feature: Add performance monitoring
   - Feature: Integrate with SDK lifecycle
   - Improvement: Add release automation
   ```

4. **Update CHANGELOG.md**
   - Document all changes
   - Organize by type (Added, Changed, Fixed, Removed)
   - Include migration notes for breaking changes

5. **Test the release**
   ```bash
   # Test SPM installation
   swift package resolve

   # Test CocoaPods installation
   pod install --project-directory=TestApp
   ```

## CI/CD Integration

The release script can be integrated into GitHub Actions or other CI/CD systems:

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to release (e.g., 1.1.0)'
        required: true

jobs:
  release:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Swift
        uses: swift-actions/setup-swift@v1

      - name: Release
        env:
          COCOAPODS_TRUNK_TOKEN: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}
        run: |
          ./scripts/release.sh ${{ github.event.inputs.version }}
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/jdumasleon/jarvis-ios-sdk/issues
- Email: jdumasleon@gmail.com

---

**Last Updated**: November 9, 2025
