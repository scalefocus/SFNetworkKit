//
//  Alamofire.DownloadRequest+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 8.10.20.
//

import Foundation
import Alamofire

// MARK: - Validation

extension Alamofire.DownloadRequest {
    func validate(_ validation: ValidationType) -> Self {
        let validationCodes = validation.statusCodes
        return validationCodes.isEmpty ? self : self.validate(statusCode: validationCodes)
    }
}

// MARK: - Response

extension Alamofire.DownloadRequest {
    public func apiResponseData(queue: DispatchQueue = .main,
                                dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
                                emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
                                emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
                                completionHandler: @escaping APIResultHandler<Data>) -> Self {
        responseData(queue: queue,
                     dataPreprocessor: dataPreprocessor,
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
