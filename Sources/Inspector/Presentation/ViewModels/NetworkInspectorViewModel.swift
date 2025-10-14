import Foundation
import Combine
import Presentation
import Domain
import JarvisInspectorDomain

/// View model for network inspector
@MainActor
public class NetworkInspectorViewModel: BaseViewModel {
    @Published public var uiState = NetworkInspectorUIState()

    private let monitorUseCase: MonitorNetworkTransactionsUseCase
    private let getTransactionUseCase: GetNetworkTransactionUseCase
    private let filterUseCase: FilterNetworkTransactionsUseCase

    public init(
        monitorUseCase: MonitorNetworkTransactionsUseCase,
        getTransactionUseCase: GetNetworkTransactionUseCase,
        filterUseCase: FilterNetworkTransactionsUseCase
    ) {
        self.monitorUseCase = monitorUseCase
        self.getTransactionUseCase = getTransactionUseCase
        self.filterUseCase = filterUseCase
        super.init()
    }

    public func loadTransactions() {
        Task {
            isLoading = true
            clearError()

            do {
                let transactions = try await monitorUseCase.execute(())

                uiState = NetworkInspectorUIState(
                    transactions: transactions,
                    filteredTransactions: transactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: uiState.filter,
                    isLoading: false,
                    error: nil
                )
                isLoading = false
            } catch {
                handleError(error)
                uiState = NetworkInspectorUIState(
                    transactions: uiState.transactions,
                    filteredTransactions: uiState.filteredTransactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: uiState.filter,
                    isLoading: false,
                    error: error
                )
            }
        }
    }

    public func selectTransaction(_ transaction: NetworkTransaction) {
        uiState = NetworkInspectorUIState(
            transactions: uiState.transactions,
            filteredTransactions: uiState.filteredTransactions,
            selectedTransaction: transaction,
            filter: uiState.filter,
            isLoading: uiState.isLoading,
            error: uiState.error
        )
    }

    public func applyFilter(_ filter: TransactionFilter) {
        Task {
            do {
                let filteredTransactions = try await filterUseCase.execute(filter)

                uiState = NetworkInspectorUIState(
                    transactions: uiState.transactions,
                    filteredTransactions: filteredTransactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: filter,
                    isLoading: false,
                    error: nil
                )
            } catch {
                handleError(error)
                uiState = NetworkInspectorUIState(
                    transactions: uiState.transactions,
                    filteredTransactions: uiState.filteredTransactions,
                    selectedTransaction: uiState.selectedTransaction,
                    filter: filter,
                    isLoading: false,
                    error: error
                )
            }
        }
    }
}