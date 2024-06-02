private import Foundation
private import HTMLEntities
private import Str
import Testing

private struct Entry: Decodable {
    var codepoints: [UInt32]
}

@Test func namedCharRef() throws {
    let dict = try JSONDecoder()
        .decode(
            [String: Entry].self,
            from: Data(contentsOf: #require(Bundle.module.url(forResource: "entities", withExtension: "json")))
        )

    for (key, value) in dict {
        switch try #require(namedChars[Str(key.dropFirst().unicodeScalars)]) {
        case (let c1, "\0"): #expect(value.codepoints == [c1.value])
        case (let c1, let c2): #expect(value.codepoints == [c1.value, c2.value])
        }
    }
}
