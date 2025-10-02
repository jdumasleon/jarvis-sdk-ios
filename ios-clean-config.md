# name

iOS Clean Architecture Assistant

# description

Expert iOS development with Clean Architecture, SwiftUI, and Apple best practices - Simplified approach

# principles

- Follow SOLID principles strictly
- Apply DRY (Don't Repeat Yourself) - extract common functionality
- Use KISS (Keep It Simple, Stupid) - prefer simple solutions
- YAGNI (You Aren't Gonna Need It) - don't over-engineer
- Favor composition over inheritance
- Write self-documenting code with clear naming
- Embrace Swift's type safety and optionals
- Use value types (structs) over reference types when possible
- Leverage SwiftUI's declarative nature

# project structure

## modularization

- Use Swift Package Manager for feature modules
- Separate core frameworks (Core, Domain, Data, Presentation, DesignSystem)
- Create feature-based modules (AuthFeature, ProfileFeature, etc.)
- Follow Apple's recommended app architecture patterns
- Use local Swift packages for clean module separation

## module types

### app module

- Main app target with dependency injection setup
- App lifecycle management and configuration
- Deep linking and universal links handling
- Main navigation setup

### feature modules

- Contains Views, ViewModels, and feature-specific logic
- Self-contained and testable modules
- Export public navigation destinations
- Follow ViewState/ViewData pattern similar to Android UiState/UiData

### core modules

- **domain:** Use cases, entities, repository protocols
- **data:** Repository implementations, data sources, persistence
- **network:** API clients, network layer, URLSession extensions
- **presentation:** Common UI components, ViewModels, state management
- **designsystem:** Reusable UI components, themes, styles, tokens
- **common:** Utilities, extensions, constants, shared types
- **testing:** Test utilities, mocks, test doubles

# clean architecture

## layers

### presentation

- UI layer: SwiftUI Views, ViewModels, view state
- ViewModels should only hold UI state and call use cases
- Use @Published and async/await for reactive state management
- Implement proper loading, error, and success states
- Use ViewState/ViewData pattern for consistent state management
- Implement ViewEvent pattern for user actions

### domain

- Business logic layer: Use cases, entities, repository protocols
- No UIKit/SwiftUI dependencies - pure Swift
- Use cases should be single-purpose and testable
- Define clear data contracts with protocols and structs

### data

- Data layer: Repository implementations, data sources
- Handle data transformation between layers
- Implement proper error handling and caching
- Use Swift Data, Core Data, or other persistence layers

# state management

## view state pattern

- Use ViewState enum for loading/success/error states
- Separate ViewState from ViewData (actual data)
- Include mock data in ViewData for previews
- Use @Published for reactive state management
- Implement proper error handling with custom error types

## view data pattern

- Create struct with all screen state
- Include loading states, error states, and actual data
- Provide mock data for testing and previews
- Use immutable structures
- Handle optional states properly

## view event pattern

- Use enum for all user events/actions
- Implement handleEvent function in ViewModel
- Keep events simple and focused
- Handle events in single switch statement
- Use associated values for parameterized events

# swift

## language features

- Prefer structs over classes for value types
- Use enums with associated values for state representation
- Leverage extensions for protocol conformance and organization
- Use property wrappers for common patterns
- Embrace optionals and avoid force unwrapping
- Use async/await for asynchronous operations
- Prefer immutable properties with let over var
- Use generics for type safety and reusability

## async await

### fundamentals

- Use async/await for asynchronous operations
- Use @MainActor for UI-related operations
- Handle cancellation with Task.isCancelled
- Use async let for concurrent operations
- Implement proper error handling with throws
- Use Task for fire-and-forget operations

### best practices

- Use structured concurrency with TaskGroup
- Handle actor isolation properly
- Use continuation APIs for bridging callback code
- Implement proper async function composition
- Use AsyncStream for reactive data streams
- Handle TaskCancellationError separately

### testing

- Use async test functions
- Test cancellation scenarios
- Use expectation() for async testing
- Mock async functions properly
- Test concurrent operations

# swiftui

## view design

- Keep views lightweight and focused
- Use @State for local view state
- Use @StateObject for view model ownership
- Use @ObservedObject for passed-in models
- Implement proper view lifecycle management
- Use state hoisting pattern for reusability

## state management

- Prefer single source of truth
- Use @Binding for two-way data flow
- Implement proper state lifting
- Use @Published for observable properties
- Handle view updates efficiently
- Use @AppStorage for simple persistence

## performance

- Use lazy stacks for large datasets
- Implement proper view identity with id()
- Use @ViewBuilder for conditional views
- Avoid unnecessary view updates
- Use GeometryReader sparingly
- Use .equatable() for expensive views

## navigation

- Use NavigationStack for iOS 16+
- Implement programmatic navigation with NavigationPath
- Handle deep linking properly
- Use sheets and full screen covers appropriately
- Keep navigation logic in coordinators or router patterns

# navigation

## coordinator pattern

- Use Coordinator protocol for navigation abstraction
- Implement AppCoordinator for main navigation flow
- Use NavigationPath for programmatic navigation
- Define destinations as Hashable enums/structs
- Keep navigation logic separate from views

## destination definition

- Define destinations as Hashable enums
- Use associated values for parameterized destinations
- Keep destinations in feature module public API
- Support Codable for deep linking
- Add computed properties for derived state

# dependency injection

## patterns

- Use @EnvironmentObject for SwiftUI dependency injection
- Create simple DI container for complex scenarios
- Use constructor injection in ViewModels
- Implement factory patterns for complex objects
- Use protocols for abstraction and testing
- Keep DI simple and focused

# testing

## unit tests

- Test ViewModels in isolation
- Use XCTest framework effectively
- Mock dependencies with protocols
- Test async/await functions properly
- Use dependency injection for testability

## ui tests

- Use XCUITest for UI automation
- Test user interactions and flows
- Use accessibility identifiers
- Test different device sizes
- Test navigation flows end-to-end

# code templates

## view state data template

```swift
// ViewState definition (equivalent to Android UiState)
enum FeatureViewState: Equatable {
    case idle
    case loading
    case success(FeatureViewData)
    case error(FeatureError)
}

// ViewData with all screen state (equivalent to Android UiData)
struct FeatureViewData: Equatable {
    let items: [FeatureItem]
    let selectedItem: FeatureItem?
    let isRefreshing: Bool
    let searchQuery: String
    let filterType: FilterType
    let showDialog: Bool
    let errorMessage: String?
    
    init(
        items: [FeatureItem] = [],
        selectedItem: FeatureItem? = nil,
        isRefreshing: Bool = false,
        searchQuery: String = "",
        filterType: FilterType = .all,
        showDialog: Bool = false,
        errorMessage: String? = nil
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.isRefreshing = isRefreshing
        self.searchQuery = searchQuery
        self.filterType = filterType
        self.showDialog = showDialog
        self.errorMessage = errorMessage
    }
    
    // Mock data for previews (equivalent to Android mockUiData)
    static let mock = FeatureViewData(
        items: [
            FeatureItem(
                id: "1",
                title: "Sample Active Item",
                description: "This is an active item for testing",
                isActive: true,
                createdAt: Date()
            ),
            FeatureItem(
                id: "2",
                title: "Sample Inactive Item",
                description: "This is an inactive item for testing", 
                isActive: false,
                createdAt: Date()
            ),
            FeatureItem(
                id: "3",
                title: "Another Active Item",
                description: "Another active item with longer description text",
                isActive: true,
                createdAt: Date()
            )
        ],
        selectedItem: FeatureItem(
            id: "1",
            title: "Sample Active Item",
            description: "This is an active item for testing",
            isActive: true,
            createdAt: Date()
        ),
        searchQuery: "sample",
        filterType: .active,
        isRefreshing: false,
        showDialog: false
    )
}

enum FilterType: String, CaseIterable, Equatable {
    case all = "All"
    case active = "Active"  
    case inactive = "Inactive"
}

// Feature Item model
struct FeatureItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let description: String
    let isActive: Bool
    let createdAt: Date
}

// Custom error type
enum FeatureError: Error, Equatable, LocalizedError {
    case networkError
    case dataNotFound
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .dataNotFound:
            return "Data not found"
        case .unknownError(let message):
            return message
        }
    }
}
```

## viewmodel viewevent template

```swift
@MainActor
final class FeatureViewModel: ObservableObject {
    @Published private(set) var viewState: FeatureViewState = .idle
    @Published private(set) var viewData: FeatureViewData = FeatureViewData()
    
    private let getFeatureItemsUseCase: GetFeatureItemsUseCase
    private let updateFeatureItemUseCase: UpdateFeatureItemUseCase
    private let deleteFeatureItemUseCase: DeleteFeatureItemUseCase
    
    init(
        getFeatureItemsUseCase: GetFeatureItemsUseCase,
        updateFeatureItemUseCase: UpdateFeatureItemUseCase,
        deleteFeatureItemUseCase: DeleteFeatureItemUseCase
    ) {
        self.getFeatureItemsUseCase = getFeatureItemsUseCase
        self.updateFeatureItemUseCase = updateFeatureItemUseCase
        self.deleteFeatureItemUseCase = deleteFeatureItemUseCase
        
        handleEvent(.loadItems)
    }
    
    func handleEvent(_ event: ViewEvent) {
        switch event {
        case .loadItems:
            loadItems()
        case .refresh:
            refresh()
        case .itemTapped(let item):
            selectItem(item)
        case .searchQueryChanged(let query):
            updateSearchQuery(query)
        case .filterChanged(let filterType):
            updateFilter(filterType)
        case .updateItem(let item):
            updateItem(item)
        case .deleteItem(let itemId):
            deleteItem(itemId)
        case .showDialog(let show):
            showDialog(show)
        case .clearError:
            clearError()
        }
    }
    
    private func loadItems() {
        viewState = .loading
        
        Task {
            do {
                let items = try await getFeatureItemsUseCase.execute()
                viewData = viewData.copy(
                    items: items,
                    isRefreshing: false
                )
                viewState = .success(viewData)
            } catch {
                viewState = .error(FeatureError.from(error))
                viewData = viewData.copy(isRefreshing: false)
            }
        }
    }
    
    private func refresh() {
        viewData = viewData.copy(isRefreshing: true)
        viewState = .success(viewData)
        loadItems()
    }
    
    private func selectItem(_ item: FeatureItem) {
        viewData = viewData.copy(selectedItem: item)
        viewState = .success(viewData)
    }
    
    private func updateSearchQuery(_ query: String) {
        viewData = viewData.copy(searchQuery: query)
        viewState = .success(viewData)
    }
    
    private func updateFilter(_ filterType: FilterType) {
        viewData = viewData.copy(filterType: filterType)
        viewState = .success(viewData)
    }
    
    private func updateItem(_ item: FeatureItem) {
        viewState = .loading
        
        Task {
            do {
                try await updateFeatureItemUseCase.execute(item)
                loadItems() // Reload to get updated data
            } catch {
                viewState = .error(FeatureError.from(error))
            }
        }
    }
    
    private func deleteItem(_ itemId: String) {
        viewState = .loading
        
        Task {
            do {
                try await deleteFeatureItemUseCase.execute(itemId)
                loadItems() // Reload to get updated data
            } catch {
                viewState = .error(FeatureError.from(error))
            }
        }
    }
    
    private func showDialog(_ show: Bool) {
        viewData = viewData.copy(showDialog: show)
        viewState = .success(viewData)
    }
    
    private func clearError() {
        viewData = viewData.copy(errorMessage: nil)
        viewState = .success(viewData)
    }
    
    // ViewEvent enum (equivalent to Android ValidationEvent)
    enum ViewEvent {
        case loadItems
        case refresh
        case itemTapped(FeatureItem)
        case searchQueryChanged(String)
        case filterChanged(FilterType)
        case updateItem(FeatureItem)
        case deleteItem(String)
        case showDialog(Bool)
        case clearError
    }
}

// Extension for FeatureViewData copy functionality
extension FeatureViewData {
    func copy(
        items: [FeatureItem]? = nil,
        selectedItem: FeatureItem?? = nil,
        isRefreshing: Bool? = nil,
        searchQuery: String? = nil,
        filterType: FilterType? = nil,
        showDialog: Bool? = nil,
        errorMessage: String?? = nil
    ) -> FeatureViewData {
        FeatureViewData(
            items: items ?? self.items,
            selectedItem: selectedItem ?? self.selectedItem,
            isRefreshing: isRefreshing ?? self.isRefreshing,
            searchQuery: searchQuery ?? self.searchQuery,
            filterType: filterType ?? self.filterType,
            showDialog: showDialog ?? self.showDialog,
            errorMessage: errorMessage ?? self.errorMessage
        )
    }
}

// Extension for error mapping
extension FeatureError {
    static func from(_ error: Error) -> FeatureError {
        if let featureError = error as? FeatureError {
            return featureError
        } else if error is URLError {
            return .networkError
        } else {
            return .unknownError(error.localizedDescription)
        }
    }
}
```

## view state hoisting template

```swift
// Main View (Stateful) - equivalent to Android Screen with ViewModel
struct FeatureView: View {
    @StateObject private var viewModel: FeatureViewModel
    let onNavigateToDetail: (String) -> Void
    let onNavigateBack: () -> Void
    
    init(
        viewModel: FeatureViewModel,
        onNavigateToDetail: @escaping (String) -> Void,
        onNavigateBack: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onNavigateToDetail = onNavigateToDetail
        self.onNavigateBack = onNavigateBack
    }
    
    var body: some View {
        FeatureContentView(
            viewState: viewModel.viewState,
            viewData: viewModel.viewData,
            onEvent: viewModel.handleEvent,
            onNavigateToDetail: onNavigateToDetail,
            onNavigateBack: onNavigateBack
        )
    }
}

// Stateless Content View
struct FeatureContentView: View {
    let viewState: FeatureViewState
    let viewData: FeatureViewData
    let onEvent: (FeatureViewModel.ViewEvent) -> Void
    let onNavigateToDetail: (String) -> Void
    let onNavigateBack: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    text: viewData.searchQuery,
                    onTextChanged: { query in
                        onEvent(.searchQueryChanged(query))
                    }
                )
                .padding(.horizontal)
                
                // Filter Tabs
                FilterTabsView(
                    selectedFilter: viewData.filterType,
                    onFilterChanged: { filter in
                        onEvent(.filterChanged(filter))
                    }
                )
                
                // Content based on view state
                switch viewState {
                case .idle:
                    Spacer()
                    
                case .loading:
                    LoadingContentView()
                    
                case .success(let data):
                    if data.items.isEmpty {
                        EmptyContentView()
                    } else {
                        FeatureContentListView(
                            items: data.items,
                            selectedItem: data.selectedItem,
                            onItemTapped: { item in
                                onEvent(.itemTapped(item))
                                onNavigateToDetail(item.id)
                            },
                            onItemUpdate: { item in
                                onEvent(.updateItem(item))
                            },
                            onItemDelete: { itemId in
                                onEvent(.deleteItem(itemId))
                            }
                        )
                    }
                    
                case .error(let error):
                    ErrorContentView(
                        error: error,
                        onRetry: {
                            onEvent(.loadItems)
                        }
                    )
                }
            }
            .navigationTitle("Feature")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        onNavigateBack()
                    }
                }
            }
            .refreshable {
                onEvent(.refresh)
            }
            .alert("Confirm Action", isPresented: .constant(viewData.showDialog)) {
                Button("Confirm") {
                    onEvent(.showDialog(false))
                }
                Button("Cancel", role: .cancel) {
                    onEvent(.showDialog(false))
                }
            } message: {
                Text("Are you sure you want to perform this action?")
            }
        }
    }
}

// Supporting Views
struct SearchBarView: View {
    let text: String
    let onTextChanged: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search items...", text: .constant(text))
                .onChange(of: text) { newValue in
                    onTextChanged(newValue)
                }
            
            if !text.isEmpty {
                Button(action: { onTextChanged("") }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterTabsView: View {
    let selectedFilter: FilterType
    let onFilterChanged: (FilterType) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Button(action: { onFilterChanged(filter) }) {
                        Text(filter.rawValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? Color.blue : Color.clear
                            )
                            .foregroundColor(
                                selectedFilter == filter ? .white : .primary
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LoadingContentView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("Loading...")
            Spacer()
        }
    }
}

struct EmptyContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No items found")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Try adjusting your search or filter criteria")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

struct FeatureContentListView: View {
    let items: [FeatureItem]
    let selectedItem: FeatureItem?
    let onItemTapped: (FeatureItem) -> Void
    let onItemUpdate: (FeatureItem) -> Void
    let onItemDelete: (String) -> Void
    
    var body: some View {
        List(items) { item in
            FeatureItemRowView(
                item: item,
                isSelected: item == selectedItem,
                onTap: { onItemTapped(item) },
                onUpdate: { onItemUpdate(item) },
                onDelete: { onItemDelete(item.id) }
            )
        }
        .listStyle(PlainListStyle())
    }
}

struct FeatureItemRowView: View {
    let item: FeatureItem
    let isSelected: Bool
    let onTap: () -> Void
    let onUpdate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack {
                    Button(action: onUpdate) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            HStack {
                Label(
                    item.isActive ? "Active" : "Inactive",
                    systemImage: item.isActive ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.caption)
                .foregroundColor(item.isActive ? .green : .red)
                
                Spacer()
                
                Text(item.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .strokeBorder(
                    isSelected ? Color.blue : Color.clear,
                    lineWidth: 2
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct ErrorContentView: View {
    let error: FeatureError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Something went wrong")
                .font(.title2)
                .foregroundColor(.primary)
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}
```

## preview templates

```swift
// Success State Preview
#Preview(name: "Feature View - Success") {
    FeatureContentView(
        viewState: .success(FeatureViewData.mock),
        viewData: FeatureViewData.mock,
        onEvent: { _ in },
        onNavigateToDetail: { _ in },
        onNavigateBack: { }
    )
}

// Loading State Preview
#Preview(name: "Feature View - Loading") {
    FeatureContentView(
        viewState: .loading,
        viewData: FeatureViewData(),
        onEvent: { _ in },
        onNavigateToDetail: { _ in },
        onNavigateBack: { }
    )
}

// Error State Preview
#Preview(name: "Feature View - Error") {
    FeatureContentView(
        viewState: .error(.networkError),
        viewData: FeatureViewData(),
        onEvent: { _ in },
        onNavigateToDetail: { _ in },
        onNavigateBack: { }
    )
}

// Empty State Preview
#Preview(name: "Feature View - Empty") {
    FeatureContentView(
        viewState: .success(FeatureViewData()),
        viewData: FeatureViewData(),
        onEvent: { _ in },
        onNavigateToDetail: { _ in },
        onNavigateBack: { }
    )
}

// With Dialog Preview
#Preview(name: "Feature View - With Dialog") {
    let viewData = FeatureViewData.mock.copy(showDialog: true)
    return FeatureContentView(
        viewState: .success(viewData),
        viewData: viewData,
        onEvent: { _ in },
        onNavigateToDetail: { _ in },
        onNavigateBack: { }
    )
}

// Individual Component Previews
#Preview(name: "Feature Item Row") {
    FeatureItemRowView(
        item: FeatureViewData.mock.items.first!,
        isSelected: true,
        onTap: { },
        onUpdate: { },
        onDelete: { }
    )
    .padding()
}

#Preview(name: "Search Bar") {
    SearchBarView(
        text: "sample search",
        onTextChanged: { _ in }
    )
    .padding()
}

#Preview(name: "Filter Tabs") {
    FilterTabsView(
        selectedFilter: .active,
        onFilterChanged: { _ in }
    )
}
```

## use case template

```swift
// Use Case Protocol
protocol GetFeatureItemsUseCase {
    func execute() async throws -> [FeatureItem]
}

protocol UpdateFeatureItemUseCase {
    func execute(_ item: FeatureItem) async throws
}

protocol DeleteFeatureItemUseCase {
    func execute(_ itemId: String) async throws
}

// Use Case Implementation
final class GetFeatureItemsUseCaseImpl: GetFeatureItemsUseCase {
    private let repository: FeatureRepository
    
    init(repository: FeatureRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [FeatureItem] {
        do {
            return try await repository.getFeatureItems()
        } catch {
            throw FeatureError.from(error)
        }
    }
}

final class UpdateFeatureItemUseCaseImpl: UpdateFeatureItemUseCase {
    private let repository: FeatureRepository
    
    init(repository: FeatureRepository) {
        self.repository = repository
    }
    
    func execute(_ item: FeatureItem) async throws {
        do {
            try await repository.updateFeatureItem(item)
        } catch {
            throw FeatureError.from(error)
        }
    }
}

final class DeleteFeatureItemUseCaseImpl: DeleteFeatureItemUseCase {
    private let repository: FeatureRepository
    
    init(repository: FeatureRepository) {
        self.repository = repository
    }
    
    func execute(_ itemId: String) async throws {
        do {
            try await repository.deleteFeatureItem(itemId)
        } catch {
            throw FeatureError.from(error)
        }
    }
}
```

## repository template

```swift
// Repository Protocol
protocol FeatureRepository {
    func getFeatureItems() async throws -> [FeatureItem]
    func updateFeatureItem(_ item: FeatureItem) async throws
    func deleteFeatureItem(_ itemId: String) async throws
    func getFeatureItemsStream() -> AsyncStream<[FeatureItem]>
}

// Repository Implementation
final class FeatureRepositoryImpl: FeatureRepository {
    private let localDataSource: FeatureLocalDataSource
    private let remoteDataSource: FeatureRemoteDataSource
    
    init(
        localDataSource: FeatureLocalDataSource,
        remoteDataSource: FeatureRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func getFeatureItems() async throws -> [FeatureItem] {
        do {
            // Try to get remote data first
            let remoteItems = try await remoteDataSource.fetchItems()
            
            // Save to local storage
            try await localDataSource.saveItems(remoteItems)
            
            return remoteItems
        } catch {
            // Fallback to local data if remote fails
            do {
                return try await localDataSource.loadItems()
            } catch {
                throw FeatureError.dataNotFound
            }
        }
    }
    
    func updateFeatureItem(_ item: FeatureItem) async throws {
        // Update local first
        try await localDataSource.updateItem(item)
        
        do {
            // Sync with remote
            try await remoteDataSource.updateItem(item)
        } catch {
            // Handle sync failure - could implement retry logic
            throw FeatureError.networkError
        }
    }
    
    func deleteFeatureItem(_ itemId: String) async throws {
        // Delete local first
        try await localDataSource.deleteItem(itemId)
        
        do {
            // Sync with remote
            try await remoteDataSource.deleteItem(itemId)
        } catch {
            // Handle sync failure
            throw FeatureError.networkError
        }
    }
    
    func getFeatureItemsStream() -> AsyncStream<[FeatureItem]> {
        AsyncStream { continuation in
            Task {
                do {
                    // Start with local data
                    let localItems = try await localDataSource.loadItems()
                    continuation.yield(localItems)
                    
                    // Then try to get fresh data from remote
                    let remoteItems = try await remoteDataSource.fetchItems()
                    try await localDataSource.saveItems(remoteItems)
                    continuation.yield(remoteItems)
                    
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}

// Data Source Protocols
protocol FeatureLocalDataSource {
    func loadItems() async throws -> [FeatureItem]
    func saveItems(_ items: [FeatureItem]) async throws
    func updateItem(_ item: FeatureItem) async throws
    func deleteItem(_ itemId: String) async throws
}

protocol FeatureRemoteDataSource {
    func fetchItems() async throws -> [FeatureItem]
    func updateItem(_ item: FeatureItem) async throws
    func deleteItem(_ itemId: String) async throws
}
```

## navigation templates

### coordinator protocol

```swift
// Simple Coordinator Protocol
protocol Coordinator: ObservableObject {
    associatedtype Destination: Hashable
    
    var navigationPath: NavigationPath { get set }
    
    func navigate(to destination: Destination)
    func goBack()
    func popToRoot()
}

// App Coordinator Implementation
@MainActor
final class AppCoordinator: Coordinator {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to destination: AppDestination) {
        navigationPath.append(destination)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate to appropriate destination
        if let destination = AppDestination.from(url) {
            navigate(to: destination)
        }
    }
}
```

### destination definitions

```swift
// App Destinations
enum AppDestination: Hashable, Codable {
    case home
    case settings
    case feature(FeatureDestination)
    case profile(ProfileDestination)
    
    // Deep linking support
    static func from(_ url: URL) -> AppDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        switch components.path {
        case "/feature":
            if let itemId = components.queryItems?.first(where: { $0.name == "itemId" })?.value {
                return .feature(.detail(itemId: itemId))
            }
            return .feature(.list)
        case "/profile":
            if let userId = components.queryItems?.first(where: { $0.name == "userId" })?.value {
                return .profile(.detail(userId: userId))
            }
            return .profile(.list)
        default:
            return .home
        }
    }
}

// Feature Destinations
enum FeatureDestination: Hashable, Codable {
    case list
    case detail(itemId: String)
    case edit(itemId: String)
    case create
    
    var analyticsKey: String {
        switch self {
        case .list: return "feature_list"
        case .detail(let itemId): return "feature_detail_\(itemId)"
        case .edit(let itemId): return "feature_edit_\(itemId)"
        case .create: return "feature_create"
        }
    }
}

// Profile Destinations
enum ProfileDestination: Hashable, Codable {
    case list
    case detail(userId: String)
    case edit(userId: String)
    case settings
    
    var shareUrl: String? {
        switch self {
        case .detail(let userId):
            return "https://myapp.com/profile?userId=\(userId)"
        default:
            return nil
        }
    }
}
```

### app integration

```swift
// App.swift - Main app with DI setup
@main
struct MyApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var container = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(container)
                .onOpenURL { url in
                    coordinator.handleDeepLink(url)
                }
        }
    }
}

// ContentView.swift - Main navigation view
struct ContentView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var container: DIContainer
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            // Root view
            HomeView(
                viewModel: container.resolve(HomeViewModel.self),
                onNavigateToFeature: {
                    coordinator.navigate(to: .feature(.list))
                },
                onNavigateToProfile: {
                    coordinator.navigate(to: .profile(.list))
                }
            )
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .home:
            HomeView(
                viewModel: container.resolve(HomeViewModel.self),
                onNavigateToFeature: {
                    coordinator.navigate(to: .feature(.list))
                },
                onNavigateToProfile: {
                    coordinator.navigate(to: .profile(.list))
                }
            )
            
        case .settings:
            SettingsView(
                viewModel: container.resolve(SettingsViewModel.self)
            )
            
        case .feature(let featureDestination):
            featureDestinationView(for: featureDestination)
            
        case .profile(let profileDestination):
            profileDestinationView(for: profileDestination)
        }
    }
    
    @ViewBuilder
    private func featureDestinationView(for destination: FeatureDestination) -> some View {
        switch destination {
        case .list:
            FeatureView(
                viewModel: container.resolve(FeatureViewModel.self),
                onNavigateToDetail: { itemId in
                    coordinator.navigate(to: .feature(.detail(itemId: itemId)))
                },
                onNavigateBack: {
                    coordinator.goBack()
                }
            )
            
        case .detail(let itemId):
            FeatureDetailView(
                itemId: itemId,
                viewModel: container.resolve(FeatureDetailViewModel.self),
                onNavigateToEdit: { itemId in
                    coordinator.navigate(to: .feature(.edit(itemId: itemId)))
                },
                onNavigateBack: {
                    coordinator.goBack()
                }
            )
            
        case .edit(let itemId):
            FeatureEditView(
                itemId: itemId,
                viewModel: container.resolve(FeatureEditViewModel.self),
                onSaveCompleted: {
                    coordinator.goBack()
                },
                onNavigateBack: {
                    coordinator.goBack()
                }
            )
            
        case .create:
            FeatureCreateView(
                viewModel: container.resolve(FeatureCreateViewModel.self),
                onCreateCompleted: { itemId in
                    coordinator.navigate(to: .feature(.detail(itemId: itemId)))
                },
                onNavigateBack: {
                    coordinator.goBack()
                }
            )
        }
    }
    
    @ViewBuilder
    private func profileDestinationView(for destination: ProfileDestination) -> some View {
        switch destination {
        case .list:
            ProfileListView(
                viewModel: container.resolve(ProfileListViewModel.self),
                onProfileSelected: { userId in
                    coordinator.navigate(to: .profile(.detail(userId: userId)))
                }
            )
            
        case .detail(let userId):
            ProfileDetailView(
                userId: userId,
                viewModel: container.resolve(ProfileDetailViewModel.self),
                onNavigateToEdit: { userId in
                    coordinator.navigate(to: .profile(.edit(userId: userId)))
                }
            )
            
        case .edit(let userId):
            ProfileEditView(
                userId: userId,
                viewModel: container.resolve(ProfileEditViewModel.self),
                onSaveCompleted: {
                    coordinator.goBack()
                }
            )
            
        case .settings:
            ProfileSettingsView(
                viewModel: container.resolve(ProfileSettingsViewModel.self)
            )
        }
    }
}
```

## dependency injection template

```swift
// Simple DI Container
@MainActor
final class DIContainer: ObservableObject {
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    init() {
        registerDependencies()
    }
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // Check for existing instance
        if let service = services[key] as? T {
            return service
        }
        
        // Create new instance from factory
        if let factory = factories[key] {
            let instance = factory() as! T
            services[key] = instance
            return instance
        }
        
        fatalError("Service \(type) not registered")
    }
    
    private func registerDependencies() {
        // Register Use Cases
        register(GetFeatureItemsUseCase.self) {
            GetFeatureItemsUseCaseImpl(
                repository: self.resolve(FeatureRepository.self)
            )
        }
        
        register(UpdateFeatureItemUseCase.self) {
            UpdateFeatureItemUseCaseImpl(
                repository: self.resolve(FeatureRepository.self)
            )
        }
        
        register(DeleteFeatureItemUseCase.self) {
            DeleteFeatureItemUseCaseImpl(
                repository: self.resolve(FeatureRepository.self)
            )
        }
        
        // Register Repositories
        register(FeatureRepository.self) {
            FeatureRepositoryImpl(
                localDataSource: self.resolve(FeatureLocalDataSource.self),
                remoteDataSource: self.resolve(FeatureRemoteDataSource.self)
            )
        }
        
        // Register Data Sources
        register(FeatureLocalDataSource.self) {
            FeatureLocalDataSourceImpl()
        }
        
        register(FeatureRemoteDataSource.self) {
            FeatureRemoteDataSourceImpl()
        }
        
        // Register ViewModels
        register(FeatureViewModel.self) {
            FeatureViewModel(
                getFeatureItemsUseCase: self.resolve(GetFeatureItemsUseCase.self),
                updateFeatureItemUseCase: self.resolve(UpdateFeatureItemUseCase.self),
                deleteFeatureItemUseCase: self.resolve(DeleteFeatureItemUseCase.self)
            )
        }
        
        register(HomeViewModel.self) {
            HomeViewModel()
        }
        
        register(SettingsViewModel.self) {
            SettingsViewModel()
        }
    }
}
```

## testing templates

### viewmodel test

```swift
import XCTest
@testable import MyApp

@MainActor
final class FeatureViewModelTests: XCTestCase {
    private var viewModel: FeatureViewModel!
    private var mockGetItemsUseCase: MockGetFeatureItemsUseCase!
    private var mockUpdateItemUseCase: MockUpdateFeatureItemUseCase!
    private var mockDeleteItemUseCase: MockDeleteFeatureItemUseCase!
    
    override func setUp() {
        super.setUp()
        mockGetItemsUseCase = MockGetFeatureItemsUseCase()
        mockUpdateItemUseCase = MockUpdateFeatureItemUseCase()
        mockDeleteItemUseCase = MockDeleteFeatureItemUseCase()
        
        viewModel = FeatureViewModel(
            getFeatureItemsUseCase: mockGetItemsUseCase,
            updateFeatureItemUseCase: mockUpdateItemUseCase,
            deleteFeatureItemUseCase: mockDeleteItemUseCase
        )
    }
    
    func testLoadItems_Success() async {
        // Given
        let expectedItems = [
            FeatureItem(
                id: "1",
                title: "Test Item",
                description: "Test Description",
                isActive: true,
                createdAt: Date()
            )
        ]
        mockGetItemsUseCase.result = .success(expectedItems)
        
        // When
        viewModel.handleEvent(.loadItems)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(viewModel.viewData.items, expectedItems)
        XCTAssertFalse(viewModel.viewData.isRefreshing)
        
        if case .success(let data) = viewModel.viewState {
            XCTAssertEqual(data.items, expectedItems)
        } else {
            XCTFail("Expected success state")
        }
    }
    
    func testLoadItems_Failure() async {
        // Given
        mockGetItemsUseCase.result = .failure(FeatureError.networkError)
        
        // When
        viewModel.handleEvent(.loadItems)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        if case .error(let error) = viewModel.viewState {
            XCTAssertEqual(error, FeatureError.networkError)
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testItemTapped_ShouldSelectItem() {
        // Given
        let testItem = FeatureItem(
            id: "1",
            title: "Test",
            description: "Test",
            isActive: true,
            createdAt: Date()
        )
        
        // When
        viewModel.handleEvent(.itemTapped(testItem))
        
        // Then
        XCTAssertEqual(viewModel.viewData.selectedItem, testItem)
        
        if case .success(let data) = viewModel.viewState {
            XCTAssertEqual(data.selectedItem, testItem)
        } else {
            XCTFail("Expected success state")
        }
    }
    
    func testSearchQueryChanged_ShouldUpdateQuery() {
        // Given
        let searchQuery = "test query"
        
        // When
        viewModel.handleEvent(.searchQueryChanged(searchQuery))
        
        // Then
        XCTAssertEqual(viewModel.viewData.searchQuery, searchQuery)
    }
}

// Mock Use Cases
final class MockGetFeatureItemsUseCase: GetFeatureItemsUseCase {
    var result: Result<[FeatureItem], Error> = .success([])
    
    func execute() async throws -> [FeatureItem] {
        switch result {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
}

final class MockUpdateFeatureItemUseCase: UpdateFeatureItemUseCase {
    var result: Result<Void, Error> = .success(())
    
    func execute(_ item: FeatureItem) async throws {
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

final class MockDeleteFeatureItemUseCase: DeleteFeatureItemUseCase {
    var result: Result<Void, Error> = .success(())
    
    func execute(_ itemId: String) async throws {
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
```

### view test

```swift
import XCTest
import SwiftUI
@testable import MyApp

final class FeatureViewTests: XCTestCase {
    
    func testFeatureContentView_LoadingState() {
        // Given
        let viewState: FeatureViewState = .loading
        let viewData = FeatureViewData()
        
        // Create the view
        let view = FeatureContentView(
            viewState: viewState,
            viewData: viewData,
            onEvent: { _ in },
            onNavigateToDetail: { _ in },
            onNavigateBack: { }
        )
        
        // Test would verify loading indicator is shown
        // Using ViewInspector or similar testing framework
    }
    
    func testFeatureContentView_SuccessState() {
        // Given
        let mockData = FeatureViewData.mock
        let viewState: FeatureViewState = .success(mockData)
        
        // Create the view
        let view = FeatureContentView(
            viewState: viewState,
            viewData: mockData,
            onEvent: { _ in },
            onNavigateToDetail: { _ in },
            onNavigateBack: { }
        )
        
        // Test would verify items are displayed
        // Using ViewInspector or similar testing framework
    }
    
    func testFeatureContentView_ErrorState() {
        // Given
        let viewState: FeatureViewState = .error(.networkError)
        let viewData = FeatureViewData()
        
        // Create the view
        let view = FeatureContentView(
            viewState: viewState,
            viewData: viewData,
            onEvent: { _ in },
            onNavigateToDetail: { _ in },
            onNavigateBack: { }
        )
        
        // Test would verify error message and retry button are shown
        // Using ViewInspector or similar testing framework
    }
}
```

# anti patterns

## general

- Don't use massive view controllers or view models
- Avoid deep nesting in SwiftUI view hierarchies
- Don't perform heavy operations on the main thread
- Avoid tight coupling between modules
- Don't ignore error handling
- Avoid force unwrapping optionals
- Don't create unnecessary state variables
- Avoid mixing UIKit and SwiftUI unnecessarily

## viewstate viewdata

- Don't mix loading/error states with actual data in ViewData
- Avoid complex logic in ViewData computed properties
- Don't expose mutable state directly from ViewModel
- Avoid nullable ViewState - use enum instead
- Don't forget to provide mock data for previews
- Avoid heavy objects in mock data

## viewevent pattern

- Don't create events for every small UI change
- Avoid complex logic in handleEvent function
- Don't ignore error handling in event processing
- Avoid nested switch statements in handleEvent
- Don't create events that depend on previous events

## swiftui

- Don't use @StateObject when @ObservedObject is appropriate
- Avoid unnecessary view updates with proper state management
- Don't ignore view lifecycle in SwiftUI
- Avoid complex @ViewBuilder functions
- Don't use GeometryReader unless necessary
- Avoid retain cycles in closure captures

## async await

- Don't use Task.detached() unless absolutely necessary
- Avoid blocking the main actor with heavy computations
- Don't ignore task cancellation
- Avoid creating unnecessary tasks
- Don't use async/await for CPU-bound operations on main actor
- Avoid memory leaks by not handling task lifecycle properly

## navigation

- Don't create complex navigation state in destinations
- Avoid passing coordinator directly to ViewModels
- Don't ignore proper lifecycle handling in navigation
- Avoid hardcoded navigation paths
- Don't create circular navigation dependencies

# module dependencies

## allowed

- App -> Feature modules
- Feature -> Core modules
- Core -> System frameworks
- Feature -> Domain protocols
- Data -> Domain protocols

## forbidden

- Domain -> Data/Presentation
- Core -> Feature modules
- Feature -> Feature (direct)
- Circular dependencies

# xcode config

## project settings

- Use Swift Package Manager for dependencies
- Configure build variants properly
- Use Xcode build cache
- Implement proper signing configuration
- Configure schemes for different environments

## swift compiler

- Enable strict concurrency checking
- Use all appropriate compiler warnings
- Configure SwiftLint rules
- Enable code coverage reporting
- Use SwiftFormat for consistent formatting

# git workflow

- Use conventional commits
- Create feature branches for new features
- Write meaningful commit messages
- Use pull requests for code review
- Maintain clean git history

# ci cd

- Run unit tests on every commit
- Perform static analysis with SwiftLint
- Generate test coverage reports
- Build and test on multiple iOS versions
- Automate TestFlight deployment
- Use Fastlane for automation

## build
  
### commands
- clean: "xcodebuild clean"
- build: "swift build"
- test: "swift test"
- archive: "xcodebuild archive"
- package_resolve: "swift package resolve"

### code_style
- swiftlint: true
- indent_size: 4
- max_line_length: 120
- force_unwrapping: false
