import Testing
private import Tokenizer

private struct TestSink {
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
    var iter = html.makeIterator()
    tokenizer.tokenize(&iter)

    let tokens: [Token] = [
        .doctype(.init(name: "html")),
        "\n",
        .tag(Tag(name: "html", kind: .start, attrs: ["lang": "en"])),
        "\n",
        .tag(Tag(name: "head", kind: .start)),
        "\n",
        .tag(Tag(name: "meta", kind: .start, attrs: ["charset": "UTF-8"], selfClosing: true)),
        "\n",
        .tag(Tag(name: "title", kind: .start)),
        "t",
        "i",
        "t",
        "l",
        "e",
        .tag(Tag(name: "title", kind: .end)),
        "\n",
        .tag(Tag(name: "head", kind: .end)),
        "\n",
        .tag(Tag(name: "body", kind: .start)),
        "\n",
        "h",
        "i",
        "\n",
        .tag(Tag(name: "body", kind: .end)),
        "\n",
        .tag(Tag(name: "html", kind: .end)),
        .eof,
    ]
    let result = tokenizer.sink.tokens
    #expect(result == tokens)
}
