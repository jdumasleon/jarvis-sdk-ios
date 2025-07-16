# Jarvis iOS SDK

A modular, in-app developer toolkit SDK for iOS applications. Inspired by tools like Chucker (Android) and FLEX (iOS), Jarvis enables developers and QA engineers to inspect, debug, and interact with their mobile apps at runtime without needing external tools.

## 🎯 Features

- **Network Inspector**: Monitor HTTP requests and responses in real-time
- **Preferences Inspector**: View and edit UserDefaults, Keychain, and other preferences
- **Shake to Debug**: Activate the toolkit with device shake gesture
- **SwiftUI Native**: Built with SwiftUI for modern iOS development
- **Modular Architecture**: Clean, testable, and extensible design
- **SPM Support**: Easy integration via Swift Package Manager

## 🏗️ Architecture

The SDK is structured into modular components using Swift Package Manager:

### Core Modules
- **JarvisCommon**: Shared utilities, extensions, and logging
- **JarvisDomain**: Business logic, entities, and repository protocols
- **JarvisData**: Data layer implementation, network interception
- **JarvisDesignSystem**: UI components and theming
- **JarvisNavigation**: Navigation utilities and routing

### Feature Modules
- **JarvisInspector**: Complete inspector UI with network and preferences views

### Demo App
- **JarvisDevApp**: iOS demo application showcasing SDK capabilities

## 📦 Installation

### Swift Package Manager

Add Jarvis to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version/branch you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/jarvis-ios-sdk", from: "1.0.0")
]
```

## 🚀 Quick Start

### 1. Open the Package in Xcode

```bash
open Package.swift
```

This will open the entire Jarvis SDK in Xcode where you can explore the modular architecture, run tests, and see the source code.

### 2. Try the Demo App

For a complete demo application:

1. Create a new iOS App project in Xcode
2. Add this package as a local dependency:
   - File → Add Package Dependencies → Add Local
   - Select the `mobile-jarvis-ios-sdk` folder
3. Copy the demo app source files from `JarvisDevApp/Sources/` into your project

### 3. Configure Jarvis in your App

```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    init() {
        // Configure Jarvis SDK
        Jarvis.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisShakeDetector() // Enable shake to debug
        }
    }
}
```

### 2. Manual Inspector Access

```swift
import SwiftUI
import Jarvis

struct ContentView: View {
    @State private var showingInspector = false
    
    var body: some View {
        VStack {
            Button("Open Jarvis Inspector") {
                showingInspector = true
            }
        }
        .sheet(isPresented: $showingInspector) {
            Jarvis.shared.showInspector()
        }
    }
}
```

### 3. Network Interception

Network requests are automatically intercepted when Jarvis is configured. The SDK uses `URLProtocol` to monitor:

- HTTP/HTTPS requests
- Request/response headers  
- Request/response bodies
- Response times and status codes

## 🔧 API Reference

### Jarvis Class

```swift
public final class Jarvis: ObservableObject {
    public static let shared: Jarvis
    
    // Configuration
    public func configure()
    public func enableNetworkInterception()
    public func disableNetworkInterception()
    
    // UI
    public func showInspector() -> some View
}
```

### SwiftUI Modifiers

```swift
extension View {
    // Enable shake-to-debug functionality
    public func jarvisShakeDetector() -> some View
}
```

## 🎨 Design System

Jarvis includes a complete design system with:

- **Colors**: Adaptive color palette supporting light/dark modes
- **Typography**: Consistent font scales and monospace code fonts  
- **Components**: Buttons, cards, and other reusable UI elements
- **Spacing**: Standardized spacing scale
- **Corner Radius**: Consistent border radius values

### Example Usage

```swift
import JarvisDesignSystem

VStack(spacing: JarvisSpacing.md) {
    JarvisButton("Primary Action", style: .primary) {
        // Action
    }
    
    JarvisCard {
        Text("Card Content")
            .foregroundColor(Color.jarvis.text)
    }
}
```

## 🧪 Testing

Run tests using Xcode or Swift Package Manager:

```bash
swift test
```

The project includes comprehensive unit tests for:
- Core SDK functionality
- Network interception
- Data management
- UI components

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎯 Roadmap

- [ ] Feature flags inspector
- [ ] Core Data inspector  
- [ ] Custom plugin system
- [ ] Performance monitoring
- [ ] Crash reporting integration
- [ ] Export/import functionality
- [ ] Remote debugging capabilities

## 💡 Inspiration

Inspired by excellent developer tools:
- [Chucker](https://github.com/ChuckerTeam/chucker) (Android)
- [FLEX](https://github.com/FLEXTool/FLEX) (iOS)
- [Flipper](https://fbflipper.com/) (Cross-platform)