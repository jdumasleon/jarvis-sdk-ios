//
//  TransactionDetailView.swift
//  JarvisSDK
//
//  Detailed view for a network transaction
//

import SwiftUI
import DesignSystem
import Domain
import JarvisInspectorDomain

/// Detail view for a network transaction
struct TransactionDetailView: View {
    let transactionId: String
    @State private var transaction: NetworkTransaction?
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading transaction...")
                    .padding()
            } else if let error = error {
                VStack(spacing: DSSpacing.m) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(DSColor.Error.error100)

                    DSText(
                        "Failed to load transaction",
                        style: .titleMedium,
                        color: DSColor.Neutral.neutral100
                    )

                    DSText(
                        error.localizedDescription,
                        style: .bodySmall,
                        color: DSColor.Neutral.neutral80
                    )
                }
                .padding()
            } else if let transaction = transaction {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    // Request Section
                    sectionView(title: "Request") {
                        detailRow(label: "Method", value: transaction.request.method.rawValue)
                        detailRow(label: "URL", value: transaction.request.url)

                        if !transaction.request.headers.isEmpty {
                            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                DSText(
                                    "Headers",
                                    style: .labelSmall,
                                    color: DSColor.Neutral.neutral80
                                )

                                ForEach(Array(transaction.request.headers.keys.sorted()), id: \.self) { key in
                                    if let value = transaction.request.headers[key] {
                                        HStack(alignment: .top) {
                                            DSText(
                                                "\(key):",
                                                style: .bodySmall,
                                                color: DSColor.Neutral.neutral100
                                            )
                                            .bold()

                                            DSText(
                                                value,
                                                style: .bodySmall,
                                                color: DSColor.Neutral.neutral80
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        if let body = transaction.request.body,
                           let bodyString = String(data: body, encoding: .utf8) {
                            detailRow(label: "Body", value: bodyString)
                        }
                    }

                    Divider()

                    // Response Section
                    if let response = transaction.response {
                        sectionView(title: "Response") {
                            detailRow(label: "Status Code", value: "\(response.statusCode)")

                            if !response.headers.isEmpty {
                                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                    DSText(
                                        "Headers",
                                        style: .labelSmall,
                                        color: DSColor.Neutral.neutral80
                                    )

                                    ForEach(Array(response.headers.keys.sorted()), id: \.self) { key in
                                        if let value = response.headers[key] {
                                            HStack(alignment: .top) {
                                                DSText(
                                                    "\(key):",
                                                    style: .bodySmall,
                                                    color: DSColor.Neutral.neutral100
                                                )
                                                .bold()

                                                DSText(
                                                    value,
                                                    style: .bodySmall,
                                                    color: DSColor.Neutral.neutral80
                                                )
                                            }
                                        }
                                    }
                                }
                            }

                            if let body = response.body,
                               let bodyString = String(data: body, encoding: .utf8) {
                                detailRow(label: "Body", value: bodyString)
                            }
                        }

                        Divider()
                    }

                    // Timing Section
                    sectionView(title: "Timing") {
                        detailRow(label: "Start Time", value: formatTimestamp(transaction.startTime))

                        if let endTime = transaction.endTime {
                            detailRow(label: "End Time", value: formatTimestamp(endTime))
                        }

                        if let duration = transaction.duration {
                            detailRow(label: "Duration", value: formatDuration(duration))
                        }

                        detailRow(label: "Status", value: transaction.status.rawValue)
                    }
                }
                .padding(DSSpacing.m)
            } else {
                DSText(
                    "Transaction not found",
                    style: .bodyMedium,
                    color: DSColor.Neutral.neutral80
                )
                .padding()
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

    @ViewBuilder
    private func sectionView<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            DSText(
                title,
                style: .titleSmall,
                color: DSColor.Neutral.neutral100
            )

            content()
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            DSText(
                label,
                style: .labelSmall,
                color: DSColor.Neutral.neutral80
            )

            DSText(
                value,
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
        }
    }

    private func loadTransaction() {
        // TODO: Implement actual loading from repository
        // For now, this is a placeholder
        isLoading = false
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 1 {
            return "\(Int(duration * 1000))ms"
        } else {
            return String(format: "%.2fs", duration)
        }
    }
}
