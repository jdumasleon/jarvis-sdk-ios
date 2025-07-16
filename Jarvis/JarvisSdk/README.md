# JarvisDevApp - Demo Application

This is a demo application showcasing the Jarvis iOS SDK capabilities.

## How to Run the Demo

Since Xcode project files can be complex to create programmatically, here are the recommended ways to test the Jarvis SDK:

### Option 1: Create a New iOS App in Xcode

1. Open Xcode
2. Create a new iOS App project
3. Choose SwiftUI as the interface
4. Add the Jarvis SDK as a local package dependency:
   - File → Add Package Dependencies
   - Click "Add Local..." 
   - Navigate to `/Users/jldumas/Jo/Jarvis/mobile-jarvis-ios-sdk`
   - Select the package

### Option 2: Use the provided source files

The demo app source files are available in the `Sources/` directory:

- `JarvisDevAppApp.swift` - Main app entry point
- `ContentView.swift` - Main demo interface

Copy these files into your new Xcode project and they should work with the Jarvis SDK.

### Option 3: Test the SDK directly

You can also test the SDK by opening the main package in Xcode:

1. Open `/Users/jldumas/Jo/Jarvis/mobile-jarvis-ios-sdk/Package.swift` in Xcode
2. Build and run tests using Cmd+U
3. Explore the source code and documentation

## Demo Features

The demo app includes:

- **Network Inspector**: Make test HTTP requests and view them in the inspector
- **Preferences Inspector**: Add test UserDefaults and edit them live
- **Shake Detection**: Shake the device (or simulator) to open the inspector
- **Manual Inspector Access**: Button to manually open the inspector

## Integration Example

```swift
import SwiftUI
import Jarvis

@main
struct MyApp: App {
    init() {
        Jarvis.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisShakeDetector()
        }
    }
}
```

## Next Steps

Once you have the demo running, try:

1. Making network requests and viewing them in the Network Inspector
2. Adding UserDefaults and editing them in the Preferences Inspector
3. Shaking the device to trigger the debug overlay
4. Exploring the modular architecture in the main SDK package