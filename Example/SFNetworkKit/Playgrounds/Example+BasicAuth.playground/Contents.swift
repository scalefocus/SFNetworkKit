import Foundation
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Requests

struct ExampleBasicAuthRequest: APIDataRequest {
    typealias Response = ExampleBasicAuthResponse
    
    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        "basic-auth"
    }

    var authorizationTokenProvider: AuthorizationTokenProvider? {
        BasicAuthorizationTokenProvider()
    }

    var logLevel: LogLevelType {
        .simple
    }
}

// MARK: - Example Responses

struct ExampleBasicAuthResponse: Decodable {
    var authenticated: Bool
}

// MARK: - Example Token Provider

struct BasicAuthorizationTokenProvider: AuthorizationTokenProvider {
    var authorizationType: AuthorizationType {
        .basic
    }

    var authorizationToken: String? {
        let username = "postman"
        let password = "password"
        guard let credentialData = "\(username):\(password)".data(using: .utf8) else {
            print("Something bad had happen, Harry.")
            return nil
        }

        return credentialData.base64EncodedString()
    }
}

// MARK: - Example Call

let request = ExampleBasicAuthRequest()
let manager = APIManager.default
// `JSONDecoder` is the default decoder, it can be ommited.
// It is left here just as an example, that we can pass any decoder to parse the response
manager.request(request, JSONDecoder()) { result in
    print(result)
}

// MARK: - Combine example
import Combine
var cancellables: [AnyCancellable] = []
manager
    .requestPublisher(request, decoder: JSONDecoder())
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
