//
//  APIRequest.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

// MARK: - Aliases

/// Represents an HTTP method.
public typealias HTTPMethod = Alamofire.HTTPMethod

/// Represents a header for a request
public typealias HTTPHeaders = [String: String]

/// Type describing the origin of the upload, whether `Data`, file, or stream.
public typealias APIUploadPayload = Alamofire.UploadRequest.Uploadable

// MARK: - Settings

public struct Settings {

    public static let `default` = Settings()

    /// Returns the default timeout for every request. Default value is 30 s
    public let requestTimeout: TimeInterval = 30

    /// The default set of `HTTPHeaders` used by Alamofire. Includes `Accept-Encoding`, `Accept-Language`, and `User-Agent`.
    public var headers: HTTPHeaders {
        Alamofire.HTTPHeaders.default.dictionary
    }

}

// MARK: - Base Request Protocol

/// The protocol used to define the specifications necessary for the `Networker` to build an `URLRequest`
public protocol APIRequest: URLConvertible, URLRequestConvertible, APIAuthorizable, APISecretable, APITrustPolicySettable, APILoggable, APICacheable, APIRefreshable {

    /// Base url(<host.com>).
    var baseUrl: String { get }

    /// Base path of the endpoint, without any possible parameters.  Will be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request. Default HTTP Method is `get`.
    var httpMethod: HTTPMethod { get }

    /// The HTTP header fields for the request. Default is `defaultHTTPHeaders`.
    var headers: HTTPHeaders { get }

    var timeout: TimeInterval { get }

    /// `true` if cookies will be sent with and set for this request; otherwise `false`.
    var shouldHandleCookies: Bool { get }

    var validation: ValidationType { get }

}

// MARK: - Default values

public extension APIRequest {

    /// Default HTTP Method is `get`
    var httpMethod: HTTPMethod {
        .get
    }

    /// Default is `defaultHTTPHeaders`
    var headers: HTTPHeaders {
        Settings.default.headers
    }

    /// Default is `defaultTimeout` - 30 s
    var timeout: TimeInterval {
        Settings.default.requestTimeout
    }

    /// Default is `true`
    var shouldHandleCookies: Bool {
        true
    }

    /// Default is `none`
    var validation: ValidationType {
        .none
    }

}

// MARK: - URLConvertible

public extension APIRequest {
    func asURL() throws -> URL {
        guard let url = URL(string: baseUrl) else {
            throw APIError.invalidBaseUrl
        }

        return url.appendingPathComponent(path)
    }
}

public extension APIRequest {
    func asURLRequest() throws -> URLRequest {
        try urlRequest()
    }

    func urlRequest() throws -> URLRequest {
        var urlRequest = try URLRequest(url: self,
                                        method: httpMethod,
                                        headers: Alamofire.HTTPHeaders(headers))

        urlRequest.httpShouldHandleCookies = shouldHandleCookies
        urlRequest.timeoutInterval = timeout

        return urlRequest
    }
}

// MARK: - Interceptor Helpers

extension APIRequest {
    var adapters: [Alamofire.RequestAdapter] {
        var adapters: [RequestAdapter] = []

        if let provider = authorizationTokenProvider {
            adapters.append(APIAuthorizationTokenAdapter(tokenProvider: provider))
        }

        if let provider = secretProvider {
            adapters.append(APISecretAdapter(secretProvider: provider))
        }

        return adapters
    }

    var retriers: [Alamofire.RequestRetrier] {
        var retriers: [Alamofire.RequestRetrier] = [
            ConnectionLostRetryPolicy()
        ]

        if let provider = authorizationTokenProvider {
            retriers.append(APIAuthorizationTokenRefreshPolicy(tokenProvider: provider))
        }

        return retriers
    }
}

// MARK: - Other Requests

// Data request

public protocol APIDataRequest: APIRequest {
    /// Encapsulates the parameters that should be passed to the server.  Dafault is `.plain` - no parameters.
    var parameters: RequestPayloadType { get }
}

public extension APIDataRequest {
    /// Dafault is `.plain` - no parameters
    var parameters: RequestPayloadType {
        .plain
    }
}

public extension APIDataRequest {
    func asURLRequest() throws -> URLRequest {
        var urlRequest = try self.urlRequest()

        let encoder = RequestPayloadEncoder()
        urlRequest = try encoder.encode(parameters, into: urlRequest)

        return urlRequest
    }
}

// Download request

public typealias APIDownloadPayload = Alamofire.DownloadRequest.Downloadable
public typealias APIDownloadDestination = Alamofire.DownloadRequest.Destination

public protocol APIDownloadRequest: DownloadableConvertible, APIDataRequest {
    var downloadable: APIDownloadPayload { get }
    var destination: APIDownloadDestination? { get }
}

