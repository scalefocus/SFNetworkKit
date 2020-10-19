//
//  Authorization.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation

/// An enum representing the header to use with an `AccessTokenPlugin`
public enum AuthorizationType {
    /// The `"Basic"` header.
    case basic

    /// The `"Bearer"` header.
    case bearer

    /// Custom header implementation.
    case custom(String)

    public var value: String {
        switch self {
        case .basic: return "Basic"
        case .bearer: return "Bearer"
        case .custom(let customValue): return customValue
        }
    }
}

//

public protocol AuthorizationTokenProvider: APIAuthenticator {
    var authorizationType: AuthorizationType { get }
    var authorizationToken: String? { get }
}

//

public protocol SecretProvider {
    // Header name
    var name: String { get }
    // secret value
    var value: String { get }
}

//

public protocol APIAuthenticator {
    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void)
}

public extension APIAuthenticator {
    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) { }
}
