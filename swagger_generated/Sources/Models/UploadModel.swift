//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class UploadModel: APIModel {

    public var binary: File?

    public init(binary: File? = nil) {
        self.binary = binary
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        binary = try container.decodeIfPresent("binary")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(binary, forKey: "binary")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? UploadModel else { return false }
      guard self.binary == object.binary else { return false }
      return true
    }

    public static func == (lhs: UploadModel, rhs: UploadModel) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