public extension APIDownloadRequest {
    var downloadable: APIDownloadPayload {
        .request(self)
    }

    var destination: APIDownloadDestination? {
        nil
    }
}

public extension APIDownloadRequest {
    func createDownloadable() throws -> APIDownloadPayload {
        downloadable
    }
}

// Upload request

public protocol APIUploadRequest: UploadConvertible, APIRequest {
    var uploadable: APIUploadPayload { get }
}

public extension APIUploadRequest {
    func createUploadable() throws -> APIUploadPayload {
        uploadable
    }
}

// Multipart request

public protocol APIMultipartRequest: APIRequest {
    /// The parameters that should be passed to the server.
    var bodyParts: [MultipartRequestPayloadType] { get }
}

public extension APIMultipartRequest {
    func asMultipartFormData() -> Alamofire.MultipartFormData {
        let multipartFormData = Alamofire.MultipartFormData()
        bodyParts.forEach {
            switch $0 {
            case .data(let data, let name, let fileName, let mimeType):
                multipartFormData.append(data,
                                         withName: name,
                                         fileName: fileName,
                                         mimeType: mimeType)
            case .file(let fileUrl, let name):
                multipartFormData.append(fileUrl, withName: name)
            case .fileWithName(let fileUrl, let name, let fileName, let mimeType):
                multipartFormData.append(fileUrl,
                                         withName: name,
                                         fileName: fileName,
                                         mimeType: mimeType)
            case .stream(let stream, let lenght, let name, let fileName, let mimeType):
                multipartFormData.append(stream,
                                         withLength: lenght,
                                         name: name,
                                         fileName: fileName,
                                         mimeType: mimeType)
            case .streamWithHeaders(let stream, let lenght, let headers):
                multipartFormData.append(stream,
                                         withLength: lenght,
                                         headers: Alamofire.HTTPHeaders(headers))
            }
        }
        return multipartFormData
    }
}

///

// MARK: - Helper Protocols

public protocol APICacheable {
    /// `true` if  this request should be cached; otherwise `false`.
    var shouldCache: Bool { get }
}

public extension APICacheable {
    /// Default is `false`.
    var shouldCache: Bool {
        false
    }
}

//

public protocol APIRefreshable {
    /// Total refresh attempts allowed within `interval` before throwing an `.excessiveRefresh` error.
    var maximumAttempts: Int { get }
}

public extension APIRefreshable {
    /// Default is `zero`
    var maximumAttempts: Int {
        0
    }
}

//

public protocol APIAuthorizable {
    var authorizationTokenProvider: AuthorizationTokenProvider? { get }
}

public extension APIAuthorizable {
    var authorizationTokenProvider: AuthorizationTokenProvider? {
        nil
    }
}

//

public protocol APISecretable {
    var secretProvider: SecretProvider? { get }
}

public extension APISecretable {
    var secretProvider: SecretProvider? {
        nil
    }
}

//

public protocol APITrustPolicySettable {
    var trustPolicy: APITrustPolicyType { get }
}

public extension APITrustPolicySettable {
    // Applications should always validate the host in production environments
    var trustPolicy: APITrustPolicyType {
        .host
    }
}

public extension APITrustPolicySettable {
    func serverTrustEvaluator() -> Alamofire.ServerTrustEvaluating {
        switch self.trustPolicy {
        case .none:
            return Alamofire.DisabledTrustEvaluator()
        case .host:
            return Alamofire.DefaultTrustEvaluator()
        case .revocation(let options):
            return Alamofire.RevocationTrustEvaluator(options: options)
        case .pinnedCertificates(let provider):
            return Alamofire.PinnedCertificatesTrustEvaluator(certificates: provider.certificates,
                                                              acceptSelfSignedCertificates: provider.acceptSelfSignedCertificates)
        case .publicKeys(let provider):
            return Alamofire.PublicKeysTrustEvaluator(keys: provider.keys)
        }
    }
}

//

public protocol APILoggable {
    var logLevel: LogLevelType { get }
}

public extension APILoggable {
    var logLevel: LogLevelType {
        .none
    }
}

// MARK: - Alamofire

// NOTE: Strange but DownloadableConvertible is not implemented in Alamofire

/// A type that can produce an `APIDownloadPayload` value.
public protocol DownloadableConvertible {
    /// Produces an `APIDownloadPayload` value from the instance.
    ///
    /// - Returns: The `APIDownloadPayload`.
    /// - Throws:  Any `Error` produced during creation.
    func createDownloadable() throws -> APIDownloadPayload
}

extension APIDownloadPayload: DownloadableConvertible {
    public func createDownloadable() throws -> APIDownloadPayload {
        self
    }
}

/// A type that can be converted to an upload, whether from an `APIDownloadPayload` or `URLRequestConvertible`.
public protocol DownloadConvertible: DownloadableConvertible & URLRequestConvertible {}
