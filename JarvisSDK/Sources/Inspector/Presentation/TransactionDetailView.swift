//
//  TransactionDetailView.swift
//  JarvisSDK
//
//  Detailed view for a network transaction with tabs
//

import SwiftUI
import JarvisDesignSystem
import JarvisDomain
import JarvisInspectorDomain
import JarvisCommon

/// Detail view for a network transaction with tabs (Overview, Request, Response)
struct TransactionDetailView: View {
    let transactionId: String
    @State private var transaction: NetworkTransaction?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: DSSpacing.none) {
            if isLoading {
                LoadingView()
            } else if let error = error {
                ErrorView(error: error, onRetry: loadTransaction)
            } else if let transaction = transaction {
                // Tab Bar
                TabBar(selectedTab: $selectedTab)

                // Tab Content
                TabView(selection: $selectedTab) {
                    OverviewTab(transaction: transaction)
                        .tag(0)

                    RequestTab(transaction: transaction)
                        .tag(1)

                    ResponseTab(transaction: transaction)
                        .tag(2)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
            } else {
                EmptyTransactionView()
            }
        }
        .background(DSColor.Extra.background0)
        .navigationTitle("Transaction Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            loadTransaction()
        }
    }

    private func loadTransaction() {
        isLoading = true
        error = nil

        Task {
            do {
                // Get use case from DI container
                let useCase = DependencyContainer.shared.resolve(GetNetworkTransactionUseCase.self)

                if let loadedTransaction = try await useCase.execute(transactionId) {
                    await MainActor.run {
                        self.transaction = loadedTransaction
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.error = NSError(domain: "TransactionNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Tab Bar

private struct TabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: DSSpacing.none) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                withAnimation { selectedTab = 0 }
            }

            TabButton(title: "Request", isSelected: selectedTab == 1) {
                withAnimation { selectedTab = 1 }
            }

            TabButton(title: "Response", isSelected: selectedTab == 2) {
                withAnimation { selectedTab = 2 }
            }
        }
        .background(DSColor.Extra.white)
        .overlay(
            Rectangle()
                .fill(DSColor.Neutral.neutral20)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
                Text(title)
                    .dsTextStyle(.bodyMedium)
                    .foregroundStyle(
                        isSelected ?
                            LinearGradient(
                                colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [DSColor.Neutral.neutral80, DSColor.Neutral.neutral80],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .dsPadding(.vertical, DSSpacing.xs)
                    .fontWeight(isSelected ? .bold : .medium)

                Rectangle()
                    .fill(
                        isSelected ?
                            LinearGradient(
                                colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.clear, Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
            
        }
    }
}

// MARK: - Overview Tab

private struct OverviewTab: View {
    let transaction: NetworkTransaction

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Spacer().frame(height: DSSpacing.s)

                // General Information
                InfoCard(title: "GENERAL") {
                    InfoRow(label: "URL", value: transaction.request.url)
                    Divider()
                    InfoRow(label: "Method", value: transaction.request.method.rawValue)
                    Divider()
                    InfoRow(label: "Protocol", value: transaction.request.httpProtocol ?? "HTTP/1.1")
                    Divider()
                    InfoRow(label: "Status", value: transaction.status.rawValue.capitalized)

                    if let response = transaction.response {
                        Divider()
                        InfoRow(label: "Status Code", value: "\(response.statusCode)")
                        Divider()
                        InfoRow(label: "Status Message", value: response.statusMessage)
                    }

                    if let duration = transaction.duration {
                        Divider()
                        InfoRow(label: "Duration", value: "\(Int(duration * 1000))ms")
                    } else if let response = transaction.response {
                        Divider()
                        InfoRow(label: "Duration", value: "\(Int(response.responseTime * 1000))ms")
                    }
                }

                // Timing Information
                InfoCard(title: "TIMING") {
                    InfoRow(label: "Start Time", value: formatTimestamp(transaction.startTime))

                    if let endTime = transaction.endTime {
                        Divider()
                        InfoRow(label: "End Time", value: formatTimestamp(endTime))
                    }

                    Divider()
                    InfoRow(label: "Request Timestamp", value: "\(transaction.request.timestamp)ms")

                    if let response = transaction.response {
                        Divider()
                        InfoRow(label: "Response Timestamp", value: "\(response.timestamp)ms")
                    }
                }

                // Size Information
                InfoCard(title: "SIZE") {
                    InfoRow(label: "Request Body Size", value: "\(transaction.request.bodySize) bytes")

                    if let response = transaction.response {
                        Divider()
                        InfoRow(label: "Response Body Size", value: "\(response.bodySize) bytes")
                    }
                }

                Spacer().frame(height: DSSpacing.m)
            }
            .dsPadding(.horizontal, DSSpacing.m)
        }
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Request Tab

private struct RequestTab: View {
    let transaction: NetworkTransaction

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Spacer().frame(height: DSSpacing.s)

                // Request Line
                InfoCard(title: "REQUEST LINE") {
                    InfoRow(label: "Method", value: transaction.request.method.rawValue)
                    Divider()
                    InfoRow(label: "Path", value: transaction.request.path ?? "/")
                    Divider()
                    InfoRow(label: "Protocol", value: transaction.request.httpProtocol ?? "HTTP/1.1")
                    Divider()
                    InfoRow(label: "Host", value: transaction.request.host ?? "")
                    Divider()
                    InfoRow(label: "URL", value: transaction.request.url)
                }

                // Headers
                if !transaction.request.headers.isEmpty {
                    InfoCard(title: "HEADERS") {
                        ForEach(Array(transaction.request.headers.keys.sorted().enumerated()), id: \.element) { index, key in
                            if let value = transaction.request.headers[key] {
                                if index > 0 {
                                    Divider()
                                }
                                InfoRow(label: key, value: value)
                            }
                        }
                    }
                }

                // Query Parameters
                if let url = URL(string: transaction.request.url),
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems, !queryItems.isEmpty {
                    InfoCard(title: "QUERY PARAMETERS") {
                        ForEach(queryItems.indices, id: \.self) { index in
                            if index > 0 {
                                Divider()
                            }
                            InfoRow(label: queryItems[index].name, value: queryItems[index].value ?? "")
                        }
                    }
                }

                // Request Body with EnhancedBodyViewer
                if let body = transaction.request.body,
                   let bodyString = String(data: body, encoding: .utf8) {
                    EnhancedBodyViewer(
                        title: "REQUEST BODY",
                        bodyContent: bodyString,
                        contentType: transaction.request.headers["Content-Type"]
                    )
                }

                Spacer().frame(height: DSSpacing.m)
            }
            .dsPadding(.horizontal, DSSpacing.m)
        }
    }
}

// MARK: - Response Tab

private struct ResponseTab: View {
    let transaction: NetworkTransaction

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Spacer().frame(height: DSSpacing.s)

                if let response = transaction.response {
                    // Status Line
                    InfoCard(title: "STATUS LINE") {
                        InfoRow(label: "Status Code", value: "\(response.statusCode)")
                        Divider()
                        InfoRow(label: "Status Message", value: response.statusMessage)
                        if let contentType = response.contentType {
                            Divider()
                            InfoRow(label: "Content-Type", value: contentType)
                        }
                        Divider()
                        InfoRow(label: "Body Size", value: "\(response.bodySize) bytes")
                        Divider()
                        InfoRow(label: "Response Time", value: "\(Int(response.responseTime * 1000))ms")
                    }

                    // Response Info
                    InfoCard(title: "RESPONSE INFO") {
                        InfoRow(label: "Success", value: response.isSuccessful ? "Yes" : "No")
                        Divider()
                        InfoRow(label: "Is JSON", value: response.isJson ? "Yes" : "No")
                        Divider()
                        InfoRow(label: "Is XML", value: response.isXml ? "Yes" : "No")
                        Divider()
                        InfoRow(label: "Is Image", value: response.isImage ? "Yes" : "No")
                    }

                    // Headers
                    if !response.headers.isEmpty {
                        InfoCard(title: "HEADERS") {
                            ForEach(Array(response.headers.keys.sorted().enumerated()), id: \.element) { index, key in
                                if let value = response.headers[key] {
                                    if index > 0 {
                                        Divider()
                                    }
                                    InfoRow(label: key, value: value)
                                }
                            }
                        }
                    }

                    // Response Body with EnhancedBodyViewer
                    if let body = response.body,
                       let bodyString = String(data: body, encoding: .utf8) {
                        EnhancedBodyViewer(
                            title: "RESPONSE BODY",
                            bodyContent: bodyString,
                            contentType: response.contentType
                        )
                    }
                } else {
                    VStack(spacing: DSSpacing.m) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(DSColor.Neutral.neutral60)

                        Text("No Response")
                            .dsTextStyle(.titleMedium)
                            .foregroundColor(DSColor.Neutral.neutral100)

                        Text("This request did not receive a response yet")
                            .dsTextStyle(.bodyMedium)
                            .foregroundColor(DSColor.Neutral.neutral80)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .dsPadding(DSSpacing.l)
                }

                Spacer().frame(height: DSSpacing.m)
            }
            .dsPadding(.horizontal, DSSpacing.m)
        }
    }
}

