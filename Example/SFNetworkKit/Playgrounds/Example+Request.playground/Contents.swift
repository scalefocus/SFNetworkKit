import UIKit
import SFNetworkKit

// MARK: - Example Requests

struct ExampleGetRequest: APIDataRequest {
    var shouldCache: Bool
    

    var maximumAttempts: Int

    var authorizationTokenProvider: AuthorizationTokenProvider?

    var secretProvider: SecretProvider?

    var trustPolicy: APITrustPolicyType

    var logLevel: LogLevelType

    var parameters: RequestPayloadType {
        .query(items: ["foo1": "bar1", "foo2": "bar2"])
    }

    var baseUrl: String {
        "https://postman-echo.com/"
    }

    var path: String {
        "get"
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
APIManager.default.request(request) { (result: Result<ExampleResponse, APIError>) in
    print(result)
}
