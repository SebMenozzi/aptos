import Foundation
import Rswift

public struct Sound: Hashable {
    let fileResource: FileResource

    public var url: URL? {
        fileResource.url()
    }

    public var fileName: String {
        fileResource.name
    }

    public init(_ fileResource: FileResource) {
        self.fileResource = fileResource
    }

    public var hashValue: Int { url.hashValue }
    public func hash(into hasher: inout Hasher) {
        url.hash(into: &hasher)
    }

    public static func == (lhs: Sound, rhs: Sound) -> Bool {
        lhs.url == rhs.url
    }
}
