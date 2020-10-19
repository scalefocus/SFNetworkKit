//
//  Logging.swift
//  NetworkKit
//
//  Created by Aleksandar Sergeev Petrov on 8.10.20.
//

import Foundation
import Alamofire

// Idea is from:
// https://github.com/Digipolitan/alamofire-logging
// &
// https://github.com/konkab/AlamofireNetworkActivityLogger/blob/master/Source/NetworkActivityLogger.swift
// but adapted for Alamofire 5+

public enum LogLevelType {
    case none
    case simple
    case verbose
}

//

final class AlamofireLogger: EventMonitor {
    private var level: LogLevelType

    init(level: LogLevelType) {
        self.level = level
    }

    /// The queue used for logging.
    private let _queue = DispatchQueue(label: "com.scalefocus.networkkit.log")
    var queue: DispatchQueue {
        _queue
    }

//    func requestDidResume(_ request: Request) {
//        guard level != .none else {
//            return
//        }
//
//        guard let method = request.lastRequest?.httpMethod, let url = request.lastRequest?.url else {
//            return
//        }
//
//        var message = "[REQUEST] \(method) \(url.absoluteString)"
//
//        if level == .verbose {
//            if let headers = request.lastRequest?.allHTTPHeaderFields {
//                for header in headers {
//                    message += "\n\(header.key): \(header.value)"
//                }
//            }
//            if let data = request.lastRequest?.httpBody, let body = String(data: data, encoding: .utf8) {
//                message += "\n\(body)"
//            }
//        }
//
//        print(message)
//    }

    func requestDidFinish(_ request: Request) {
        guard level != .none else {
            return
        }

        guard let method = request.lastRequest?.httpMethod, let url = request.lastRequest?.url else {
            return
        }

        var message = "[REQUEST] [\(request.id)] \(method) \(url.absoluteString)"

        if level == .verbose {
            if let headers = request.lastRequest?.allHTTPHeaderFields {
                for header in headers {
                    message += "\n\(header.key): \(header.value)"
                }
            }
            if let data = request.lastRequest?.httpBody, let body = String(data: data, encoding: .utf8) {
                message += "\n\(body)"
            }
        }

        print(message)

        message = "[RESPONSE] [\(request.id)] \(method) \(request.response?.statusCode ?? -1) \(url) \(String(format: "%.3fms", (request.metrics?.taskInterval.duration ?? 0) * 1000))"

        if let err = request.error?.localizedDescription {
            message += " [!] \(err)"
        }

        if level == .verbose {
            if let headers = request.response?.allHeaderFields {
                for header in headers {
                    message += "\n\(header.key): \(header.value)"
                }
            }
            if let data = (request as? DataRequest)?.data, let body = String(data: data, encoding: .utf8) {
                if body.count > 0 {
                    message += "\n\(body)"
                }
            }
            if let fileUrl = (request as? DownloadRequest)?.fileURL {
                message += "\n\(fileUrl)"
            }
        }

        print(message)
    }
}
