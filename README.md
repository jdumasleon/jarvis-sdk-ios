# Jarvis iOS SDK

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A comprehensive debugging and development toolkit for iOS applications, providing real-time insights into your app's behavior, network traffic, preferences, and performance metrics.

**🎯 Perfect for development and debugging | 📱 Zero overhead in production builds**

## Table of Contents

- [Quick Start](#quick-start)
  - [1. Add Dependency](#1-add-dependency)
  - [2. Initialize in App](#2-initialize-in-app)
  - [3. Configure Network Monitoring](#3-configure-network-monitoring)
  - [4. Activate Jarvis](#4-activate-jarvis)
- [Features](#features)
  - [🌐 Network Inspection](#-network-inspection)
  - [📊 Preferences Management](#-preferences-management)
  - [⚡ Performance Monitoring](#-performance-monitoring)
  - [🏠 Application Overview](#-application-overview)
  - [🎨 Modern UI](#-modern-ui)
- [Installation](#installation)
  - [Swift Package Manager (Recommended)](#swift-package-manager-recommended)
- [Integration Guide](#integration-guide)
  - [Prerequisites](#prerequisites)
  - [Step-by-Step Integration](#step-by-step-integration)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
  - [Complete Configuration Options](#complete-configuration-options)
  - [Integration Checklist](#integration-checklist)
- [Usage](#usage)
  - [Activation Methods](#activation-methods)
  - [Network Monitoring](#network-monitoring)
  - [Preferences Management](#preferences-management-1)
  - [Performance Monitoring](#performance-monitoring-1)
- [Advanced Configuration](#advanced-configuration)
  - [Custom Network Interception](#custom-network-interception)
  - [Production Build Behavior](#production-build-behavior)
- [Demo Application](#demo-application)
- [Advanced Usage](#advanced-usage)
  - [Manual Network Logging](#manual-network-logging)
  - [Custom Preferences Integration](#custom-preferences-integration)
- [Architecture](#architecture)
  - [Module Structure](#module-structure)
  - [Key Components](#key-components)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debug Mode](#debug-mode)
  - [Support](#support)
- [Frequently Asked Questions](#frequently-asked-questions)
- [License](#license)
- [Changelog](#changelog)
  - [Version 1.1.7 (Latest)](#version-117-latest)
  - [Version 1.1.0](#version-110)
  - [Version 1.0.0](#version-100)

---

## Quick Start

### 1. Add Dependency

**Swift Package Manager (SPM):**
```swift
// In Xcode: File > Add Package Dependencies
// URL: https://github.com/jdumasleon/mobile-jarvis-ios-sdk
```

### 2. Initialize in App

**SwiftUI:**
```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(config: JarvisConfig(
                    enableShakeDetection: true,
                    enableDebugLogging: true
                ))
        }
    }
}
```

**UIKit:**
```swift
import UIKit
import Jarvis

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let viewController = ViewController()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()

        // Initialize Jarvis SDK
        JarvisSDK.shared.initialize(
            config: JarvisConfig(enableShakeDetection: true),
            window: window
        )
    }
}
```

### 3. Configure Network Monitoring

Configure your URLSession to enable network inspection:

```swift
import Jarvis

class HTTPClient {
    private let session: URLSession

    init() {
        var config = URLSessionConfiguration.default

        // Add Jarvis network interception
        JarvisSDK.configureURLSession(&config)

        self.session = URLSession(configuration: config)
    }

    func fetchData() async throws -> Data {
        let url = URL(string: "https://api.example.com/data")!
        let (data, _) = try await session.data(from: url)
        // Request automatically captured by Jarvis ✓
        return data
    }
}
```

### 4. Activate Jarvis

- **Shake your device** (if enabled in config)
- **Or call programmatically**: `JarvisSDK.shared.activate()`

That's it! 🎉 Jarvis will now provide debugging capabilities and network inspection.

## Features

### 🌐 Network Inspection
- **Real-time HTTP/HTTPS monitoring** - Capture all network requests and responses
- **Request/Response details** - Headers, body, timing, and error information
- **Automatic data redaction** - Protects sensitive information (tokens, passwords)
- **Search and filtering** - Find specific requests quickly
- **Duration tracking** - Accurate millisecond timing for performance analysis
- **Error tracking** - Captures failed requests with detailed error information

### 📊 Preferences Management
- **Multi-storage support** - UserDefaults, Keychain, and Property Lists
- **Real-time inspection** - View all app preferences instantly
- **Type-safe display** - Proper formatting for all data types
- **iOS Settings-style UI** - Familiar interface for browsing preferences
- **Search and filtering** - Quickly find specific keys or values
- **Secure data handling** - Keychain items properly protected

### ⚡ Performance Monitoring
- **CPU Metrics** - Real-time CPU usage monitoring with per-core breakdown
- **Memory Tracking** - Heap usage, footprint, and memory pressure detection
- **FPS Monitoring** - Frame rate tracking with jank detection
- **Battery Monitoring** - Battery level and thermal state tracking
- **Performance Charts** - Visual representation of system performance over time
- **Historical Data** - Track performance trends throughout your debugging session

### 🏠 Application Overview
- **Dashboard** - Comprehensive metrics dashboard with multiple views
- **System Information** - Device details, OS version, app version
- **Health Scores** - Overall app health metrics and indicators
- **Network Activity Charts** - Visual representation of network traffic
- **Session Management** - Track metrics across app sessions

### 🎨 Modern UI
- **SwiftUI Native** - Built entirely with SwiftUI for modern iOS
- **Draggable FAB** - Floating action button with smooth animations
- **Expandable Mini-FABs** - Quick access to all features
- **Dark/Light Theme** - Automatic theme switching based on system preferences
- **Smooth Animations** - Fluid transitions and micro-interactions
- **Responsive Design** - Optimized for all iOS device sizes

## Installation

The Jarvis iOS SDK is available through multiple distribution channels:

- **✅ Swift Package Manager** (Recommended) - Native Xcode integration
- **✅ Manual Integration** - For advanced use cases

### Swift Package Manager (Recommended)

#### Using Xcode

1. Open your project in Xcode
2. Go to **File > Add Package Dependencies**
3. Enter the repository URL: `https://github.com/jdumasleon/mobile-jarvis-ios-sdk`
4. Select version: **1.1.7** or **"Up to Next Major Version"**
5. Click **Add Package**
6. Select your target and click **Add Package**

#### Using Package.swift

Add to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/jdumasleon/mobile-jarvis-ios-sdk", from: "1.2.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Jarvis", package: "mobile-jarvis-ios-sdk")
    ]
)
```

### Available Packages

The SDK provides a complete, all-in-one package:

```swift
// Complete SDK (recommended)
import Jarvis  // All features included
```

Features included:
- ✅ **Network Inspection** - URLSession interception and monitoring
- ✅ **Preferences Management** - UserDefaults, Keychain, Property List support
- ✅ **Performance Monitoring** - CPU, Memory, FPS tracking
- ✅ **Core Functionality** - FAB, shake detection, configuration
- ✅ **Design System** - Beautiful UI components and theme
- ✅ **Zero overhead in production** - Automatically disabled in release builds

## Integration Guide

### Prerequisites

**🔧 Required:**
- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI or UIKit

**📦 Optional but Recommended:**
- URLSession for network monitoring
- UserDefaults for preferences inspection

### Step-by-Step Integration

#### Option A: SwiftUI Integration

##### 1. Add Jarvis Modifier to Your App

```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(config: createConfig())
        }
    }

    private func createConfig() -> JarvisConfig {
        return JarvisConfig(
            preferences: PreferencesConfig(
                configuration: PreferencesConfiguration(
                    autoDiscoverUserDefaults: true,
                    autoDiscoverKeychain: true
                )
            ),
            networkInspection: NetworkInspectionConfig(
                enableNetworkLogging: true
            ),
            enableDebugLogging: true,
            enableShakeDetection: true
        )
    }
}
```

##### 2. Configure Your URLSession

```swift
import Jarvis

class NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession

    init() {
        var config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30

        // Add Jarvis network interception
        JarvisSDK.configureURLSession(&config)

        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = URL(string: endpoint)!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

#### Option B: UIKit Integration

See [UIKit Integration Guide](UIKIT_INTEGRATION.md) for comprehensive UIKit setup instructions.

##### 1. Initialize in SceneDelegate

```swift
import UIKit
import Jarvis

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let viewController = ViewController()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()

        // Initialize Jarvis SDK
        JarvisSDK.shared.initialize(
            config: createConfig(),
            window: window
        )
    }

    private func createConfig() -> JarvisConfig {
        return JarvisConfig(
            preferences: PreferencesConfig(
                configuration: PreferencesConfiguration(
                    autoDiscoverUserDefaults: true,
                    autoDiscoverKeychain: true
                )
            ),
            networkInspection: NetworkInspectionConfig(
                enableNetworkLogging: true
            ),
            enableDebugLogging: true,
            enableShakeDetection: true
        )
    }
}
```

##### 2. Handle Shake Detection (UIKit)

```swift
import UIKit
import Jarvis

class ViewController: UIViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            JarvisSDK.shared.handleShake()
        }
    }
}
```

### SwiftUI Integration

Complete SwiftUI setup example:

```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(config: advancedConfig())
        }
    }

    private func advancedConfig() -> JarvisConfig {
        return JarvisConfig(
            preferences: PreferencesConfig(
                configuration: PreferencesConfiguration(
                    autoDiscoverUserDefaults: true,
                    autoDiscoverKeychain: true,
                    enablePreferenceEditing: false,  // Read-only mode
                    showSystemPreferences: false     // Hide system keys
                )
            ),
            networkInspection: NetworkInspectionConfig(
                enableNetworkLogging: true,
                useAggressiveInterception: true,
                maxCachedRequests: 100
            ),
            enableDebugLogging: true,
            enableShakeDetection: true
        )
    }
}
```

### UIKit Integration

For UIKit apps, see the [UIKit Integration Guide](UIKIT_INTEGRATION.md) which covers:
- ✅ Complete UIKit setup instructions
- ✅ Window management and lifecycle
- ✅ Navigation controller integration
- ✅ Shake detection implementation
- ✅ Working example code
- ✅ Troubleshooting UIKit-specific issues

### Complete Configuration Options

**Full JarvisConfig Example:**

```swift
import Jarvis

private func createAdvancedConfig() -> JarvisConfig {
    return JarvisConfig(
        // Preferences configuration
        preferences: PreferencesConfig(
            configuration: PreferencesConfiguration(
                // Auto-discovery settings
                autoDiscoverUserDefaults: true,
                autoDiscoverKeychain: true,

                // Security and behavior
                enablePreferenceEditing: false,      // Read-only mode for safety
                showSystemPreferences: false,        // Hide system keys
                maxPreferencesCount: 1000           // Limit for performance
            )
        ),

        // Network inspection configuration
        networkInspection: NetworkInspectionConfig(
            enableNetworkLogging: true,
            useAggressiveInterception: true,        // Automatic URLSession interception
            maxCachedRequests: 100,                // Limit cached requests
            enableBodyLogging: true,               // Log request/response bodies
            redactSensitiveData: true              // Automatically redact passwords, tokens
        ),

        // Performance monitoring
        performanceMonitoring: PerformanceConfig(
            enableCpuMonitoring: true,
            enableMemoryMonitoring: true,
            enableFpsMonitoring: true,
            samplingIntervalMs: 1000,              // Sample every 1 second
            maxHistorySize: 300                    // Keep 5 minutes of history
        ),

        // Core features
        enableDebugLogging: true,
        enableShakeDetection: true
    )
}
```

### Integration Checklist

Before deploying, verify:

**For SwiftUI:**
- ✅ `.jarvisSDK()` modifier added to root view
- ✅ Configuration created with desired features
- ✅ URLSession configured for network monitoring
- ✅ Shake detection tested on physical device

**For UIKit:**
- ✅ `JarvisSDK.shared.initialize()` called in SceneDelegate
- ✅ Window reference passed to SDK
- ✅ Shake detection implemented in ViewController
- ✅ URLSession configured for network monitoring
- ✅ Lifecycle properly managed

**Common Checklist:**
- ✅ **SDK Initialization**: Jarvis configured on app launch
- ✅ **Network Configuration**: URLSession configured with `JarvisSDK.configureURLSession()`
- ✅ **Build Variants**: Debug-only integration confirmed
- ✅ **Physical Device Testing**: Shake detection tested on real device
- ✅ **Performance**: No noticeable impact on app performance

## Usage

### Activation Methods

#### 1. Shake Detection
Simply shake your device to open Jarvis (if enabled in configuration).

**Note:** Shake detection only works on physical devices, not in the simulator.

#### 2. Programmatic Activation
```swift
import Jarvis

// In your ViewController or View
func openJarvis() {
    // Activate Jarvis
    JarvisSDK.shared.activate()

    // Deactivate Jarvis
    JarvisSDK.shared.deactivate()

    // Toggle Jarvis state
    let isActive = JarvisSDK.shared.toggle()

    // Check if active
    if JarvisSDK.shared.isActive {
        print("Jarvis is currently active")
    }
}
```

#### 3. Floating Action Button (FAB)
When activated, the Jarvis FAB provides quick access to:
- **Home** - Main dashboard with metrics and overview
- **Inspector** - Network traffic analysis
- **Preferences** - App preferences management

The FAB can be dragged anywhere on the screen and remembers its position.

### Network Monitoring

#### Automatic Network Interception

Jarvis automatically intercepts network traffic when your URLSession is configured:

```swift
import Jarvis

// Configure once in your networking layer
class APIClient {
    private let session: URLSession

    init() {
        var config = URLSessionConfiguration.default
        JarvisSDK.configureURLSession(&config)
        self.session = URLSession(configuration: config)
    }

    // All requests through this session are automatically captured
    func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://api.example.com/users")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([User].self, from: data)
    }
}
```

**Supported HTTP Clients:**
- ✅ **URLSession** - Full support (built-in)
- ✅ **Alamofire** - Works automatically (uses URLSession)
- ✅ **Custom networking** - Works if based on URLSession
- ❌ **Pure socket connections** - Not supported

#### Viewing Captured Requests

1. **Activate Jarvis** - Shake device or call `JarvisSDK.shared.activate()`
2. **Tap Inspector FAB** - Network icon in the FAB menu
3. **Browse Requests** - See all captured requests in real-time
4. **View Details** - Tap any request to see:
   - Request: Method, URL, headers, body
   - Response: Status code, headers, body
   - Timing: Duration in milliseconds
   - Errors: Detailed error information if failed

#### Search and Filter

- **Search by URL** - Type in the search bar
- **Filter by method** - GET, POST, PUT, DELETE, etc.
- **Filter by status** - 2xx (success), 4xx (client error), 5xx (server error)
- **Sort by time** - Newest first or oldest first
- **Sort by duration** - Find slow requests

### Preferences Management

#### Automatic Detection

Jarvis automatically discovers and displays:
- **UserDefaults** - All standard and suite-based preferences
- **Keychain** - Securely stored credentials (with proper entitlements)
- **Property Lists** - App-specific .plist files

#### Viewing Preferences

1. **Activate Jarvis**
2. **Tap Preferences button** in the FAB menu
3. **Browse by storage type** - Filter by UserDefaults, Keychain, etc.
4. **Search for keys** - Use search bar to find specific preferences
5. **View details** - Tap any preference to see type, value, and metadata

#### Type-Safe Display

Jarvis properly formats all data types:
- **String** - Plain text display
- **Number** - Integer, Float, Double formatting
- **Boolean** - True/False display
- **Date** - Formatted date and time
- **Data** - Hex dump or decoded string
- **Array** - List view with items
- **Dictionary** - Key-value pair display

### Performance Monitoring

#### Automatic Metrics Collection

Jarvis collects performance data automatically when enabled:

```swift
let config = JarvisConfig(
    performanceMonitoring: PerformanceConfig(
        enableCpuMonitoring: true,
        enableMemoryMonitoring: true,
        enableFpsMonitoring: true,
        samplingIntervalMs: 1000
    )
)
```

#### Viewing Performance Data

1. **Activate Jarvis**
2. **Open Dashboard** - Tap Home in FAB menu
3. **View Performance Charts** - See real-time metrics:
   - **CPU Usage** - App and system CPU percentage
   - **Memory Usage** - Heap, footprint, and total memory
   - **FPS Metrics** - Frame rate and jank detection
   - **Battery Level** - Current battery percentage
   - **Thermal State** - Device temperature status

#### Performance Metrics Available

**CPU Metrics:**
- App CPU usage percentage
- System-wide CPU usage
- Number of cores
- Active thread count

**Memory Metrics:**
- Heap used/total/max (MB)
- Memory footprint (MB)
- Available memory
- Memory pressure state

**FPS Metrics:**
- Current frame rate
- Average FPS
- Frame drops count
- Jank frames detection

**System Metrics:**
- Battery level percentage
- Thermal state (normal, fair, serious, critical)

## Advanced Configuration

### Custom Network Interception

For advanced use cases, manually log network transactions:

```swift
import Jarvis
import JarvisInspectorDomain

// Custom network interceptor
class CustomNetworkLogger {
    func logRequest(_ request: URLRequest, data: Data?) async {
        let transaction = NetworkTransaction(
            id: UUID().uuidString,
            url: request.url?.absoluteString ?? "",
            method: request.httpMethod ?? "GET",
            requestHeaders: request.allHTTPHeaderFields,
            requestBody: data,
            startDate: Date()
        )

        // Log to Jarvis
        JarvisSDK.shared.logNetworkTransaction(transaction)
    }

    func logResponse(_ response: URLResponse, data: Data?, error: Error?) {
        // Create and log response
        // See documentation for complete example
    }
}
```

### Production Build Behavior

Jarvis is designed for **development only**. In release builds, wrap initialization:

```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .jarvisSDK(config: JarvisConfig(
                    enableShakeDetection: true,
                    enableDebugLogging: true
                ))
                #endif
        }
    }
}
```

This ensures **zero overhead** in production builds.

## Demo Application

The SDK includes a comprehensive demo app showcasing all features:

### Running the Demo

```bash
# Clone the repository
git clone https://github.com/jdumasleon/mobile-jarvis-ios-sdk.git
cd mobile-jarvis-ios-sdk

# Open in Xcode
open JarvisDemo/JarvisDemo.xcodeproj

# Build and run on device or simulator
# (Shake detection requires physical device)
```

### Demo Features

The demo app demonstrates:
- ✅ **SwiftUI Integration** - Complete setup example
- ✅ **Network Monitoring** - Sample API calls with automatic capture
- ✅ **Preferences Management** - Various UserDefaults examples
- ✅ **Performance Monitoring** - Real-time metrics display
- ✅ **FAB Interactions** - Draggable floating action button
- ✅ **Dashboard Views** - Multiple chart and metric visualizations
- ✅ **Search and Filtering** - Advanced request filtering

## Advanced Usage

### Manual Network Logging

For non-URLSession networking or custom integrations:

```swift
import Jarvis
import JarvisInspectorDomain

// Create network transaction
let transaction = NetworkTransaction(
    id: UUID().uuidString,
    url: "https://api.example.com/data",
    method: "POST",
    requestHeaders: ["Content-Type": "application/json"],
    requestBody: requestData,
    startDate: Date()
)

// Log request
JarvisSDK.shared.logNetworkTransaction(transaction)

// Update with response
let updatedTransaction = transaction.withResponse(
    statusCode: 200,
    responseHeaders: responseHeaders,
    responseBody: responseData,
    endDate: Date()
)

JarvisSDK.shared.updateNetworkTransaction(updatedTransaction)
```

### Custom Preferences Integration

Register custom preference storage:

```swift
import Jarvis

// Register custom preferences
JarvisSDK.shared.registerCustomPreferences(
    storageName: "Custom Storage",
    preferences: [
        "api_key": "abc123...",
        "user_id": "12345",
        "is_premium": true,
        "last_sync_date": Date()
    ]
)
```

## Architecture

### Module Structure

```
JarvisSDK/
├── Sources/
│   ├── Jarvis/                    # Main SDK module
│   │   ├── Api/                   # Public API interface
│   │   ├── Config/                # Configuration models
│   │   └── Internal/              # Internal implementation
│   │       ├── Core/              # Common utilities
│   │       ├── Feature/           # Feature modules
│   │       │   ├── Home/          # Dashboard & overview
│   │       │   │   ├── Data/      # Repositories
│   │       │   │   ├── Domain/    # Entities & use cases
│   │       │   │   └── Presentation/ # ViewModels & Views
│   │       │   └── ...
│   │       └── Presentation/      # Navigation & UI
│   │
│   ├── JarvisInspector/           # Network monitoring module
│   │   ├── Data/                  # Network repositories
│   │   ├── Domain/                # Network entities
│   │   └── Presentation/          # Inspector UI
│   │
│   ├── JarvisPreferences/         # Preferences module
│   │   ├── Data/                  # Preferences repositories
│   │   ├── Domain/                # Preferences entities
│   │   └── Presentation/          # Preferences UI
│   │
│   └── JarvisDesignSystem/        # UI components
│       ├── Components/            # Reusable components
│       ├── Foundation/            # Colors, typography
│       └── Resources/             # Assets
│
├── Tests/                         # Unit tests
└── Package.swift                  # SPM manifest
```

### Key Components

- **JarvisSDK** - Main SDK singleton and entry point
- **JarvisSDKApplication** - Core UI application with navigation
- **PerformanceMonitorManager** - Real-time performance tracking
- **NetworkTransactionRepository** - Network data persistence
- **PreferenceRepository** - Preferences data access
- **DependencyContainer** - Dependency injection system

## Troubleshooting

### Common Issues

#### Jarvis Not Appearing

**Solutions:**
1. Check if `.jarvisSDK()` modifier is applied to root view (SwiftUI)
2. Verify `JarvisSDK.shared.initialize()` is called (UIKit)
3. Ensure shake detection is enabled: `enableShakeDetection: true`
4. Try programmatic activation: `JarvisSDK.shared.activate()`
5. Enable debug logging to see initialization logs

#### Shake Detection Not Working

**Reasons:**
- Simulator doesn't support shake gestures
- Shake detection not enabled in config
- Physical device accelerometer issue

**Solutions:**
1. **Test on physical device** (not simulator)
2. Verify config: `JarvisConfig(enableShakeDetection: true)`
3. Use programmatic activation as alternative
4. Check device accelerometer in Settings > Privacy

#### Network Requests Not Appearing

**Common Causes:**
1. URLSession not configured with Jarvis
2. Using `URLSession.shared` (cannot be configured)
3. Network logging disabled in config
4. SDK not activated

**Solutions:**

```swift
// ✗ Wrong - No configuration
let session = URLSession(configuration: .default)

// ✗ Wrong - URLSession.shared cannot be configured
let (data, _) = try await URLSession.shared.data(from: url)

// ✓ Correct - Configure custom URLSession
var config = URLSessionConfiguration.default
JarvisSDK.configureURLSession(&config)
let session = URLSession(configuration: config)
let (data, _) = try await session.data(from: url)
```

#### Preferences Not Loading

**Solutions:**
1. Enable auto-discovery: `autoDiscoverUserDefaults: true`
2. Check UserDefaults access permissions
3. Verify Keychain entitlements for Keychain items
4. Try refreshing the preferences list
5. Check debug logs for scanning errors

#### Performance Issues

**Impact:**
- Network monitoring adds ~2-5ms per request
- Performance monitoring uses ~100KB memory
- Designed for development builds only

**Best Practices:**

```swift
// Wrap in DEBUG flag
#if DEBUG
.jarvisSDK(config: config)
#endif

// Reduce overhead
let config = JarvisConfig(
    networkInspection: NetworkInspectionConfig(
        maxCachedRequests: 50  // Lower cache limit
    ),
    performanceMonitoring: PerformanceConfig(
        samplingIntervalMs: 2000  // Sample less frequently
    )
)

// Deactivate when not debugging
JarvisSDK.shared.deactivate()
```

### Debug Mode

Enable verbose logging to diagnose issues:

```swift
let config = JarvisConfig(
    enableDebugLogging: true  // Enable detailed logs
)
```

Check Xcode console for Jarvis log messages:
```
[Jarvis] SDK initialized successfully
[Jarvis] Network monitoring enabled
[Jarvis] Performance monitoring started
[Jarvis] Captured request: GET https://api.example.com/data
```

### Support

For issues and questions:
- **GitHub Issues**: [Create an issue](https://github.com/jdumasleon/mobile-jarvis-ios-sdk/issues)
- **Email**: jdumasleon@gmail.com
- **Documentation**: Check this README and code examples
- **Demo App**: Review the included demo application

## Frequently Asked Questions

### General

**Q: Does Jarvis work with Alamofire or other networking libraries?**

A: Yes! Alamofire and most iOS networking libraries use `URLSession` internally. When you configure your URLSession with `JarvisSDK.configureURLSession()`, all requests are automatically captured. Any library built on `URLSession` will work seamlessly.

**Q: Can I use Jarvis in production builds?**

A: Jarvis is designed for **development and debugging only**. Always wrap initialization in `#if DEBUG` blocks:

```swift
#if DEBUG
.jarvisSDK(config: JarvisConfig(...))
#endif
```

**Q: Does Jarvis work on macOS, watchOS, or tvOS?**

A: Currently iOS only (iOS 15.0+). Support for other Apple platforms is under consideration for future releases.

### Network Monitoring

**Q: Do I need to configure every URLSession instance?**

A: Yes. Each `URLSession` you create needs to be configured with `JarvisSDK.configureURLSession()`. This is typically done once in your networking layer or HTTP client initialization.

**Q: Why aren't my network requests appearing?**

A: Most commonly:
1. URLSession not configured with Jarvis interceptor
2. Using `URLSession.shared` (cannot be configured - create custom session)
3. SDK not activated (shake device or call `.activate()`)
4. Network logging disabled in config

**Q: Are my API keys and passwords safe?**

A: Yes. Jarvis automatically redacts sensitive headers (`Authorization`, `Cookie`, API keys) and detects sensitive data in request/response bodies. All data stays on-device and is never transmitted externally.

**Q: Can I export captured network logs?**

A: Currently, Inspector provides in-app viewing only. Export functionality is planned for a future release. Network data is persisted locally using Core Data for the duration of your debug session.

### Performance

**Q: What is the performance impact of Jarvis?**

A: Minimal in debug builds:
- Network monitoring: ~2-5ms overhead per request
- Performance monitoring: ~100KB memory + sampling overhead
- UI rendering: No noticeable impact when deactivated

In release builds with `#if DEBUG` wrapping: **zero overhead**.

**Q: How do I reduce memory usage?**

A: Configure lower limits:

```swift
let config = JarvisConfig(
    networkInspection: NetworkInspectionConfig(
        maxCachedRequests: 50  // Default: 100
    ),
    performanceMonitoring: PerformanceConfig(
        maxHistorySize: 150,  // Default: 300
        samplingIntervalMs: 2000  // Default: 1000
    )
)
```

### Integration

**Q: Does Jarvis support UIKit apps?**

A: Yes! Jarvis supports both SwiftUI and UIKit. See the [UIKit Integration Guide](UIKIT_INTEGRATION.md) for detailed UIKit setup instructions.

**Q: Can I disable specific features?**

A: Yes, configure only the features you need:

```swift
let config = JarvisConfig(
    preferences: nil,  // Disable preferences
    networkInspection: NetworkInspectionConfig(
        enableNetworkLogging: true
    ),
    performanceMonitoring: nil  // Disable performance monitoring
)
```

## License

```
Copyright 2024 Jarvis SDK

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Changelog

### Version 1.2.0 (Latest)
- ⚡ **Performance Monitoring** - Comprehensive system performance tracking (CPU, Memory, FPS)
- 📊 **Performance Charts** - Visual performance metrics with PerformanceOverviewChart
- 🏠 **Enhanced Dashboard** - Integrated performance monitoring into main dashboard
- 🔧 **Performance Manager** - Real-time performance data collection and monitoring
- 📈 **Historical Metrics** - Track performance trends over time with configurable sampling
- 🎯 **Battery & Thermal** - Battery level and thermal state monitoring
- 📝 **Improved Documentation** - Complete guides for all features and integrations

### Version 1.1.0
- 🌐 **Network Activity Chart** - Visual representation of network traffic over time
- 📊 **Dashboard Redesign** - New card-based layout with multiple chart types
- 🎨 **Chart Animations** - Smooth entry animations for all chart components
- 🔧 **Enhanced Metrics** - Expanded dashboard metrics with network and preferences analytics
- 📱 **UIKit Support** - Complete UIKit integration guide and documentation
- 🎭 **Design System Updates** - Improved components and visual consistency

### Version 1.0.0
- 🚀 **Initial Release** - Core SDK functionality
- 🌐 **Network Monitoring** - HTTP/HTTPS request interception via URLProtocol
- ⚙️ **Preferences Management** - UserDefaults, Keychain, Property List support
- 🎨 **SwiftUI UI** - Native SwiftUI interface with dark/light theme
- 📱 **Shake Detection** - Intuitive activation method
- 🎯 **Floating Action Button** - Draggable FAB with expandable mini-FABs
- 🏗️ **Modular Architecture** - Clean separation of concerns
- 🔒 **Sensitive Data Protection** - Automatic redaction of passwords and tokens
- 📱 **iOS 15.0+ Support** - Modern iOS compatibility

---

**Built with ❤️ for iOS developers**