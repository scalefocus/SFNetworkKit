import Foundation
import SFNetworkKit
import PlaygroundSupport
import Combine

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Requests

// NOTE: You can switch to stored properties
struct ExampleGetRequest: APIDataRequest {
    typealias Response = ExampleResponse
    
    var parameters: RequestPayloadType {
        .query(items: ["foo1": "bar1", "foo2": "bar2"])
    }

    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        "get"
    }

    /// **This is an example how to log request and response**
    /// Use `simple` if you don't need all details
    /// Default is `none`, which means do not log anything
    var logLevel: LogLevelType {
        .verbose
    }
}

// MARK: - Example Responses

struct ExampleResponse: Decodable {
    var args: [String: String]
    var headers: [String: String]
    var url: String

    var data: String?
    var files: [String: String]?
    var form: [String: String]?
    var json: [String: String]?

    var authenticated: Bool?
}

// MARK: - Example Call

let request = ExampleGetRequest()
let manager = APIManager.default
manager.request(request) { result in
    print(result)
}

// MARK: - Combine example
import Combine
var cancellables: [AnyCancellable] = []
manager
    .requestPublisher(request)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
            print(error.localizedDescription)
        default:
            break
        }
    }, receiveValue: { result in
        print(result)
    }).store(in: &cancellables)
