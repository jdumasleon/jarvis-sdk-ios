import Foundation
import Domain
import JarvisInspectorDomain

/// UI state for network inspector
public struct NetworkInspectorUIState {
    public let transactions: [NetworkTransaction]
    public let filteredTransactions: [NetworkTransaction]
    public let selectedTransaction: NetworkTransaction?
    public let filter: TransactionFilter
    public let isLoading: Bool
    public let error: Error?

    public init(
        transactions: [NetworkTransaction] = [],
        filteredTransactions: [NetworkTransaction] = [],
        selectedTransaction: NetworkTransaction? = nil,
        filter: TransactionFilter = TransactionFilter(),
        isLoading: Bool = false,
        error: Error? = nil
    ) {
        self.transactions = transactions
        self.filteredTransactions = filteredTransactions
        self.selectedTransaction = selectedTransaction
        self.filter = filter
        self.isLoading = isLoading
        self.error = error
    }
}