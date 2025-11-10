//
//  NetworkMonitor.swift
//  Platform
//
//  Platform-specific network monitoring
//

import Foundation
import Network

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
