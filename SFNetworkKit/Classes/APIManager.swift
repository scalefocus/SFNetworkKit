//
//  APIManager.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

public typealias APIResult<T> = Swift.Result<T, APIError>
public typealias APIResultHandler<T: Decodable> = (APIResult<T>) -> Void
public typealias APIProgressHandler = (Double) -> Void

// MARK: - ServerTrustManager+NetworkKit

public final class APIManager {

    public static let `default` = APIManager()

    /// Handles caching request execution.
    ///
    /// - Parameters:
    ///   - request: The APIRequest to be executed.
    ///   - decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
    ///   - authTokenProvider; Authorization token provider
    ///   - completion: callback Data, Response, Error
    ///
    public final func request<T: Decodable>(_ request: APIDataRequest,
                                            _ decoder: JSONDecoder = JSONDecoder(),
                                            _ completion: @escaping APIResultHandler<T>) {
        let session = self.session(for: request)
        // Handles cache
        let cacher = self.cacher(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        _ = session
            .request(request, interceptor: interceptor)
            .cacheResponse(using: cacher)
            .validate(request.validation)
            .apiResponseDecodable(decoder: decoder) { (result: APIResult<T>) in
                _ = session // !!! Capture me! Don't let me die! ;)
                completion(result)
            }
    }

    // TODO: Stream Request

    public final func download(_ request: APIDownloadRequest,
                               _ downloadProgress: APIProgressHandler? = nil,
                               _ completion: @escaping APIResultHandler<Data>) {
        let session = self.session(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        _ = session
            .download(convertible: request, interceptor: interceptor, to: request.destination)
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseData { (result: APIResult<Data>) in
                _ = session // !!! Capture me! Don't let me die! ;)
                completion(result)
            }
    }

    public final func upload<T: Decodable>(_ request: APIUploadRequest,
                                           _ decoder: JSONDecoder = JSONDecoder(),
                                           _ uploadProgress: APIProgressHandler? = nil,
                                           _ downloadProgress: APIProgressHandler? = nil,
                                           _ completion: @escaping APIResultHandler<T>) {
        let session = self.session(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)

        _ = session
            .upload(convertible: request, interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseDecodable(decoder: decoder) { (result: APIResult<T>) in
                _ = session // !!! Capture me! Don't let me die! ;)
                completion(result)
            }
    }

    public final func upload<T: Decodable>(_ request: APIMultipartRequest,
                                           _ decoder: JSONDecoder = JSONDecoder(),
                                           _ uploadProgress: APIProgressHandler? = nil,
                                           _ downloadProgress: APIProgressHandler? = nil,
                                           _ completion: @escaping APIResultHandler<T>) {
        let session = self.session(for: request)
        // Handles refresh and retry
        let interceptor = self.interceptor(for: request)
        //
        let multipartFormData = request.asMultipartFormData()

        let _ = session
            .upload(multipartFormData: multipartFormData,
                    with: request,
                    interceptor: interceptor)
            .uploadProgress { progress in
                uploadProgress?(progress.fractionCompleted)
            }
            .downloadProgress { progress in
                downloadProgress?(progress.fractionCompleted)
            }
            .apiResponseDecodable(decoder: decoder) { (result: APIResult<T>) in
                _ = session // !!! Capture me! Don't let me die! ;)
                completion(result)
            }
    }

    // MARK: - Helpers

    private func interceptor(for request: APIRequest) -> Alamofire.Interceptor {
        Alamofire.Interceptor(adapters: request.adapters,
                              retriers: request.retriers)
    }

    private func cacher(for request: APICacheable) -> ResponseCacher {
        ResponseCacher(behavior: request.shouldCache ? .cache : .doNotCache)
    }

    private func session(for request: APIRequest) -> Alamofire.Session {
        guard let host = URL(string: request.baseUrl)?.host else {
            fatalError("Invalid base url: \(request.baseUrl)")
        }

        let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: false,
                                                    evaluators: [host: request.serverTrustEvaluator()])

        let logEventMonitor = AlamofireLogger(level: request.logLevel)

        return Alamofire.Session(serverTrustManager: serverTrustManager,
                                 eventMonitors: [logEventMonitor])
    }

}
