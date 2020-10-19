import Foundation
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Requests

struct ExampleOAuth1Request: APIDataRequest {
    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        "oauth1"
    }

    var parameters: RequestPayloadType {
        .plain
    }

    var logLevel: LogLevelType {
        .verbose
    }

    var authorizationTokenProvider: AuthorizationTokenProvider? {
        OAuth1TokenProvider()
    }
}

// MARK: - Example Responses

struct ExampleOAuth1Response: Decodable {
    var status: String?
    var message: String?
    var base_uri: String?
    var normalized_param_string: String?
    var base_string: String?
    var signing_key: String?
}

// MARK: - Example Token Provider

struct OAuth1TokenProvider: AuthorizationTokenProvider {
    var authorizationType: AuthorizationType {
        .custom("OAuth")
    }

    var authorizationToken: String? {
        "oauth_consumer_key=\"RKCGzna7bv9YD57c\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1602672506\",oauth_nonce=\"nKpQE4wS1eC\",oauth_signature=\"KG%2FvDzUuUEGr1kSUFGs6JrWGmXY%3D\""
    }

    func refreshToken(completion: @escaping (Bool) -> Void) {
        // TODO: Actual refresh token logic
        completion(true)
    }
}

// MARK: - Example Call

let request = ExampleOAuth1Request()
let manager = APIManager.default
manager.request(request) { (result: Result<ExampleOAuth1Response, APIError>) in
    PlaygroundPage.current.finishExecution()
}
