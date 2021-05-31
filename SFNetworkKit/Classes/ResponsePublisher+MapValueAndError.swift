//
//  Helpers.swift
//  SFNetworkKit
//
//  Created by Plamen Penchev on 31.05.21.
//

import Foundation
import Alamofire
import Combine

@available(iOS 13, *)
extension DataResponsePublisher {
    /// Helper for type erasing ```DataResponsePublisher``` to AnyPublisher
    /// with proper value and APIError.
    @available(iOS 13, *)
    func mapValueAndError() -> AnyPublisher<Value, APIError> {
        value().mapError(APIError.getAsAPIError).eraseToAnyPublisher()
    }
}

@available(iOS 13, *)
extension DownloadResponsePublisher {
    /// Helper for type erasing ```DownloadResponsePublisher``` to AnyPublisher
    /// with proper value and APIError.
    @available(iOS 13, *)
    func mapValueAndError() -> AnyPublisher<Value, APIError> {
        value().mapError(APIError.getAsAPIError).eraseToAnyPublisher()
    }
}
