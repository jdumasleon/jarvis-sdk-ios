import Foundation
import Combine
import JarvisDomain

public final class NetworkRepositoryImpl: NetworkRepository {
    private let dataManager = NetworkDataManager.shared
    
    public init() {}
    
    public func getAllRequests() -> AnyPublisher<[NetworkRequest], Never> {
        return dataManager.requestsPublisher
    }
    
    public func getResponse(for requestId: UUID) -> AnyPublisher<NetworkResponse?, Never> {
        return dataManager.responsesPublisher
            .map { responses in
                responses.first { $0.requestId == requestId }
            }
            .eraseToAnyPublisher()
    }
    
    public func clearAllRequests() -> AnyPublisher<Void, Never> {
        return Just(())
            .handleEvents(receiveOutput: { _ in
                self.dataManager.clearAllData()
            })
            .eraseToAnyPublisher()
    }
    
    public func addRequest(_ request: NetworkRequest) -> AnyPublisher<Void, Never> {
        return Just(())
            .handleEvents(receiveOutput: { _ in
                self.dataManager.addRequest(request)
            })
            .eraseToAnyPublisher()
    }
    
    public func addResponse(_ response: NetworkResponse) -> AnyPublisher<Void, Never> {
        return Just(())
            .handleEvents(receiveOutput: { _ in
                self.dataManager.addResponse(response)
            })
            .eraseToAnyPublisher()
    }
}