// MARK: - Info Card

private struct InfoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text(title)
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral80)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: DSSpacing.none) {
                content()
            }
            .dsPadding(DSSpacing.s)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(label)
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral60)

            Text(value)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral100)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsPadding(.vertical, DSSpacing.xs)
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: DSSpacing.m) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(DSColor.Primary.primary100)

            Text("Loading transaction...")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

private struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(DSColor.Error.error100)

            Text("Failed to Load Transaction")
                .dsTextStyle(.titleMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text(error.localizedDescription)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)
                .multilineTextAlignment(.center)
                .dsPadding(.horizontal, DSSpacing.l)

            DSButton(
                "Retry",
                style: .secondary,
                size: .medium,
                action: onRetry
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dsPadding(DSSpacing.l)
    }
}

// MARK: - Empty Transaction View

private struct EmptyTransactionView: View {
    var body: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(DSColor.Neutral.neutral60)

            Text("Transaction Not Found")
                .dsTextStyle(.titleMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text("The requested transaction could not be found")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dsPadding(DSSpacing.l)
    }
}

// MARK: - Previews

#if DEBUG
import JarvisCommon

#Preview("Transaction Detail - Success") {
    let mockTransaction = NetworkTransaction(
        id: "mock-1",
        request: NetworkRequest(
            url: "https://api.example.com/users/123",
            method: .GET,
            headers: [
                "Authorization": "Bearer token123",
                "Content-Type": "application/json",
                "User-Agent": "JarvisDemo/1.0"
            ],
            body: "{\"id\": 123, \"name\": \"John Doe\"}".data(using: .utf8)
        ),
        response: NetworkResponse(
            statusCode: 200,
            headers: [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache"
            ],
            body: "{\"id\": 123, \"name\": \"John Doe\"}".data(using: .utf8),
            responseTime: 0.234
        ),
        status: .completed,
        startTime: Date(),
        endTime: Date().addingTimeInterval(0.234)
    )

    return NavigationStack {
        TransactionDetailViewPreview(transaction: mockTransaction)
    }
}

