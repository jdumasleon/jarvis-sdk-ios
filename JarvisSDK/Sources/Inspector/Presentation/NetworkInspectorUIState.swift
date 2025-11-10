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

    // UI-specific state
    public let searchQuery: String
    public let selectedMethod: HTTPMethod?
    public let selectedStatusCategory: StatusCategory?
    public let currentPage: Int
    public let itemsPerPage: Int
    public let totalPages: Int
    public let groupByDate: Bool
    public let dateGroups: [DateGrouping.DateGroup]

    // Infinite scroll state
    public let hasMorePages: Bool
    public let isLoadingMore: Bool
    public let isRefreshing: Bool

    public init(
        transactions: [NetworkTransaction] = [],
        filteredTransactions: [NetworkTransaction] = [],
        selectedTransaction: NetworkTransaction? = nil,
        filter: TransactionFilter = TransactionFilter(),
        isLoading: Bool = false,
        error: Error? = nil,
        searchQuery: String = "",
        selectedMethod: HTTPMethod? = nil,
        selectedStatusCategory: StatusCategory? = nil,
        currentPage: Int = 0,
        itemsPerPage: Int = 20,
        totalPages: Int = 0,
        groupByDate: Bool = true,
        dateGroups: [DateGrouping.DateGroup] = [],
        hasMorePages: Bool = false,
        isLoadingMore: Bool = false,
        isRefreshing: Bool = false
    ) {
        self.transactions = transactions
        self.filteredTransactions = filteredTransactions
        self.selectedTransaction = selectedTransaction
        self.filter = filter
        self.isLoading = isLoading
        self.error = error
        self.searchQuery = searchQuery
        self.selectedMethod = selectedMethod
        self.selectedStatusCategory = selectedStatusCategory
        self.currentPage = currentPage
        self.itemsPerPage = itemsPerPage
        self.totalPages = totalPages
        self.groupByDate = groupByDate
        self.dateGroups = dateGroups
        self.hasMorePages = hasMorePages
        self.isLoadingMore = isLoadingMore
        self.isRefreshing = isRefreshing
    }
}

/// Status code categories for filtering
public enum StatusCategory: String, CaseIterable {
    case all = "All"
    case successful = "Success"
    case redirect = "Redirect"
    case clientError = "Client Error"
    case serverError = "Server Error"

    public var range: ClosedRange<Int>? {
        switch self {
        case .all: return nil
        case .successful: return 200...299
        case .redirect: return 300...399
        case .clientError: return 400...499
        case .serverError: return 500...599
        }
    }
}
