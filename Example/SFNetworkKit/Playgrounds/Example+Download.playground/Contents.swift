import Foundation
import SFNetworkKit
import PlaygroundSupport

// resolve path errors
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Example Requests

// NOTE: This is an example how we can use path parameters.
// You can build the url in many other ways
struct ExampleDownloadRequest: APIDownloadRequest {

    var baseUrl: String {
        "https://www.hackingwithswift.com/"
    }

    var path: String {
        "img"
    }

    var parameters: RequestPayloadType {
        .path(segments: ["hws", "example-code-294-1.png"])
    }
}

// MARK: - Example Call

let request = ExampleDownloadRequest()
let manager = APIManager.default
manager.download(request) { (result) in
    let data = try! result.get()
    let image = UIImage.init(data: data)!
    show(image: image)
//    PlaygroundPage.current.finishExecution()
}

// МАРК: - Helpers

func show(image: UIImage) {
    let imageView = UIImageView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 916,
                                              height: 611))
    imageView.image = image
    PlaygroundPage.current.liveView = imageView
    PlaygroundPage.current.liveView
}
