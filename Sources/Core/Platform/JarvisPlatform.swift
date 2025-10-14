import Foundation
import Network
#if os(iOS)
import UIKit
#endif

/// Platform layer for the Jarvis SDK
/// Handles platform-specific implementations and system integrations
public struct JarvisPlatform {
    public static let version = "1.0.0"
}

// MARK: - Network Monitoring

/// Platform-specific network monitoring
public class NetworkMonitor: ObservableObject {
    @Published public var isConnected = true
    @Published public var connectionType: ConnectionType = .wifi

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case other
        case none
    }

    public init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else if path.status == .satisfied {
            connectionType = .other
        } else {
            connectionType = .none
        }
    }
}

// MARK: - Device Information

/// Platform device information
public struct DeviceInfo {
    public let model: String
    public let systemName: String
    public let systemVersion: String
    public let identifier: String

    public init() {
        #if os(iOS)
        let device = UIDevice.current
        self.model = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.identifier = device.identifierForVendor?.uuidString ?? "unknown"
        #elseif os(macOS)
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        self.identifier = "unknown"
        #else
        self.model = "unknown"
        self.systemName = "unknown"
        self.systemVersion = "unknown"
        self.identifier = "unknown"
        #endif
    }
}

// MARK: - URL Session Interception

/// URLSession interception for network monitoring
public class URLSessionInterceptor: URLProtocol {
    public static var onRequestStarted: ((URLRequest) -> Void)?
    public static var onRequestCompleted: ((URLRequest, URLResponse?, Data?, Error?) -> Void)?

    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        URLSessionInterceptor.onRequestStarted?(request)

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

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
        task.resume()
    }

    public override func stopLoading() {
        // Implementation for stopping loading
    }
}