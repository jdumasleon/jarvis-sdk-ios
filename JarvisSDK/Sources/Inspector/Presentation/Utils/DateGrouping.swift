import Foundation
import JarvisDomain
import JarvisInspectorDomain

/// Utility for grouping network transactions by date
public struct DateGrouping {

    /// Represents a group of transactions for a specific date
    public struct DateGroup: Identifiable {
        public let id: String
        public let title: String
        public let date: Date
        public let transactions: [NetworkTransaction]

        public init(title: String, date: Date, transactions: [NetworkTransaction]) {
            self.id = title
            self.title = title
            self.date = date
            self.transactions = transactions
        }
    }

    /// Groups transactions by date (Today, Yesterday, or specific date)
    /// - Parameter transactions: Transactions to group
    /// - Returns: Array of date groups sorted by date (newest first)
    public static func group(_ transactions: [NetworkTransaction]) -> [DateGroup] {
        let calendar = Calendar.current

        // Group by day
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.startTime)
        }

        // Convert to DateGroup array with formatted titles
        return grouped.map { date, transactions in
            DateGroup(
                title: formatDateGroupTitle(date),
                date: date,
                transactions: transactions.sorted { $0.startTime > $1.startTime }
            )
        }
        .sorted { $0.date > $1.date } // Newest first
    }

    /// Formats a date into a group title (Today, Yesterday, or formatted date)
    /// - Parameter date: The date to format
    /// - Returns: Formatted string (e.g., "Today", "Yesterday", "Dec 25, 2024")
    private static func formatDateGroupTitle(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            // This week - show day name
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full day name
            return formatter.string(from: date)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            // This year - show month and day
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // e.g., "Dec 25"
            return formatter.string(from: date)
        } else {
            // Other years - show full date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    /// Gets a summary of transaction counts by date
    /// - Parameter transactions: Transactions to summarize
    /// - Returns: Dictionary mapping date titles to transaction counts
    public static func getSummary(_ transactions: [NetworkTransaction]) -> [String: Int] {
        let groups = group(transactions)
        return Dictionary(uniqueKeysWithValues: groups.map { ($0.title, $0.transactions.count) })
    }
}
