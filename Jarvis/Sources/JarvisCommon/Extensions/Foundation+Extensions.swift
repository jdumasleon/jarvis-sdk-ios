import Foundation

// MARK: - Date Extensions
public extension Date {
    func formattedString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - Data Extensions
public extension Data {
    var prettyJSON: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        return String(data: prettyData, encoding: .utf8)
    }
}

// MARK: - String Extensions
public extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}