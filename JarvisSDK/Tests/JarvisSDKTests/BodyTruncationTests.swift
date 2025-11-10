import Foundation
import Testing
@testable import JarvisInspectorData

struct BodyTruncationTests {
    @Test func smallPayloadsAreNotModified() throws {
        let original = Data(repeating: 0x1, count: 128)
        let truncated = BodyTruncation.truncateIfNeeded(original)
        #expect(truncated == original)
        #expect(!BodyTruncation.shouldTruncate(original))
        #expect(BodyTruncation.getTruncationInfo(original) == nil)
    }

    @Test func oversizedPayloadsIncludeHelpfulPrefix() throws {
        let original = Data(repeating: 0x2, count: BodyTruncation.maxBodySize + 50)
        let result = BodyTruncation.truncateIfNeeded(original)

        #expect(result != nil)
        #expect(result!.count <= BodyTruncation.maxBodySize + 200)  // includes header text

        let prefix = String(decoding: result!.prefix(60), as: UTF8.self)
        #expect(prefix.contains("Content too large"))

        let info = BodyTruncation.getTruncationInfo(original)
        #expect(info?.originalSize == original.count)
        #expect(info?.truncatedSize == BodyTruncation.maxBodySize)
        #expect(info?.message.contains("Content truncated") == true)
    }
}
