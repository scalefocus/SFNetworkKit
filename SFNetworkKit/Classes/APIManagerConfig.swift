//
//  APIManagerConfig.swift
//  SFNetworkKit
//
//  Created by Plamen Penchev on 31.05.21.
//

import Foundation
import Alamofire

/// A configuration to use when setting up APIManager's session.
public struct APIManagerConfig {
    /// The event monitors to use for tracking session events.
    let eventMonitors: [EventMonitor]

    /// The trust policy to use for the particular host (Certificate pinning etc.).
    let serverTrustPolicies: [HostTrustPolicy]
    
    public init(eventMonitors: [EventMonitor] = [],
                serverTrustPolicies: [HostTrustPolicy] = []) {
        self.eventMonitors = eventMonitors
        self.serverTrustPolicies = serverTrustPolicies
    }
}

/// A model to use for configuring the server trust policy for particular hosts.
public struct HostTrustPolicy: APITrustPolicySettable {
    public let host: String
    public let trustPolicy: APITrustPolicyType
    
    /// Avoid using ```.none``` as ```trustPolicy``` in production!!!
    public init(host: String, trustPolicy: APITrustPolicyType = .none) {
        self.host = host
        self.trustPolicy = trustPolicy
    }
}
