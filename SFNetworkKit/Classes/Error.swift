//
//  Error.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 5.10.20.
//

import Foundation

public enum APIError: Error {
    /// Failed to create a valid `URL` from `APIRequest`'s baseUrl.
    case invalidBaseUrl

    /// Api Request failed with an underlying error.
    case requestFailed(error: Error)

    // MARK: - Encoding

    /// JSON serialization failed with an underlying system error during the encoding process.
    case jsonEncodingFailed(error: Error)
    /// Parameter serialization failed with an underlying system error during the encoding process.
    case parameterEncodingFailed(error: Error)
    /// The `URLRequest` did not have a `URL` to encode.
    case missingURL

    // MARK: - Authorization

    /// Authorization token is empty
    case invalidAuthorizationToken
    
    // MARK: - Unknown
    
    /// When the error is not any of the ones specified above.
    case unknown(error: Error)
    
    /// Tries to cast the provided error as APIError and returns it.
    /// If the cast fails an ```.unknown(error:)``` is returned with
    /// the original error as an associated value.
    /// - Parameter error: The error to get as APIError.
    static func getAsAPIError(error: Error) -> APIError {
        guard let apiError = error as? APIError else {
            return .unknown(error: error)
        }
        
        return apiError
    }
}