#Preview("Transaction Detail - Error Response") {
    let mockTransaction = NetworkTransaction(
        id: "mock-2",
        request: NetworkRequest(
            url: "https://api.example.com/users/999",
            method: .GET,
            headers: ["Authorization": "Bearer token123"],
            body: nil
        ),
        response: NetworkResponse(
            statusCode: 404,
            headers: ["Content-Type": "application/json"],
            body: "{\"error\": \"User not found\"}".data(using: .utf8),
            responseTime: 0.123
        ),
        status: .failed,
        startTime: Date(),
        endTime: Date().addingTimeInterval(0.123)
    )

    return NavigationStack {
        TransactionDetailViewPreview(transaction: mockTransaction)
    }
}

#Preview("Transaction Detail - No Response") {
    let mockTransaction = NetworkTransaction(
        id: "mock-3",
        request: NetworkRequest(
            url: "https://api.example.com/timeout",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: "{\"data\": \"test\"}".data(using: .utf8)
        ),
        response: nil,
        status: .pending,
        startTime: Date(),
        endTime: nil
    )

    return NavigationStack {
        TransactionDetailViewPreview(transaction: mockTransaction)
    }
}

// Preview helper view
private struct TransactionDetailViewPreview: View {
    let transaction: NetworkTransaction
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: DSSpacing.none) {
            TabBar(selectedTab: $selectedTab)

            TabView(selection: $selectedTab) {
                OverviewTab(transaction: transaction)
                    .tag(0)

                RequestTab(transaction: transaction)
                    .tag(1)

                ResponseTab(transaction: transaction)
                    .tag(2)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
        .navigationTitle("Transaction Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
#endif
