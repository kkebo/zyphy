import Foundation
private import HTMLEntities
import Testing

private struct Entry: Decodable {
    var codepoints: [UInt32]
}

// swift-format-ignore: NeverForceUnwrap
@Test func namedCharRef() throws {
    let dict = try JSONDecoder()
        .decode(
            [String: Entry].self,
            from: Data(contentsOf: Bundle.module.url(forResource: "entities", withExtension: "json")!)
        )

    for (key, value) in dict {
        switch namedChars[String(key.dropFirst())]! {
        case (let c1, "\0"): #expect(value.codepoints == [c1.value])
        case (let c1, let c2): #expect(value.codepoints == [c1.value, c2.value])
        }
    }
}
