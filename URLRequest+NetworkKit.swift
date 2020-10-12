//
//  URLRequest+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

extension URLRequest {
    mutating func encoded(encodable: Encodable,
                          encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        do {
            // NOTE: Wrap to avoid compiler error
            // Value of protocol type 'Encodable' cannot conform to 'Encodable';
            // only struct/enum/class types can conform to protocols
            let encodable = AnyEncodable(encodable)
            httpBody = try encoder.encode(encodable)

            let contentTypeHeaderName = "Content-Type"
            if value(forHTTPHeaderField: contentTypeHeaderName) == nil {
                setValue("application/json", forHTTPHeaderField: contentTypeHeaderName)
            }

            return self
        } catch {
            throw APIError.jsonEncodingFailed(error: error)
        }
    }

    func encoded(parameters: Parameters, parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw APIError.parameterEncodingFailed(error: error)
        }
    }
}

// MARK: - Helpers

struct AnyEncodable: Encodable {

    private let encodable: Encodable

    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
