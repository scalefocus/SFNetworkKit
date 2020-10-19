//
//  Payload.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

/// A dictionary of parameters to apply to a `URLRequest`.
public typealias Parameters = Alamofire.Parameters

// MARK: - Request Payload Type

public enum RequestPayloadType {

    /// A request with no additional data.
    case plain

    /// A requests body set with data.
    case data(Data)

    /// A request body set with `Encodable` type. Encoder can be set to custom
    case json(Encodable)

    /// A requests body set as form urlencoded
    case form(Parameters)

    // ??? Consider move it to special URL Builder class
    /// Parameters added to the path http://domain.com/path/{parameter1}/{parameter2}.
    /// Not to be confused with query components.
    case path(segments: [String])

    /// URL query string components.
    case query(items: Parameters)

    /// A requests body set with data, combined with url path segments(optional) and url query parameters.
    case compositeData(bodyData: Data, pathSegments: [String]?, queryItems: [String: Any])

    /// A requests body set with `Encodable` type, combined with url path segments(optional) and url query parameters.
    case compositeJSON(bodyJSON: Encodable, pathSegments: [String]?, queryItems: [String: Any])

    /// A requests body set with encoded parameters combined url path segments(optional) and url query parameters.
    case compositeForm(bodyParameters: [String: Any],
                       pathSegments: [String]?,
                       queryItems: [String: Any])

}

// MARK: - Payload Encoder

public protocol PayloadEncoder {
    func encode(_ payload: RequestPayloadType?, into request: URLRequest) throws -> URLRequest
}

open class RequestPayloadEncoder: PayloadEncoder {
    public func encode(_ payload: RequestPayloadType?, into request: URLRequest) throws -> URLRequest {
        guard let payload = payload else { return request }

        var request = request

        switch payload {
        case .plain:
            // Do nothing
            break
        case .data(let data):
            request.httpBody = data
        case .json(let encodable):
            request = try request.encoded(encodable: encodable)
        case .form(let parameters):
            request = try request.encoded(parameters: parameters,
                                          parameterEncoding: URLEncoding.httpBody)
        case .path(let segments):
            segments.forEach { request.url?.appendPathComponent($0) }
        case .query(let parameters):
            request = try request.encoded(parameters: parameters,
                                          parameterEncoding: URLEncoding.queryString)
        case .compositeData(let data, let segments, let queryItems):
            request = try encode(.data(data), into: request)
            if let segments = segments {
                request = try encode(.path(segments: segments), into: request)
            }
            request = try encode(.query(items: queryItems), into: request)
        case .compositeJSON(let encodable, let segments, let queryItems):
            request = try encode(.json(encodable), into: request)
            if let segments = segments {
                request = try encode(.path(segments: segments), into: request)
            }
            request = try encode(.query(items: queryItems), into: request)
        case .compositeForm(let parameters, let segments, let queryItems):
            request = try encode(.form(parameters), into: request)
            if let segments = segments {
                request = try encode(.path(segments: segments), into: request)
            }
            request = try encode(.query(items: queryItems), into: request)
        }

        return request
    }
}

// MARK: - Multipart Request Payload Type

// NOTE: The value of `name` parameter is the original field name in the form.
// For example, a part might contain a header:
// Content-Disposition: form-data; name="userTextField"

// NOTE: The original local file name may be supplied as well - `fileName`

public enum MultipartRequestPayloadType {
    case data(data: Data, name: String, fileName: String?, mimeType: String?)
    case file(fileUrl: URL, name: String)
    case fileWithName(fileUrl: URL, name: String, fileName: String, mimeType: String)
    case streamWithHeaders(stream: InputStream, lenght: UInt64, headers: HTTPHeaders)
    case stream(stream: InputStream, lenght: UInt64, name: String, fileName: String, mimeType: String)
}
