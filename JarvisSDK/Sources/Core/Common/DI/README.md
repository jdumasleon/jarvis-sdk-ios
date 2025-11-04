# Jarvis Dependency Injection System

## Overview

The Jarvis DI system is a lightweight, type-safe dependency injection container inspired by [Stitch](https://github.com/thoughtbot/Stitch), designed specifically for the Jarvis iOS SDK. It provides a clean, SwiftUI-native approach to managing dependencies across modules without requiring macros (compatible with iOS 16+).

## Core Components

### 1. DependencyContainer
Thread-safe singleton container that manages dependency registration and resolution.

```swift
@MainActor
public final class DependencyContainer {
    public static let shared = DependencyContainer()

    // Register dependencies
    func register<T>(_ type: T.Type, scope: DependencyScope = .singleton, factory: @escaping () -> T)

    // Resolve dependencies
    func resolve<T>(_ type: T.Type) -> T
}
```

### 2. DependencyScope
Defines the lifecycle of dependencies:

- **`.singleton`**: Single instance shared across the application
- **`.transient`**: New instance created on each resolution
- **`.scoped`**: Single instance per scope (useful for feature-level dependencies)

### 3. Property Wrappers

#### @Injected
For standard dependency injection:

```swift
@Injected var repository: PreferenceRepositoryProtocol
@Injected var useCase: GetPreferencesUseCase
```

#### @InjectedObservable
For SwiftUI ObservableObject dependencies:

```swift
@InjectedObservable var viewModel: PreferencesViewModel
```

## Architecture

### Registration Flow

1. **App Initialization**: `JarvisSDK.initialize()` is called
2. **DI Setup**: `DependencyConfiguration.registerDependencies()` registers all modules
3. **Module Registration**: Each feature module registers its dependencies:
   - Repositories (Singleton)
   - Use Cases (Transient)
   - ViewModels (Transient)

### Dependency Graph

```
┌─────────────────────────────────────┐
│   DependencyConfiguration           │
│   (Centralized Registration)        │
└─────────────────────────────────────┘
              │
              ├─── Preferences Module
              │    ├── PreferenceRepository (Singleton)
              │    ├── GetPreferencesUseCase (Transient)
              │    ├── UpdatePreferenceUseCase (Transient)
              │    └── PreferencesViewModel (Transient)
              │
              └─── Inspector Module
                   ├── NetworkTransactionRepository (Singleton)
                   ├── MonitorNetworkTransactionsUseCase (Transient)
                   └── NetworkInspectorViewModel (Transient)
```

## Usage Examples

### 1. Registering Dependencies

In `DependencyConfiguration.swift`:

```swift
private static func registerPreferencesDependencies() {
    let container = DependencyContainer.shared

    // Register Repository (Singleton)
    container.register(
        PreferenceRepositoryProtocol.self,
        scope: .singleton
    ) {
        PreferenceRepository()
    }

    // Register Use Case (Transient)
    container.register(
        GetPreferencesUseCase.self,
        scope: .transient
    ) {
        let repository = container.resolve(PreferenceRepositoryProtocol.self)
        return GetPreferencesUseCase(repository: repository)
    }
}
```

### 2. Injecting Dependencies in ViewModels

```swift
@MainActor
public class PreferencesViewModel: BaseViewModel {
    @Injected private var getPreferencesUseCase: GetPreferencesUseCase
    @Injected private var updatePreferenceUseCase: UpdatePreferenceUseCase

    public override init() {
        super.init()
    }
}
```

### 3. Using ViewModels in SwiftUI Views

```swift
struct PreferencesScreen: View {
    @InjectedObservable var viewModel: PreferencesViewModel

    var body: some View {
        List {
            ForEach(viewModel.uiState.preferences) { preference in
                Text(preference.key)
            }
        }
        .onAppear {
            viewModel.loadPreferences()
        }
    }
}
```

### 4. Testing with Custom Dependencies

```swift
// Production
let viewModel = PreferencesViewModel() // Uses DI

// Testing
let mockRepository = MockPreferenceRepository()
let mockUseCase = GetPreferencesUseCase(repository: mockRepository)
let viewModel = PreferencesViewModel(
    getPreferencesUseCase: mockUseCase,
    updatePreferenceUseCase: mockUpdateUseCase,
    deletePreferenceUseCase: mockDeleteUseCase
)
```

## Benefits

### 1. **Decoupling**
- ViewModels don't create their own dependencies
- Protocol-based abstractions for testability
- Clear separation of concerns

### 2. **Centralized Configuration**
- All dependencies registered in one place (`DependencyConfiguration.swift`)
- Easy to understand the dependency graph
- Single source of truth for dependency management

### 3. **Type Safety**
- Compile-time type checking
- No string-based lookups
- Clear error messages if dependencies are missing

### 4. **SwiftUI Integration**
- Native `@StateObject` lifecycle management
- Seamless integration with SwiftUI views
- Automatic view updates when ObservableObjects change

### 5. **Testability**
- Easy to inject mock dependencies
- Support for both DI and manual initialization
- Clear testing boundaries

## Comparison with Stitch

| Feature | Jarvis DI | Stitch |
|---------|-----------|--------|
| **Macros** | No (iOS 16+ compatible) | Yes (requires Xcode 15+) |
| **Property Wrappers** | `@Injected`, `@InjectedObservable` | `@Stitch`, `@StitchObservable` |
| **Registration** | Manual in `DependencyConfiguration` | `@Stitchify` macro |
| **Scopes** | Singleton, Transient, Scoped | Singleton, Transient |
| **SwiftUI Support** | Native `@StateObject` integration | Native support |
| **Testing** | Dual initialization (DI + manual) | Similar approach |

## Best Practices

### 1. **Use Appropriate Scopes**
- Repositories: `.singleton` (shared state)
- Use Cases: `.transient` (stateless operations)
- ViewModels: `.transient` (new instance per view)

### 2. **Register Early**
- Call `DependencyConfiguration.registerDependencies()` during app initialization
- Register before any views are created

### 3. **Protocol-Based Injection**
- Always inject protocols, not concrete types
- Enables easy mocking for tests

```swift
// Good ✅
container.register(PreferenceRepositoryProtocol.self) { PreferenceRepository() }
@Injected var repository: PreferenceRepositoryProtocol

// Avoid ❌
@Injected var repository: PreferenceRepository
```

### 4. **Keep Factories Simple**
- Factories should be lightweight
- Complex initialization logic belongs in the type itself

### 5. **Support Manual Initialization for Testing**
- Always provide a public initializer that accepts dependencies
- Use `@Injected` for production, manual init for testing

## Troubleshooting

### "Dependency not registered" Fatal Error

**Cause**: Attempting to resolve a dependency before registration.

**Solution**: Ensure `DependencyConfiguration.registerDependencies()` is called before any `@Injected` properties are accessed.

### "Cannot find type in scope" Compiler Error

**Cause**: Missing import statement.

**Solution**: Import the `Common` module where the DI infrastructure is defined:

```swift
import Common
```

### SwiftUI Preview Crashes

**Cause**: Dependencies not registered in preview context.

**Solution**: Register dependencies in the preview:

```swift
#Preview {
    let _ = DependencyConfiguration.registerDependencies()
    return PreferencesScreen()
}
```

## File Structure

```
JarvisSDK/Sources/Core/Common/DI/
├── DependencyContainer.swift      # Core container implementation
├── DependencyScope.swift          # Lifecycle scope definitions
├── Injected.swift                 # @Injected property wrapper
├── InjectedObservable.swift       # @InjectedObservable wrapper
├── Injectable.swift               # Marker protocol
└── README.md                      # This file

JarvisSDK/Sources/Jarvis/Config/
└── DependencyConfiguration.swift  # Centralized registration
```

## Future Enhancements

- [ ] Circular dependency detection
- [ ] Dependency graph visualization
- [ ] Auto-registration via reflection (if needed)
- [ ] Named dependencies (multiple implementations)
- [ ] Lazy resolution optimization
- [ ] Thread-local scopes

## Contributing

When adding new modules:

1. Define protocols for all dependencies
2. Register dependencies in `DependencyConfiguration.swift`
3. Use `@Injected` in consuming classes
4. Provide manual initializers for testing

---

**Built with ❤️ for the Jarvis iOS SDK**
