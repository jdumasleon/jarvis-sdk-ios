import SwiftUI
import DesignSystem
import Domain
import JarvisInspectorDomain

/// Main network inspector view
public struct NetworkInspectorView: View {
    @StateObject private var viewModel: NetworkInspectorViewModel

    public init(viewModel: NetworkInspectorViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading transactions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.uiState.filteredTransactions, id: \.id) { transaction in
                            NetworkTransactionRowView(transaction: transaction)
                                .onTapGesture {
                                    viewModel.selectTransaction(transaction)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Network Inspector")
            .onAppear {
                viewModel.loadTransactions()
            }
        }
    }
}

/// Row view for network transaction
public struct NetworkTransactionRowView: View {
    let transaction: NetworkTransaction

    public init(transaction: NetworkTransaction) {
        self.transaction = transaction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(transaction.request.method.rawValue)
                    .setTextStyle(.labelSmall)
                    .foregroundColor(methodColor)
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, 2)
                    .background(methodColor.opacity(0.1))
                    .dsCornerRadius(DSRadius.xs)

                Spacer()

                if let statusCode = transaction.response?.statusCode {
                    Text("\\(statusCode)")
                        .setTextStyle(.labelSmall)
                        .foregroundColor(statusColor(statusCode))
                }
            }

            Text(transaction.request.url)
                .setTextStyle(.bodySmall)
                .foregroundColor(DSColor.Text.primary)
                .lineLimit(2)

            if let duration = transaction.duration {
                Text(String(format: "%.0fms", duration * 1000))
                    .setTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Text.secondary)
            }
        }
        .dsPadding(DSSpacing.s)
    }

    private var methodColor: Color {
        switch transaction.request.method {
        case .GET:
            return DSColor.Success.success100
        case .POST:
            return DSColor.Primary.primary100
        case .PUT:
            return DSColor.Warning.warning100
        case .DELETE:
            return DSColor.Error.error100
        default:
            return DSColor.Text.secondary
        }
    }

    private func statusColor(_ statusCode: Int) -> Color {
        switch statusCode {
        case 200..<300:
            return DSColor.Success.success100
        case 300..<400:
            return DSColor.Warning.warning100
        case 400...:
            return DSColor.Error.error100
        default:
            return DSColor.Text.secondary
        }
    }
}