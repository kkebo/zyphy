public import Tokenizer

public struct TreeConstructor: ~Copyable {
    public var document: Document
    private var mode: InsertionMode

    public init() {
        self.document = .init(title: "", body: nil, head: nil)
        self.mode = .initial
    }
}

extension TreeConstructor: TokenSink {
    public mutating func process(_ token: consuming Token) {
        repeat {
            switch self.mode {
            case .initial:
                switch token {
                case .char("\t"), .char("\n"), .char("\u{0C}"), .char("\r"), .char(" "): break
                case .comment(_):
                    // TODO: Insert a comment as the last child of the Document object.
                    break
                case .doctype(_):
                    // TODO: implement here
                    self.mode = .beforeHTML
                case _:
                    // TODO: If the document is not an iframe srcdoc document, then this is a parse error; if the parser cannot change the mode flag is false, set the Document to quirks mode.
                    self.mode = .beforeHTML
                    continue
                }
            case .beforeHTML:
                switch token {
                case .doctype(_):
                    // TODO: parse error
                    break
                case .comment(_):
                    // TODO: Insert a comment as the last child of the Document object.
                    break
                case .char("\t"), .char("\n"), .char("\u{0C}"), .char("\r"), .char(" "): break
                case .tag(let tag) where tag.kind == .start && tag.name == "html":
                    // TODO: Create an element for the token in the HTML namespace, with the Document as the intended parent. Append it to the Document object. Put this element in the stack of open elements.
                    self.mode = .beforeHead
                case .tag(let tag) where tag.kind == .end && !["head", "body", "html", "br"].contains(tag.name):
                    // TODO: parse error
                    break
                case _:
                    // TODO: Create an html element whose node document is the Document object. Append it to the Document object. Put this element in the stack of open elements.
                    self.mode = .beforeHead
                    continue
                }
            case .beforeHead:
                switch token {
                case .char("\t"), .char("\n"), .char("\u{0C}"), .char("\r"), .char(" "): break
                case .comment(_):
                    // TODO: Insert a comment.
                    break
                case .doctype(_):
                    // TODO: parse error
                    break
                case .tag(let tag) where tag.kind == .start && tag.name == "html":
                    fatalError("not implemented")
                case .tag(let tag) where tag.kind == .start && tag.name == "head":
                    fatalError("not implemented")
                case .tag(let tag) where tag.kind == .end && !["head", "body", "html", "br"].contains(tag.name):
                    // TODO: parse error
                    break
                case _:
                    // TODO: implement here
                    self.mode = .inHead
                    continue
                }
            case .inHead:
                // TODO: implement here
                self.mode = .afterHead
                continue
            case .inHeadNoscript:
                fatalError("not implemented")
            case .afterHead:
                // TODO: implement here
                self.mode = .inBody
                continue
            case .inBody:
                fatalError("not implemented")
            case .text:
                fatalError("not implemented")
            case .inTable:
                fatalError("not implemented")
            case .inTableText:
                fatalError("not implemented")
            case .inCaption:
                fatalError("not implemented")
            case .inColumnGroup:
                fatalError("not implemented")
            case .inTableBody:
                fatalError("not implemented")
            case .inRow:
                fatalError("not implemented")
            case .inCell:
                fatalError("not implemented")
            case .inSelect:
                fatalError("not implemented")
            case .inSelectInTable:
                fatalError("not implemented")
            case .inTemplate:
                fatalError("not implemented")
            case .afterBody:
                fatalError("not implemented")
            case .inFrameset:
                fatalError("not implemented")
            case .afterFrameset:
                fatalError("not implemented")
            case .afterAfterBody:
                fatalError("not implemented")
            case .afterAfterFrameset:
                fatalError("not implemented")
            }
            return
        } while true
    }
}
