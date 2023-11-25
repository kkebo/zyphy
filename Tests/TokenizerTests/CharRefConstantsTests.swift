import Foundation
public import Testing
import Tokenizer

// swift-format-ignore: NeverForceUnwrap
@Test public func namedCharRef() throws {
    struct Entry: Decodable {
        var codepoints: [UInt32]
    }

    let dict = try JSONDecoder()
        .decode(
            [String: Entry].self,
            from: Data(contentsOf: Bundle.module.url(forResource: "entities", withExtension: "json")!)
        )

    for (k, v) in dict {
        let (c1, c2) = namedChars[String(k.dropFirst())]!
        if c2.value != 0 {
            #expect(v.codepoints == [c1.value, c2.value])
        } else {
            #expect(v.codepoints == [c1.value])
        }
    }
}
