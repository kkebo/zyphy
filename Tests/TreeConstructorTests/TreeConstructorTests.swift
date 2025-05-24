private import Str
import Testing
private import Tokenizer
private import TreeConstructor

@Test
func testDOM() {
    let constructor = TreeConstructor(sink: DOM())
    // constructor.process(.tag(.init(name: "a", kind: .start, attrs: ["href": "localhost"])))
    // constructor.process(.tag(.init(name: "i", kind: .start)))
    // constructor.process(.chars("text"))
    // constructor.process(.tag(.init(name: "i", kind: .end)))
    // constructor.process(.tag(.init(name: "a", kind: .end)))
    let expected = Node(
        value: .document,
        childNodes: [],
    )
    #expect(constructor.sink.document == expected)
}
