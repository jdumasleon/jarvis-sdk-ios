import Foundation
import JarvisCommon
import JarvisDomain

public final class JarvisURLProtocol: URLProtocol {
    private static let handledKey = "JarvisURLProtocolHandled"
    private var dataTask: URLSessionDataTask?
    private var receivedData = Data()
    private var startTime: Date?
    
    public static func startIntercepting() {
        URLProtocol.registerClass(JarvisURLProtocol.self)
        JarvisLogger.shared.info("JarvisURLProtocol registered for network interception")
    }
    
    public static func stopIntercepting() {
        URLProtocol.unregisterClass(JarvisURLProtocol.self)
        JarvisLogger.shared.info("JarvisURLProtocol unregistered")
    }
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else {
            return false
        }
        
        guard let url = request.url,
              let scheme = url.scheme,
              scheme.lowercased() == "http" || scheme.lowercased() == "https" else {
            return false
        }
        
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        guard let newRequest = createModifiedRequest() else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        startTime = Date()
        logRequest(newRequest)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        dataTask = session.dataTask(with: newRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.logResponse(response, data: data)
            }
            
            if let data = data {
                self.receivedData.append(data)
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        dataTask?.resume()
    }
    
    public override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
    
    private func createModifiedRequest() -> URLRequest? {
        guard let originalRequest = request.mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: originalRequest)
        return originalRequest as URLRequest
    }
    
    private func logRequest(_ request: URLRequest) {
        guard let url = request.url else { return }
        
        let networkRequest = NetworkRequest(
            url: url,
            method: HTTPMethod(rawValue: request.httpMethod ?? "GET") ?? .GET,
            headers: request.allHTTPHeaderFields ?? [:],
            body: request.httpBody
        )
        
        NetworkDataManager.shared.addRequest(networkRequest)
        JarvisLogger.shared.debug("Intercepted request: \(request.httpMethod ?? "GET") \(url)")
    }
    
    private func logResponse(_ response: URLResponse, data: Data?) {
        guard let httpResponse = response as? HTTPURLResponse,
              let url = response.url else { return }
        
        let responseTime = startTime?.timeIntervalSinceNow ?? 0
        
        if let requestId = NetworkDataManager.shared.getRequestId(for: url) {
            let networkResponse = NetworkResponse(
                requestId: requestId,
                statusCode: httpResponse.statusCode,
                headers: httpResponse.allHeaderFields as? [String: String] ?? [:],
                body: data,
                responseTime: abs(responseTime)
            )
            
            NetworkDataManager.shared.addResponse(networkResponse)
        }
        
        JarvisLogger.shared.debug("Intercepted response: \(httpResponse.statusCode) for \(url)")
    }
}