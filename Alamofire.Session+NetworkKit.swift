//
//  Alamofire.Session+NetworkKit.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 6.10.20.
//

import Foundation
import Alamofire

extension Alamofire.Session {
    func download(convertible: DownloadableConvertible,
                  interceptor: RequestInterceptor? = nil,
                  to destination: DownloadRequest.Destination? = nil) -> DownloadRequest {
        guard let downloadable = try? convertible.createDownloadable() else {
            fatalError("Downloadable value doesn't exist.")
        }

        switch downloadable {
        case .request(let requestConvertible):
            return download(requestConvertible, interceptor: interceptor, to: destination)
        case .resumeData(let data):
            return download(resumingWith: data, interceptor: interceptor, to: destination)
        }
    }

    func upload(convertible: UploadConvertible,
                interceptor: RequestInterceptor? = nil,
                fileManager: FileManager = .default) -> UploadRequest {
        guard let uploadable = try? convertible.createUploadable() else {
            fatalError("Uploadable value doesn't exist.")
        }

        switch uploadable {
        case .data(let data):
            return upload(data, with: convertible, interceptor: interceptor, fileManager: fileManager)
        case .file(let fileUrl, _):
            return upload(fileUrl, with: convertible, interceptor: interceptor, fileManager: fileManager)
        case .stream(let stream):
            return upload(stream, with: convertible, interceptor: interceptor, fileManager: fileManager)
        }
    }
}
