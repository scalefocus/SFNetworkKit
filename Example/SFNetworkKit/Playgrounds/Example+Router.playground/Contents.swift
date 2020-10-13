import UIKit
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Router

enum APIRouter: APIDataRequest {

    // !!! In real world example we will have associated values to pass request's parameters
    case getPostman
    case postPostman

    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        switch self {
        case .getPostman:
            return "get"
        case .postPostman:
            return "post"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getPostman:
            return .get
        case .postPostman:
            return .post
        }
    }

    var parameters: RequestPayloadType {
        switch self {
        case .getPostman:
            return .query(items: ["foo1": "bar1", "foo2": "bar2"])
        case .postPostman:
            return .form(["foo1": "bar1", "foo2": "bar2"])
        }
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

let request: APIRouter = .getPostman // .postPostman
let manager = APIManager.default
manager.request(request) { (result: Result<ExampleResponse, APIError>) in
    print(result)

    PlaygroundPage.current.finishExecution()
}
