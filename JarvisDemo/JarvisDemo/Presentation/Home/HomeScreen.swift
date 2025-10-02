//
//  HomeScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import Jarvis

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Content based on state
                    contentView

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Jarvis Demo")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.onEvent(.RefreshData)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.uiState {
        case .idle:
            Text("Loading...")
                .foregroundColor(.secondary)

        case .loading:
            ProgressView()
                .scaleEffect(1.5)

        case .success(let uiData):
            successContent(uiData: uiData)

        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)

                Text("Error")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    viewModel.onEvent(.RefreshData)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func successContent(uiData: HomeUiData) -> some View {
        VStack(spacing: 24) {
            // SDK Status Card
            statusCard(uiData: uiData)

            // Configuration Card
            configurationCard(uiData: uiData)

            // Quick Actions Card
            quickActionsCard(uiData: uiData)

            // Recent API Calls
            if !uiData.recentApiCalls.isEmpty {
                recentApiCallsCard(uiData: uiData)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            switch viewModel.uiState {
            case .success(let uiData):
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(uiData.isJarvisActive ? .green : .gray)
            default:
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }

            Text("Jarvis iOS SDK")
                .font(.title)
                .fontWeight(.bold)

            Text("Network & Preferences Inspector")
                .font(.subtitle)
                .foregroundColor(.secondary)
        }
    }

    private func statusCard(uiData: HomeUiData) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("SDK Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Circle()
                    .fill(uiData.isJarvisActive ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }

            Button(action: {
                viewModel.onEvent(.ToggleJarvisMode)
            }) {
                HStack {
                    Image(systemName: uiData.isJarvisActive ? "stop.circle" : "play.circle")
                    Text(uiData.isJarvisActive ? "Deactivate Jarvis" : "Activate Jarvis")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(uiData.isJarvisActive ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            VStack(spacing: 8) {
                infoRow(title: "Status", value: uiData.isJarvisActive ? "Active" : "Inactive")
                infoRow(title: "Network Logging", value: uiData.jarvisConfiguration.networkInspection.enableNetworkLogging ? "Enabled" : "Disabled")
                infoRow(title: "Preferences Monitoring", value: uiData.jarvisConfiguration.preferences.enableUserDefaultsMonitoring ? "Enabled" : "Disabled")
                infoRow(title: "Shake Detection", value: uiData.jarvisConfiguration.enableShakeDetection ? "Enabled" : "Disabled")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func configurationCard(uiData: HomeUiData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                configRow(icon: "network", title: "Network Inspection", description: "Monitor HTTP requests and responses")
                configRow(icon: "gearshape", title: "Preferences Monitoring", description: "Track UserDefaults and Keychain changes")
                configRow(icon: "iphone.shake", title: "Shake Detection", description: "Toggle SDK with device shake")
                configRow(icon: "bug", title: "Debug Logging", description: "Detailed SDK logging for development")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func quickActionsCard(uiData: HomeUiData) -> some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                Button(action: {
                    viewModel.onEvent(.PerformTestApiCall)
                }) {
                    HStack {
                        Image(systemName: "network")
                        Text("Make Test API Call")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }

                Button(action: {
                    viewModel.onEvent(.ClearData)
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear API Data")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }

                Button(action: {
                    viewModel.onEvent(.ShowJarvisOverlay)
                }) {
                    HStack {
                        Image(systemName: "eye")
                        Text("Show Jarvis Overlay")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func recentApiCallsCard(uiData: HomeUiData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent API Calls")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if uiData.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            VStack(spacing: 8) {
                ForEach(Array(uiData.recentApiCalls.prefix(5))) { apiCall in
                    apiCallRow(apiCall: apiCall)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func apiCallRow(apiCall: ApiCallResult) -> some View {
        HStack {
            // Method badge
            Text(apiCall.method)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(methodColor(for: apiCall.method).opacity(0.2))
                .foregroundColor(methodColor(for: apiCall.method))
                .cornerRadius(4)

            // Status badge
            Text("\\(apiCall.statusCode)")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor(for: apiCall.statusCode).opacity(0.2))
                .foregroundColor(statusColor(for: apiCall.statusCode))
                .cornerRadius(4)

            Spacer()

            // Duration
            Text("\\(apiCall.duration)ms")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func methodColor(for method: String) -> Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .gray
        }
    }

    private func statusColor(for statusCode: Int) -> Color {
        switch statusCode {
        case 200..<300: return .green
        case 300..<400: return .yellow
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func configRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    HomeScreen(viewModel: HomeViewModel())
}