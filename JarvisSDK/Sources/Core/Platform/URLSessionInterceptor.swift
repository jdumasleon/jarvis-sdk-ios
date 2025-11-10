//
//  URLSessionInterceptor.swift
//  Platform
//
//  URLSession interception for network monitoring
//

import Foundation

/// URLSession interception for network monitoring
/// To use: Call JarvisSDK.configureURLSession(&configuration) to add this interceptor to your URLSessionConfiguration
public class URLSessionInterceptor: URLProtocol {
    public static var onRequestStarted: ((URLRequest) -> Void)?
    public static var onRequestCompleted: ((URLRequest, URLResponse?, Data?, Error?) -> Void)?

    // Property key to mark requests that should not be intercepted (prevents infinite recursion)
    private static let handledKey = "JarvisURLSessionInterceptorHandled"

    private var dataTask: URLSessionDataTask?

    public override class func canInit(with request: URLRequest) -> Bool {
        // Don't intercept requests that we've already handled
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else {
            return false
        }
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        // Notify that request is starting
        URLSessionInterceptor.onRequestStarted?(request)

        // Mark request as handled to prevent infinite recursion
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: URLSessionInterceptor.handledKey, in: mutableRequest)

        // Create a new session with default configuration
        let session = URLSession(configuration: .default)

        // Execute the actual request
        dataTask = session.dataTask(with: mutableRequest as URLRequest) { [weak self] data, response, error in
            guard let self = self else { return }

            // Notify that request completed
            URLSessionInterceptor.onRequestCompleted?(self.request, response, data, error)

            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        dataTask?.resume()
    }

    public override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
}
