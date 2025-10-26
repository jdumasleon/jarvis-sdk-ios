# iOS Preferences Architecture - Live Scanning & Management

## TL;DR - What You Need to Know

**The iOS SDK can scan, view, edit, and delete ALL host app preferences with ZERO configuration!**

Unlike Android (which needs Proto extractors), iOS can:
- ✅ Scan all UserDefaults suites automatically (scans .plist files)
- ✅ Scan all Keychain items automatically (queries SecItemCopyMatching)
- ✅ **Edit preferences in real-time** from SDK UI
- ✅ **Delete preferences** from SDK UI
- ✅ **NO registration required** - everything works out of the box!

**Configuration is OPTIONAL** - only needed for:
1. Privacy: Hide specific suites/services (exclude lists)
2. Performance: Scan only specific suites/services (include lists)
3. UI preferences: Show/hide system keys

---

## Architecture Overview

### Scanner-Based Live System (Current Implementation)

The SDK uses a **scanner-based architecture** for live preference management:

```
┌─────────────────────────────────────────┐
│         DEMO APP (Host App)             │
│                                         │
│  DemoUserDefaultsManager                │
│  └── Uses UserDefaults normally         │
│      (no SDK-specific code!)            │
│                                         │
│  DemoKeychainManager                    │
│  └── Uses Keychain normally             │
│      (no SDK-specific code!)            │
└─────────────────────────────────────────┘

              ↓ (automatic scanning)

┌─────────────────────────────────────────┐
│          JARVIS SDK                     │
│                                         │
│  1. UserDefaultsScanner                 │
│     → Scans Library/Preferences/*.plist │
│     → Returns AppPreference list        │
│                                         │
│  2. KeychainScanner                     │
│     → Queries SecItemCopyMatching       │
│     → Returns AppPreference list        │
│                                         │
│  3. HostAppPreferenceRepository         │
│     → Combines scanners                 │
│     → Provides edit/delete APIs         │
│                                         │
│  4. SDK UI (PreferencesListView)        │
│     → Display preferences               │
│     → Edit button → updatePreference()  │
│     → Delete button → deletePreference()│
└─────────────────────────────────────────┘
```

---

## How It Works (2 Simple Approaches)

### Approach 1: ZERO Configuration (Recommended for Most Apps)

**Demo App Does:** Nothing! Just use preferences normally.

```swift
// Demo app just uses UserDefaults normally
let defaults = UserDefaults(suiteName: "com.jarvis.demo.prefs")
defaults.set("value", forKey: "key")
```

**SDK Does:** Auto-discovers everything automatically!

```swift
// SDK automatically finds ALL preferences
let repository = HostAppPreferenceRepository()
let allPreferences = repository.scanAllPreferences()
// Returns: ALL UserDefaults from ALL suites + ALL Keychain items

// Edit a preference
repository.updatePreference(
    key: "key",
    value: "new_value",
    source: .userDefaults,
    suiteName: "com.jarvis.demo.prefs"
)

// Delete a preference
repository.deletePreference(
    key: "key",
    source: .userDefaults,
    suiteName: "com.jarvis.demo.prefs"
)
```

**How:**
1. Scans `Library/Preferences/*.plist` → gets all UserDefaults
2. Queries `SecItemCopyMatching` → gets all Keychain items
3. Provides edit/delete APIs for live management
4. Done!

**When to use:** 99% of apps. Just works with zero config.

---

### Approach 2: Filter with Configuration (For Privacy/Performance)

**Demo App Does:** Configure what SDK can see.

```swift
let config = PreferencesConfiguration(
    autoDiscoverUserDefaults: true,
    excludeUserDefaultsSuites: ["private_data"], // Hide this suite
    autoDiscoverKeychain: false, // Don't scan keychain
    enablePreferenceEditing: true // Allow editing from SDK
)
```

**SDK Does:** Respects the filters.

**When to use:**
- Hide sensitive data from SDK
- Improve performance by excluding large suites
- Control what appears in SDK UI
- Disable editing for production builds

---

## Why Android Needs More Configuration

### Android's Proto DataStore Problem:

```kotlin
// Android Proto DataStore
@Serializable
data class UserSettings(
    val username: String,
    val isPremium: Boolean,
    val theme: String
)

// File on disk: user_settings.pb (binary proto)
// SDK sees: [binary blob] ❌ Can't read!

// NEED: Extractor function
protoExtractors = mapOf(
    "user_settings" to { userSettings: UserSettings ->
        mapOf(
            "username" to userSettings.username,
            "isPremium" to userSettings.isPremium,
            "theme" to userSettings.theme
        )
    }
)
```

### iOS Doesn't Have This Problem:

```swift
// iOS UserDefaults
let defaults = UserDefaults(suiteName: "com.jarvis.demo.prefs")
defaults.set("John", forKey: "username")
defaults.set(true, forKey: "isPremium")
defaults.set("dark", forKey: "theme")

// File on disk: com.jarvis.demo.prefs.plist (XML/Binary plist)
// SDK reads:
// - username: John ✅
// - isPremium: true ✅
// - theme: dark ✅
// No extractor needed!

// SDK can also edit:
defaults.set("Jane", forKey: "username") ✅
defaults.removeObject(forKey: "username") ✅
```

**Why:**
- UserDefaults are **already key-value pairs**
- Plist format is standard (like XML/JSON)
- iOS provides `dictionaryRepresentation()` to read everything
- iOS provides `set()` and `removeObject()` for editing

---

## Layer-by-Layer Breakdown

### Domain Layer

**Entities:**
- `AppPreference` - Model for scanned preference
  - id, key, value, type, source, suiteName, timestamp

- `PreferenceSource` - Enum
  - userDefaults, keychain, propertyList

