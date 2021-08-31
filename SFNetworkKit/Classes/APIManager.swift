//
//  APIManager.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire
import Combine

public typealias APIResult<T> = Swift.Result<T, APIError>
public typealias APIResultHandler<T: Decodable> = (APIResult<T>) -> Void
public typealias APIProgressHandler = (Double) -> Void

// MARK: - ServerTrustManager+NetworkKit

public final class APIManager {

    public static let `default` = APIManager()
    private var session = AF
    
    public init(configuration: APIManagerConfig? = nil) {
        // Setup custom session if config is provided,
        // otherwise use the default one from AF.
        let evaluators = configuration?
            .serverTrustPolicies
            .reduce(into: [String: ServerTrustEvaluating]()) {
                $0[$1.host] = $1.serverTrustEvaluator()
            }
        
        let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: false,
                                                    evaluators: evaluators ?? [:])
        session = Alamofire.Session(serverTrustManager: serverTrustManager,
                                    eventMonitors: configuration?.eventMonitors ?? [])
    }
    
    /// Handles request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - completion: Completion with the request's result - either parsed data or error.
    public final func request<T: APIDataRequest>(_ request: T,
                                                 _ decoder: JSONDecoder = JSONDecoder(),
                                                 _ completion: @escaping APIResultHandler<T.Response>) {
        // Handles cache
        let cacher = self.cacher(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        session
            .request(request, interceptor: interceptor)
            .cacheResponse(using: cacher)
            .validate(request.validation)
            .apiResponseDecodable(of: T.Response.self, decoder: decoder) { result in
                completion(result)
            }
    }
    
    /// Handles request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    /// - Returns: Publisher with the request's result - either parsed data or error.
    @available(iOS 13, *)
    public final func requestPublisher<T: APIDataRequest>(
        _ request: T,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T.Response, APIError> {
        // Handles cache
        let cacher = self.cacher(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        
        return session
            .request(request, interceptor: interceptor)
            .cacheResponse(using: cacher)
            .validate(request.validation)
            .publishDecodable(type: T.Response.self, decoder: decoder)
            .mapValueAndError()
    }
    
    // TODO: Stream Request
    
    /// Handles request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - downloadProgress: Closure to be executed when progress is updated.
    ///   - completion: Completion with the request's result - either received data or error.
    public final func download<T: APIDownloadRequest>(_ request: T,
                                                      _ downloadProgress: APIProgressHandler? = nil,
                                                      _ completion: @escaping APIResultHandler<T.Response>) {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        session
            .download(convertible: request, interceptor: interceptor, to: request.destination)
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseData { result in
                completion(result)
            }
    }
    
    /// Handles request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - downloadProgress: Closure to be executed when progress is updated.
    /// - Returns: Publisher with the request's result - either received data or error.
    @available(iOS 13, *)
    public final func downloadPublisher<T: APIDownloadRequest>(
        _ request: T,
        _ downloadProgress: APIProgressHandler? = nil
    ) -> AnyPublisher<T.Response, APIError> {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        
        return session
            .download(convertible: request, interceptor: interceptor, to: request.destination)
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .publishData()
            .mapValueAndError()
    }
    
    /// Handles upload request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - uploadProgress: Closure to be executed when upload progress is updated.
    ///   - downloadProgress: Closure to be executed when download progress is updated.
    ///   - completion: Completion with the request's result - either parsed data or error.
    public final func upload<T: APIUploadRequest>(_ request: T,
                                           _ decoder: JSONDecoder = JSONDecoder(),
                                           _ uploadProgress: APIProgressHandler? = nil,
                                           _ downloadProgress: APIProgressHandler? = nil,
                                           _ completion: @escaping APIResultHandler<T.Response>) {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        session
            .upload(convertible: request, interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseDecodable(of: T.Response.self, decoder: decoder) { result in
                completion(result)
            }
    }
    
    /// Handles upload request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - uploadProgress: Closure to be executed when upload progress is updated.
    ///   - downloadProgress: Closure to be executed when download progress is updated.
    /// - Returns: Publisher with the request's result - either parsed data or error.
    @available(iOS 13, *)
    public final func uploadPublisher<T: APIUploadRequest>(
        _ request: T,
        _ decoder: JSONDecoder = JSONDecoder(),
        _ uploadProgress: APIProgressHandler? = nil,
        _ downloadProgress: APIProgressHandler? = nil
    ) -> AnyPublisher<T.Response, APIError> {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        
        return session
            .upload(convertible: request, interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .publishDecodable(type: T.Response.self, decoder: decoder)
            .mapValueAndError()
    }
    
    /// Handles multipart upload request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - uploadProgress: Closure to be executed when upload progress is updated.
    ///   - downloadProgress: Closure to be executed when download progress is updated.
    ///   - completion: Completion with the request's result - either parsed data or error.
    public final func upload<T: APIMultipartRequest>(_ request: T,
                                                     _ decoder: JSONDecoder = JSONDecoder(),
                                                     _ uploadProgress: APIProgressHandler? = nil,
                                                     _ downloadProgress: APIProgressHandler? = nil,
                                                     _ completion: @escaping APIResultHandler<T.Response>) {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        let multipartFormData = request.asMultipartFormData()

        session
            .upload(multipartFormData: multipartFormData,
                    with: request,
                    interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseDecodable(of: T.Response.self, decoder: decoder) { result in
                completion(result)
            }
    }
    
    /// Handles multipart upload request execution.
    /// - Parameters:
    ///   - request: The APIDataRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - uploadProgress: Closure to be executed when upload progress is updated.
    ///   - downloadProgress: Closure to be executed when download progress is updated.
    /// - Returns: Publisher with the request's result - either parsed data or error.
    @available(iOS 13, *)
    public final func uploadPublisher<T: APIMultipartRequest>(
        _ request: T,
        _ decoder: JSONDecoder = JSONDecoder(),
        _ uploadProgress: APIProgressHandler? = nil,
        _ downloadProgress: APIProgressHandler? = nil
    ) -> AnyPublisher<T.Response, APIError> {
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        let multipartFormData = request.asMultipartFormData()
        
        return session
            .upload(multipartFormData: multipartFormData,
                    with: request,
                    interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .publishDecodable(type: T.Response.self, decoder: decoder)
            .mapValueAndError()
    }

    // MARK: - Helpers

    private func interceptor<T: APIRequest>(for request: T) -> Alamofire.Interceptor {
        Alamofire.Interceptor(adapters: request.adapters,
                              retriers: request.retriers)
    }

    private func cacher(for request: APICacheable) -> ResponseCacher {
        ResponseCacher(behavior: request.shouldCache ? .cache : .doNotCache)
    }
}
