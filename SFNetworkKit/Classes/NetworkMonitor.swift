//
//  NetworkMonitor.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 12.10.20.
//

import Foundation
import Alamofire

/// Alamofire's `NetworkReachabilityManager` wrapper.
public final class NetworkObserver {

    /// Whether the network is currently reachable.
    public var isConnected: Bool {
        return networkReachabilityManager.isReachable
    }

    private let networkMonitor: CompositeNetworkMonitor

    private let networkReachabilityManager: NetworkReachabilityManager

    public convenience init?(host: String = "www.apple.com",
                             networkMonitors: [NetworkMonitor] = []) {
        guard let networkReachabilityManager = NetworkReachabilityManager(host: host) else {
            return nil
        }

        self.init(networkReachabilityManager: networkReachabilityManager,
                  networkMonitor: CompositeNetworkMonitor(monitors: networkMonitors))
    }

    private init(networkReachabilityManager: NetworkReachabilityManager,
                 networkMonitor: CompositeNetworkMonitor) {
        self.networkReachabilityManager = networkReachabilityManager
        self.networkMonitor = networkMonitor
    }

    deinit {
        stopObserving()
    }

    public func startObserving() {
        networkReachabilityManager.startListening { [weak self] status in
            self?.networkMonitor.networkStatusDidChange(status.isConnected)
        }
    }

    public func stopObserving() {
        networkReachabilityManager.stopListening()
    }

}

// MARK: - NetworkMonitor

public protocol NetworkMonitor: AnyObject {
    /// The `DispatchQueue` onto which NetworkKit's root `CompositeNetworkMonitor` will dispatch events. `.main` by default.
    var queue: DispatchQueue { get }

    func networkStatusDidChange(_ isConnected: Bool)
}

// MARK: - Default Implementations

public extension NetworkMonitor {
    var queue: DispatchQueue {
        .main
    }

    func networkStatusDidChange(_ isConnected: Bool) {
        // Do nothing
    }
}

// MARK: - Monitors

// Composite

public final class CompositeNetworkMonitor: NetworkMonitor {
    public let queue = DispatchQueue(label: "com.scalefocus.networkkit.compositeNetworkMonitor", qos: .utility)

    let monitors: [NetworkMonitor]

    init(monitors: [NetworkMonitor]) {
        self.monitors = monitors
    }

    func performEvent(_ event: @escaping (NetworkMonitor) -> Void) {
        queue.async {
            for monitor in self.monitors {
                monitor.queue.async { event(monitor) }
            }
        }
    }

    public func networkStatusDidChange(_ isConnected: Bool) {
        performEvent { $0.networkStatusDidChange(isConnected) }
    }
}

// Closure

/// `NetworkMonitor` that allows optional closures to be set to receive events.
/// Evenets are dispatched on `.main` `DispatchQueue` by default.
open class ClosureNetworkMonitor: NetworkMonitor {
    /// Closure called on the `networkStatusDidChange(_:)` event.
    open var networkStatusDidChange: ((Bool) -> Void)?

    // MARK: - NetworkMonitor

    public func networkStatusDidChange(_ isConnected: Bool) {
        networkStatusDidChange?(isConnected)
    }
}
