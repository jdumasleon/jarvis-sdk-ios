import Foundation
import Combine
import JarvisDomain

public final class NetworkDataManager: ObservableObject {
    public static let shared = NetworkDataManager()
    
    @Published private var requests: [NetworkRequest] = []
    @Published private var responses: [NetworkResponse] = []
    
    private var requestLookup: [URL: UUID] = [:]
    private let queue = DispatchQueue(label: "com.jarvis.networkdata", attributes: .concurrent)
    
    private init() {}
    
    public func addRequest(_ request: NetworkRequest) {
        queue.async(flags: .barrier) {
            self.requestLookup[request.url] = request.id
            DispatchQueue.main.async {
                self.requests.append(request)
            }
        }
    }
    
    public func addResponse(_ response: NetworkResponse) {
        queue.async(flags: .barrier) {
            DispatchQueue.main.async {
                self.responses.append(response)
            }
        }
    }
    
    public func getRequestId(for url: URL) -> UUID? {
        return queue.sync {
            return requestLookup[url]
        }
    }
    
    public func getAllRequests() -> [NetworkRequest] {
        return queue.sync {
            return requests
        }
    }
    
    public func getResponse(for requestId: UUID) -> NetworkResponse? {
        return queue.sync {
            return responses.first { $0.requestId == requestId }
        }
    }
    
    public func clearAllData() {
        queue.async(flags: .barrier) {
            self.requestLookup.removeAll()
            DispatchQueue.main.async {
                self.requests.removeAll()
                self.responses.removeAll()
            }
        }
    }
    
    public var requestsPublisher: AnyPublisher<[NetworkRequest], Never> {
        $requests.eraseToAnyPublisher()
    }
    
    public var responsesPublisher: AnyPublisher<[NetworkResponse], Never> {
        $responses.eraseToAnyPublisher()
    }
}