import Foundation
public import Testing
import Tokenizer

// swift-format-ignore: NeverForceUnwrap
@Test public func namedCharRef() throws {
    struct CodePointsAndCharacters: Codable {
        var codepoints: [UInt32]
        var characters: String
    }

    let dict = try JSONDecoder()
        .decode(
            [String: CodePointsAndCharacters].self,
            from: Data(contentsOf: Bundle.module.url(forResource: "entities", withExtension: "json")!)
        )

    for (k, v) in namedChars {
        #expect(v.unicodeScalars.map(\.value) == dict["&\(k)"]!.codepoints, .comment(k))
    }
    // TODO: minus 2
    #expect(namedChars.count + 2 == dict.count)
}
