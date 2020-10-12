//
//  NetworkReachabilityStatus+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 12.10.20.
//

import Foundation
import Alamofire

extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus {
    var isConnected: Bool {
        switch self {
        case .reachable(_):
            return true
        default:
            return false
        }
    }
}
