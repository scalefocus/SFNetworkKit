//
//  Alamofire.DataRequest+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 8.10.20.
//

import Foundation
import Alamofire

// MARK: - Validation

extension Alamofire.DataRequest {
    func validate(_ validation: ValidationType) -> Self {
        let validationCodes = validation.statusCodes
        return validationCodes.isEmpty ? self : self.validate(statusCode: validationCodes)
    }
}

// MARK: - Response

extension Alamofire.DataRequest {
    @discardableResult
    public func apiResponseDecodable<T: Decodable>(of type: T.Type = T.self,
                                                   queue: DispatchQueue = .main,
                                                   dataPreprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
                                                   decoder: DataDecoder = JSONDecoder(),
                                                   emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
                                                   emptyRequestMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods,
                                                   completionHandler: @escaping APIResultHandler<T>) -> Self {
        responseDecodable(of: type,
                          queue: queue,
                          dataPreprocessor: dataPreprocessor,
                          decoder: decoder,
                          emptyResponseCodes: emptyResponseCodes,
                          emptyRequestMethods: emptyRequestMethods) { (response) in
            let mappedResponse = response
                .mapError { (error) -> APIError in
                    APIError.requestFailed(error: error)
                }
            completionHandler(mappedResponse.result)
        }
    }
}
