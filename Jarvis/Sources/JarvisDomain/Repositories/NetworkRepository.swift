import Foundation
import Combine

public protocol NetworkRepository {
    func getAllRequests() -> AnyPublisher<[NetworkRequest], Never>
    func getResponse(for requestId: UUID) -> AnyPublisher<NetworkResponse?, Never>
    func clearAllRequests() -> AnyPublisher<Void, Never>
    func addRequest(_ request: NetworkRequest) -> AnyPublisher<Void, Never>
    func addResponse(_ response: NetworkResponse) -> AnyPublisher<Void, Never>
}

public protocol PreferencesRepository {
    func getAllPreferences() -> AnyPublisher<[PreferenceItem], Never>
    func updatePreference(key: String, value: Any, source: PreferenceSource) -> AnyPublisher<Bool, Error>
    func deletePreference(key: String, source: PreferenceSource) -> AnyPublisher<Bool, Error>
    func refreshPreferences() -> AnyPublisher<Void, Never>
}