**Use Cases:**
- `GetHostAppPreferencesUseCase` - Scan and return preferences
- `UpdateHostAppPreferenceUseCase` - Update a preference value
- `DeleteHostAppPreferenceUseCase` - Delete a preference

**Repository Protocol:**
- `HostAppPreferenceRepositoryProtocol`
  - scanAllPreferences()
  - getPreferences(by source)
  - updatePreference()
  - deletePreference()
  - refresh()

**Configuration:**
- `PreferencesConfiguration` - Filtering/privacy controls
- `PreferencesConfigProvider` - Configuration provider protocol

---

### Data Layer

**Scanners:**
- `UserDefaultsScanner`
  - Scans Library/Preferences/*.plist files
  - Extracts preferences using dictionaryRepresentation()
  - Filters based on include/exclude lists

- `KeychainScanner`
  - Queries SecItemCopyMatching for all items
  - Extracts service/account/data
  - Filters based on include/exclude lists

**Services:**
- `HostAppPreferenceScanner`
  - Coordinates UserDefaultsScanner + KeychainScanner
  - Combines results into single list

**Repository:**
- `HostAppPreferenceRepository`
  - Implements HostAppPreferenceRepositoryProtocol
  - Uses scanners for reading
  - Uses UserDefaults.set() / SecItemAdd for editing
  - Uses UserDefaults.removeObject() / SecItemDelete for deleting

---

### Presentation Layer

**ViewModels:**
- `PreferencesViewModel`
  - Uses GetHostAppPreferencesUseCase
  - Uses UpdateHostAppPreferenceUseCase
  - Uses DeleteHostAppPreferenceUseCase
  - Manages UI state (loading, loaded, empty, error)
  - Handles filtering (All, UserDefaults, Keychain)

- `AppPreferenceViewModel`
  - Wraps AppPreference for UI display
  - Provides displayTitle, displaySubtitle, displayValue

**Views:**
- `PreferencesListView`
  - SwiftUI view with filter segments
  - Displays list of preferences
  - Refresh button to rescan
  - Empty/error states

- `PreferenceRowView`
  - Displays preference key, value, type
  - Delete button for each row
  - Edit capability (future: inline editing)

---

## Recommended Implementation (Simplest)

### For Demo App:

**Just use preferences normally - NO SDK-specific code needed!**

```swift
// DemoUserDefaultsManager.swift
class DemoUserDefaultsManager {
    private let demoPrefs = UserDefaults(suiteName: "com.jarvis.demo.prefs")!

    func setUserName(_ name: String) {
        demoPrefs.set(name, forKey: "user_name")
    }
}

// That's it! SDK will find it automatically and allow editing.
```

### For SDK:

**Use default auto-discovery:**

```swift
// JarvisSDK automatically scans everything
let repository = HostAppPreferenceRepository()
let preferences = repository.scanAllPreferences()

// Edit a preference
repository.updatePreference(
    key: "user_name",
    value: "Jane",
    source: .userDefaults,
    suiteName: "com.jarvis.demo.prefs"
)

// Delete a preference
repository.deletePreference(
    key: "user_name",
    source: .userDefaults,
    suiteName: "com.jarvis.demo.prefs"
)
```

### For JarvisDemo App (if you want to show users how to configure):

```swift
@main
struct JarvisDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(config: JarvisConfig(
                    preferences: PreferencesConfig(
                        // Auto-discover everything (default)
                        configuration: .default
                    )
                ))
        }
    }
}

// No registration needed!
```

---

## What's Included (Clean Implementation)

### Demo App (Independent from SDK):

1. ✅ **DemoUserDefaultsManager** - Demo app's own UserDefaults manager (4 suites)
2. ✅ **DemoKeychainManager** - Demo app's own Keychain manager
3. ✅ **DemoPreferencesRepository** - Demo app's unified repository
4. ✅ **ManageDemoPreferencesUseCase** - Demo app's use case
5. ✅ **PreferencesViewModel** - Demo app's presentation layer

### SDK (Scans and Manages Host App):

1. ✅ **UserDefaultsScanner** - Auto-discovers .plist files
2. ✅ **KeychainScanner** - Auto-discovers Keychain services
3. ✅ **HostAppPreferenceScanner** - Coordinates all scanners
4. ✅ **HostAppPreferenceRepository** - Repository with edit/delete support
5. ✅ **PreferencesConfiguration** - Optional filtering/privacy controls
6. ✅ **AppPreference** - Model for scanned preferences
7. ✅ **GetHostAppPreferencesUseCase** - Use case for scanning
8. ✅ **UpdateHostAppPreferenceUseCase** - Use case for editing
9. ✅ **DeleteHostAppPreferenceUseCase** - Use case for deleting
10. ✅ **PreferencesListView** - SwiftUI view with edit/delete UI

### Not Included (Not Needed for iOS):

1. ❌ **PreferencesRegistry** - Removed! iOS can scan directly
2. ❌ **Proto extractors** - iOS doesn't have Proto DataStore
3. ❌ **Registration code** - Not needed, everything is automatic
4. ❌ **Change tracking** - Not needed for live scanning
5. ❌ **PreferenceMonitor** - Removed! Using scanners instead

---

## Summary

**Android:** Needs registration for Proto DataStore (complex binary format)
**iOS:** Doesn't need registration! Can scan, edit, and delete everything automatically.

**Best practice for iOS:**
- Use auto-discovery (zero configuration)
- Only add configuration if you need to hide/filter preferences
- Enable editing for debug builds
- Disable editing for production builds (optional)

**Key Features:**
- ✅ Live scanning (no change history)
- ✅ Edit preferences from SDK UI
- ✅ Delete preferences from SDK UI
- ✅ Zero configuration required
- ✅ Matches Android SDK behavior

**Result:** Simpler, cleaner, and more powerful than Android!
