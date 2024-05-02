private import DequeModule
import Testing
private import Tokenizer

private struct TestSink: ~Copyable {
    var tokens = [Token]()
}

extension TestSink: TokenSink {
    mutating func process(_ token: consuming Token) {
        self.tokens.append(token)
    }
}

@Test func basicHTML() {
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
    var input = Deque(html.unicodeScalars)
    tokenizer.tokenize(&input)

    let tokens: [Token] = [
        .doctype(.init(name: "html")),
        .char("\n"),
        .tag(Tag(name: "html", kind: .start, attrs: ["lang": "en"])),
        .char("\n"),
        .tag(Tag(name: "head", kind: .start)),
        .char("\n"),
        .tag(Tag(name: "meta", kind: .start, attrs: ["charset": "UTF-8"], selfClosing: true)),
        .char("\n"),
        .tag(Tag(name: "title", kind: .start)),
        .char("t"),
        .char("i"),
        .char("t"),
        .char("l"),
        .char("e"),
        .tag(Tag(name: "title", kind: .end)),
        .char("\n"),
        .tag(Tag(name: "head", kind: .end)),
        .char("\n"),
        .tag(Tag(name: "body", kind: .start)),
        .char("\n"),
        .char("h"),
        .char("i"),
        .char("\n"),
        .tag(Tag(name: "body", kind: .end)),
        .char("\n"),
        .tag(Tag(name: "html", kind: .end)),
        .eof,
    ]
    let result = tokenizer.sink.tokens
    #expect(result == tokens)
}
