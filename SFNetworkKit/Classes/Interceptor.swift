//
//  Interceptor.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

open class APISecretAdapter: Alamofire.RequestAdapter {
    private let secretProvider: SecretProvider

    public init(secretProvider: SecretProvider) {
        self.secretProvider = secretProvider
    }

    public func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(name: secretProvider.name,
                               value: secretProvider.value)
        completion(.success(urlRequest))
    }
}

open class APIAuthorizationTokenAdapter: Alamofire.RequestAdapter {
    private let tokenProvider: AuthorizationTokenProvider

    public init(tokenProvider: AuthorizationTokenProvider) {
        self.tokenProvider = tokenProvider
    }

    public func adapt(_ urlRequest: URLRequest,
                      for session: Session,
                      completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let authorizationToken = tokenProvider.authorizationToken, !authorizationToken.isEmpty else {
            completion(.failure(APIError.invalidAuthorizationToken))
            return
        }

        var urlRequest = urlRequest
        urlRequest.headers.add(
            .authorization("\(tokenProvider.authorizationType.value) \(authorizationToken)")
        )

        completion(.success(urlRequest))
    }
}

open class APIAuthorizationTokenRefreshPolicy: Alamofire.RequestRetrier {
    /// The default retry limit for retry policies.
    public static let defaultRetryLimit: UInt = 2

    /// The total number of times the request is allowed to be retried.
    public let retryLimit: UInt

    /// Prevents the retry body from multiple executions for the same response instance.
    var lastProceededResponse: HTTPURLResponse?

    public let tokenProvider: AuthorizationTokenProvider

    public init(tokenProvider: AuthorizationTokenProvider,
                retryLimit: UInt = APIAuthorizationTokenRefreshPolicy.defaultRetryLimit) {
        self.retryLimit = retryLimit
        self.tokenProvider = tokenProvider
    }
    
    public func retry(_ request: Request,
                      for session: Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        // ??? Maybe we should also retry if status code is 403
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            // The request did not fail due to a 401 Unauthorized response.
            // Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }

        guard lastProceededResponse != request.response, request.retryCount < retryLimit else {
            return completion(.doNotRetry)
        }

        lastProceededResponse = request.response

        tokenProvider.refreshToken { isSuccess in
            isSuccess ? completion(.retry) : completion(.doNotRetry)
        }
    }
}
