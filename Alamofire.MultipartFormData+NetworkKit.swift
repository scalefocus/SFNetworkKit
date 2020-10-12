//
//  Alamofire.MultipartFormData+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

extension Alamofire.MultipartFormData {
    public func append(_ bodyPart: APIMultipartRequestPayloadType) {
        switch bodyPart {
        case .data(let data, let name, let fileName, let mimeType):
            append(data, withName: name, fileName: fileName, mimeType: mimeType)
        case .file(let fileUrl, let name):
            append(fileUrl, withName: name)
        case .fileWithName(let fileUrl, let name, let fileName, let mimeType):
            append(fileUrl, withName: name, fileName: fileName, mimeType: mimeType)
        case .streamWithHeaders(let stream, let lenght, let headers):
            append(stream, withLength: lenght, headers: Alamofire.HTTPHeaders(headers))
        case .stream(let stream, let lenght, let name, let fileName, let mimeType):
            append(stream, withLength: lenght, name: name, fileName: fileName, mimeType: mimeType)
        }
    }

    public func append(_ bodyParts: [APIMultipartRequestPayloadType]) {
        bodyParts.forEach { append($0) }
    }
}
