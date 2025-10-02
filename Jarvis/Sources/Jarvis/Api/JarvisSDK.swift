import Foundation
import JarvisPlatform
import JarvisInspectorDomain
import SwiftUI
import Combine

/// Main entry point for the Jarvis SDK
@MainActor
public final class JarvisSDK: ObservableObject {

    // MARK: - Singleton
    public static let shared = JarvisSDK()

    // MARK: - Published Properties
    @Published public private(set) var isActive = false
    @Published public private(set) var isShowing = false
    @Published public private(set) var isInitialized = false

    // MARK: - Private Properties
    private var configuration = JarvisConfig()
    private let shakeDetector = ShakeDetector.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Internal State
    private var previousActiveState = false
    private var previousShowingState = false

    // MARK: - Initialization
    private init() {
        setupShakeDetection()
    }

    // MARK: - Public API

    /// Initialize the Jarvis SDK with configuration
    /// - Parameter config: Configuration for the SDK
    public func initialize(config: JarvisConfig = JarvisConfig()) async {
        if !isInitialized {
            configuration = config

            // Configure logging
            JarvisLogger.shared.configure(enableLogging: config.enableDebugLogging)

            await performInitialization()

            isShowing = false
            isInitialized = true

            JarvisLogger.shared.info("Jarvis SDK initialized successfully")
        } else {
            // Store previous states for restoration
            previousActiveState = isActive
            previousShowingState = isShowing

            // Update configuration
            configuration = config
            JarvisLogger.shared.configure(enableLogging: config.enableDebugLogging)

            JarvisLogger.shared.info("Jarvis SDK re-initialized with new configuration")
        }
    }

    /// Initialize the SDK asynchronously
    /// - Parameters:
    ///   - config: Configuration for the SDK
    ///   - completion: Optional completion handler
    public func initializeAsync(
        config: JarvisConfig = JarvisConfig(),
        completion: (() -> Void)? = nil
    ) {
        Task {
            await initialize(config: config)
            completion?()
        }
    }

    /// Activate the SDK (show FAB and enable features)
    public func activate() {
        guard isInitialized else {
            JarvisLogger.shared.warning("Cannot activate: SDK not initialized")
            return
        }

        isActive = true

        if configuration.enableShakeDetection {
            shakeDetector.startDetection()
        }

        JarvisLogger.shared.info("Jarvis SDK activated")
    }

    /// Deactivate the SDK (hide all UI and disable features)
    public func deactivate() {
        isActive = false
        hideOverlay()

        if configuration.enableShakeDetection {
            shakeDetector.stopDetection()
        }

        JarvisLogger.shared.info("Jarvis SDK deactivated")
    }

    /// Toggle SDK activation state
    /// - Returns: New activation state
    @discardableResult
    public func toggle() -> Bool {
        if isActive {
            deactivate()
        } else {
            activate()
        }
        return isActive
    }

    /// Show the main Jarvis overlay
    public func showOverlay() {
        guard isActive else {
            JarvisLogger.shared.warning("Cannot show overlay: SDK not active")
            return
        }

        isShowing = true
        JarvisLogger.shared.debug("Jarvis overlay shown")
    }

    /// Hide the main Jarvis overlay
    public func hideOverlay() {
        isShowing = false
        JarvisLogger.shared.debug("Jarvis overlay hidden")
    }

    /// Dismiss and cleanup the SDK
    public func dismiss() {
        Task {
            await performCleanup()

            isShowing = false
            isActive = false
            isInitialized = false

            JarvisLogger.shared.info("Jarvis SDK dismissed")
        }
    }

    /// Get current configuration
    public func getConfiguration() -> JarvisConfig {
        return configuration
    }

    // MARK: - SwiftUI Integration

    /// Main Jarvis overlay view
    public func mainView() -> some View {
        JarvisMainView()
            .environmentObject(self)
    }

    // MARK: - Private Methods

    private func setupShakeDetection() {
        shakeDetector.setShakeHandler { [weak self] in
            Task { @MainActor in
                self?.handleShakeDetected()
            }
        }
    }

    private func handleShakeDetected() {
        guard configuration.enableShakeDetection else { return }

        #if DEBUG
        JarvisLogger.shared.debug("Shake detected - toggling Jarvis SDK")
        toggle()
        #endif
    }

    private func performInitialization() async {
        // Initialize core systems
        await initializeCore()

        // Initialize network inspection
        if configuration.networkInspection.enableNetworkLogging {
            await initializeNetworkInspection()
        }

        // Initialize preferences monitoring
        if configuration.preferences.enableUserDefaultsMonitoring {
            await initializePreferencesMonitoring()
        }

        // Restore previous states if re-initializing
        if previousActiveState {
            isActive = previousActiveState
        }
        if previousShowingState {
            isShowing = previousShowingState
        }
    }

    private func initializeCore() async {
        // TODO: Initialize core platform services
        JarvisLogger.shared.debug("Core systems initialized")
    }

    private func initializeNetworkInspection() async {
        // TODO: Initialize inspection monitoring
        JarvisLogger.shared.debug("Network inspection initialized")
    }

    private func initializePreferencesMonitoring() async {
        // TODO: Initialize preferences monitoring
        JarvisLogger.shared.debug("Preferences monitoring initialized")
    }

