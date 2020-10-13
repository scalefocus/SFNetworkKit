import UIKit
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Requests

struct ExampleGetRequest: APIDataRequest {
    var parameters: RequestPayloadType {
        .query(items: ["foo1": "bar1", "foo2": "bar2"])
    }

    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        "get"
    }

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

let request = ExampleGetRequest()
let manager = APIManager.default
manager.request(request) { (result: Result<ExampleResponse, APIError>) in
    print(result)

    PlaygroundPage.current.finishExecution()
}
