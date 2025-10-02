//
//  InspectorScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI

struct InspectorScreen: View {
    @ObservedObject var viewModel: InspectorViewModel
    @State private var showingFilters = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                contentView
            }
            .navigationTitle("Network Inspector")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filters") {
                        showingFilters.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                filtersView
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
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading API calls...")
                    .foregroundColor(.secondary)
                    .padding(.top)
            }

        case .success(let uiData):
            successContent(uiData: uiData)

        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)

                Text("Error Loading Data")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    viewModel.onEvent(.RefreshApiCalls)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func successContent(uiData: InspectorUiData) -> some View {
        VStack(spacing: 0) {
            // Search and Filter Header
            headerSection(uiData: uiData)

            // Statistics Summary
            statsSection(uiData: uiData)

            // API Calls List
            if uiData.filteredApiCalls.isEmpty {
                emptyStateView(uiData: uiData)
            } else {
                apiCallsList(uiData: uiData)
            }
        }
        .refreshable {
            viewModel.onEvent(.RefreshApiCalls)
        }
    }

    private func headerSection(uiData: InspectorUiData) -> some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search API calls...", text: Binding(
                    get: { uiData.searchQuery },
                    set: { viewModel.onEvent(.SearchQueryChanged($0)) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())

                if !uiData.searchQuery.isEmpty {
                    Button("Clear") {
                        viewModel.onEvent(.SearchQueryChanged(""))
                    }
                    .foregroundColor(.blue)
                }
            }

            // Method Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All", isSelected: uiData.selectedMethod == nil) {
                        viewModel.onEvent(.MethodFilterChanged(nil))
                    }

                    ForEach(["GET", "POST", "PUT", "DELETE", "PATCH"], id: \\.self) { method in
                        filterChip(title: method, isSelected: uiData.selectedMethod == method) {
                            viewModel.onEvent(.MethodFilterChanged(method))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private func statsSection(uiData: InspectorUiData) -> some View {
        HStack {
            statItem(title: "Total", value: "\\(uiData.totalCalls)", color: .blue)
            Divider()
            statItem(title: "Success", value: "\\(uiData.successfulCalls)", color: .green)
            Divider()
            statItem(title: "Failed", value: "\\(uiData.failedCalls)", color: .red)
            Divider()
            statItem(title: "Filtered", value: "\\(uiData.filteredApiCalls.count)", color: .orange)
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func emptyStateView(uiData: InspectorUiData) -> some View {
        VStack(spacing: 16) {
            Image(systemName: uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "network.slash" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "No API Calls" : "No Results Found")
                .font(.headline)
                .foregroundColor(.gray)

            Text(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "API calls will appear here when your app makes them" : "Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                if !(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil) {
                    Button("Clear Filters") {
                        viewModel.onEvent(.ClearFilters)
                    }
                    .buttonStyle(.bordered)
                }

                Button("Make Test Call") {
                    viewModel.onEvent(.PerformRandomApiCall)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func apiCallsList(uiData: InspectorUiData) -> some View {
        List {
            if uiData.isRefreshing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Refreshing...")
                        .foregroundColor(.secondary)
                }
                .listRowSeparator(.hidden)
            }

            ForEach(uiData.filteredApiCalls) { apiCall in
                NavigationLink(destination: ApiCallDetailView(apiCall: apiCall)) {
                    ApiCallRowView(apiCall: apiCall)
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }

    private var filtersView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Filter Options")
                    .font(.title2)
                    .fontWeight(.bold)

                if case .success(let uiData) = viewModel.uiState {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HTTP Methods")
                            .font(.headline)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(["GET", "POST", "PUT", "DELETE", "PATCH"], id: \\.self) { method in
                                filterChip(title: method, isSelected: uiData.selectedMethod == method) {
                                    let newMethod = uiData.selectedMethod == method ? nil : method
                                    viewModel.onEvent(.MethodFilterChanged(newMethod))
                                }
                            }
                        }
                    }
                }

                Spacer()

                Button("Clear All Filters") {
                    viewModel.onEvent(.ClearFilters)
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                }
            }
        }
    }
}

struct ApiCallRowView: View {
    let apiCall: ApiCallResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // HTTP Method Badge
                methodBadge

                // Status Badge
                statusBadge

                Spacer()

                // Duration
                Text("\\(apiCall.duration)ms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // URL
            Text(apiCall.url)
                .font(.body)
                .lineLimit(2)

            // Host and Timestamp
            HStack {
                Text(apiCall.host)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(apiCall.timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var methodBadge: some View {
        Text(apiCall.method)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(methodColor.opacity(0.2))
            .foregroundColor(methodColor)
            .cornerRadius(4)
    }

    private var statusBadge: some View {
        Text("\\(apiCall.statusCode)")
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }

    private var methodColor: Color {
        switch apiCall.method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .gray
        }
    }

    private var statusColor: Color {
        switch apiCall.statusCode {
        case 200..<300: return .green
        case 300..<400: return .yellow
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
}

struct ApiCallDetailView: View {
    let apiCall: ApiCallResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Request Section
                requestSection

                // Response Section
                responseSection

                // Timing Section
                timingSection
            }
            .padding()
        }
        .navigationTitle("Call Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var requestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Request")
                .font(.headline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                detailRow(title: "Method", value: apiCall.method)
                detailRow(title: "URL", value: apiCall.url)
                detailRow(title: "Host", value: apiCall.host)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Response")
                .font(.headline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                detailRow(title: "Status Code", value: "\\(apiCall.statusCode)")
                detailRow(title: "Success", value: apiCall.isSuccess ? "Yes" : "No")
                if let error = apiCall.error {
                    detailRow(title: "Error", value: error)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timing")
                .font(.headline)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                let startDate = Date(timeIntervalSince1970: TimeInterval(apiCall.startTime) / 1000.0)
                let endDate = Date(timeIntervalSince1970: TimeInterval(apiCall.endTime) / 1000.0)

                detailRow(title: "Start Time", value: DateFormatter.detailFormatter.string(from: startDate))
                detailRow(title: "End Time", value: DateFormatter.detailFormatter.string(from: endDate))
                detailRow(title: "Duration", value: "\\(apiCall.duration)ms")
                detailRow(title: "Timestamp", value: apiCall.timestamp)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

extension DateFormatter {
    static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}

#Preview {
    InspectorScreen(viewModel: InspectorViewModel())
}