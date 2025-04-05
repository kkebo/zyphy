private import Str
import Testing
private import Tokenizer

private struct TestSink: ~Copyable {
    var tokens: [TestToken] = []
}

extension TestSink: TokenSink {
    mutating func process(_ token: consuming Token) {
        self.tokens.append(.init(token))
    }
}

@Test
func basicHTML() {
    let html = #"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8" />
        <title>title</title>
        </head>
        <body>
        hi
        </body>
        </html>
        """#

    var tokenizer = Tokenizer(sink: TestSink())
    var input = BufferQueue(ArraySlice(html.unicodeScalars))
    tokenizer.tokenize(&input)

    let tokens: [TestToken] = [
        .doctype(.init(name: "html")),
        .char("\n"),
        .tag(.init(name: "html", kind: .start, attrs: ["lang": "en"])),
        .char("\n"),
        .tag(.init(name: "head", kind: .start)),
        .char("\n"),
        .tag(.init(name: "meta", kind: .start, attrs: ["charset": "UTF-8"], selfClosing: true)),
        .char("\n"),
        .tag(.init(name: "title", kind: .start)),
        .chars(["t", "i", "t", "l", "e"]),
        .tag(.init(name: "title", kind: .end)),
        .char("\n"),
        .tag(.init(name: "head", kind: .end)),
        .char("\n"),
        .tag(.init(name: "body", kind: .start)),
        .char("\n"),
        .chars(["h", "i"]),
        .char("\n"),
        .tag(.init(name: "body", kind: .end)),
        .char("\n"),
        .tag(.init(name: "html", kind: .end)),
        .eof,
    ]
    let result = tokenizer.sink.tokens
    #expect(result == tokens)
}
