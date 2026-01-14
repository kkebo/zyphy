private import Foundation
private import HTMLEntities
private import Str
import Testing

private struct Entry: Decodable {
    var codepoints: [UInt32]
}

@Test
func namedCharRef() async throws {
    let dict = try JSONDecoder()
        .decode(
            [String: Entry].self,
            from: Data(contentsOf: #require(Bundle.module.url(forResource: "entities", withExtension: "json"))),
        )

    let namedCharsDict: [StrSlice: (Unicode.Scalar, Unicode.Scalar)] = .init(
        uniqueKeysWithValues: namedChars.indices.lazy.map {
            let (key, v0, v1) = namedChars[$0]
            return (key[...], (v0, v1))
        }
    )

    try await withThrowingDiscardingTaskGroup { group in
        for (key, value) in dict {
            group.addTask {
                let key = StrSlice(key.dropFirst().unicodeScalars)
                let result1 = try #require(namedCharsDict[key])
                let result2 = try #require(processedNamedChars[key])
                #expect(result1 == result2)
                switch result1 {
                case (let c1, "\0"): #expect(value.codepoints == [c1.value])
                case (let c1, let c2): #expect(value.codepoints == [c1.value, c2.value])
                }
            }
        }
    }
}
