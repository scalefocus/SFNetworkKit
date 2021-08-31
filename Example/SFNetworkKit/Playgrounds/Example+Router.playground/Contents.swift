import Foundation
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Router

enum APIRouter: APIDataRequest {
    typealias Response = ExampleResponse
    
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

let request: APIRouter = .getPostman // .postPostman
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