    private func performCleanup() async {
        // Stop network interception

        // Stop shake detection
        shakeDetector.stopDetection()

        // Clear subscriptions
        cancellables.removeAll()

        JarvisLogger.shared.debug("SDK cleanup completed")
    }
}

// MARK: - SwiftUI Extensions

/// SwiftUI ViewModifier to integrate Jarvis SDK with any view
public struct JarvisSDKModifier: ViewModifier {
    @StateObject private var jarvis = JarvisSDK.shared
    @State private var showingInspector = false

    let config: JarvisConfig

    public init(config: JarvisConfig = JarvisConfig()) {
        self.config = config
    }

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingInspector) {
                jarvis.mainView()
            }
            .onChange(of: jarvis.isShowing) { isShowing in
                showingInspector = isShowing
            }
            .onShake {
                if jarvis.isActive && config.enableShakeDetection {
                    jarvis.showOverlay()
                }
            }
            .task {
                await jarvis.initialize(config: config)

                #if DEBUG
                jarvis.activate()
                #endif
            }
    }
}

public extension View {
    /// Add Jarvis SDK integration to any SwiftUI view
    /// - Parameter config: Configuration for the SDK
    /// - Returns: View with Jarvis SDK integration
    func jarvisSDK(config: JarvisConfig = JarvisConfig()) -> some View {
        modifier(JarvisSDKModifier(config: config))
    }
}

// MARK: - Temporary Main View
// TODO: Replace with proper implementation from feature modules

internal struct JarvisMainView: View {
    @EnvironmentObject private var jarvis: JarvisSDK
    @State private var transactions: [NetworkTransaction] = []
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                DashboardView(jarvis: jarvis)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Dashboard")
                    }
                    .tag(0)

                // Network Inspector Tab
                NetworkInspectorView(transactions: transactions)
                    .tabItem {
                        Image(systemName: "network")
                        Text("Network")
                    }
                    .tag(1)

                // Preferences Tab
                PreferencesView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Preferences")
                    }
                    .tag(2)
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        jarvis.hideOverlay()
                    }
                }
            }
        }
        .onAppear {
            refreshTransactions()
        }
        .refreshable {
            refreshTransactions()
        }
    }

    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Dashboard"
        case 1: return "Network Inspector"
        case 2: return "Preferences"
        default: return "Jarvis SDK"
        }
    }

    private func refreshTransactions() {
        transactions = URLSessionInterceptor.shared.getAllTransactions()
    }
}

private struct DashboardView: View {
    let jarvis: JarvisSDK

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Jarvis SDK Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("iOS Network & Preferences Inspector")
                    .font(.headline)
                    .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    InfoRow(title: "Status", value: jarvis.isActive ? "Active" : "Inactive")
                    InfoRow(title: "Network Logging", value: jarvis.getConfiguration().networkInspection.enableNetworkLogging ? "Enabled" : "Disabled")
                    InfoRow(title: "Preferences Monitoring", value: jarvis.getConfiguration().preferences.enableUserDefaultsMonitoring ? "Enabled" : "Disabled")
                    InfoRow(title: "Shake Detection", value: jarvis.getConfiguration().enableShakeDetection ? "Enabled" : "Disabled")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Quick Actions
                VStack(spacing: 12) {
                    Button("Clear Network Data") {
                        URLSessionInterceptor.shared.clearAllTransactions()
                    }
                    .buttonStyle(.bordered)

                    Button("Test Network Request") {
                        performTestRequest()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }

    private func performTestRequest() {
        Task {
            do {
                let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
                let (_, _) = try await URLSession.shared.data(from: url)
            } catch {
                print("Test request failed: \(error)")
            }
        }
    }
}

private struct NetworkInspectorView: View {
    let transactions: [NetworkTransaction]

    var body: some View {
        List {
            if transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "network.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Network Requests")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Network requests will appear here when your app makes them")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .listRowSeparator(.hidden)
            } else {
                ForEach(transactions) { transaction in
                    NetworkTransactionRow(transaction: transaction)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

private struct NetworkTransactionRow: View {
    let transaction: NetworkTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // HTTP Method Badge
                Text(transaction.request.method.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(methodColor.opacity(0.2))
                    .foregroundColor(methodColor)
                    .cornerRadius(4)

                // Status Badge
                if let response = transaction.response {
                    Text("\(response.statusCode)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }

                Spacer()

                // Duration
                if let duration = transaction.duration {
                    Text("\(Int(duration * 1000))ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // URL
            Text(transaction.request.url)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(2)

            // Timestamp
            Text(transaction.startTime.timeAgoString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var methodColor: Color {
        switch transaction.request.method {
        case .GET: return .blue
        case .POST: return .green
        case .PUT: return .orange
        case .DELETE: return .red
        case .PATCH: return .purple
        default: return .gray
        }
    }

    private var statusColor: Color {
        guard let response = transaction.response else { return .gray }

        switch response.statusCode {
        case 200..<300: return .green
        case 300..<400: return .yellow
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
}

private struct PreferencesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Preferences Inspector")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Monitor UserDefaults and other preferences")
                    .font(.headline)
                    .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    Text("Coming Soon")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text("Preferences monitoring functionality will be implemented in the next phase")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
