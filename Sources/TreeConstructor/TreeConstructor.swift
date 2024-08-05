public import Tokenizer

public struct TreeConstructor: ~Copyable {
    public var document: Document
    private var mode: InsertionMode

    public init() {
        self.document = .init(title: "", body: nil, head: nil)
        self.mode = .initial
    }

    private mutating func step(_ token: consuming Token) -> ProcessResult {
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
            case let token:
                // TODO: If the document is not an iframe srcdoc document, then this is a parse error; if the parser cannot change the mode flag is false, set the Document to quirks mode.
                self.mode = .beforeHTML
                return .reprocess(token)
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
            case let token:
                // TODO: Create an html element whose node document is the Document object. Append it to the Document object. Put this element in the stack of open elements.
                self.mode = .beforeHead
                return .reprocess(token)
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
            case let token:
                // TODO: implement here
                self.mode = .inHead
                return .reprocess(token)
            }
        case .inHead:
            // TODO: implement here
            self.mode = .afterHead
            return .reprocess(token)
        case .inHeadNoscript:
            switch token {
            case .doctype:
                // TODO: parse error
                break
            case .tag(let tag) where tag.kind == .start && tag.name == "html":
                fatalError("not implemented")
            case .tag(let tag) where tag.kind == .end && tag.name == "noscript":
                // TODO: Pop the current node (which will be a noscript element) from the stack of open elements; the new current node will be a head element.
                self.mode = .inHead
            case .char("\t"), .char("\n"), .char("\u{0C}"), .char("\r"), .char(" "), .comment:
                fatalError("not implemented")
            case .tag(let tag) where tag.kind == .start && ["basefont", "bgsound", "link", "meta", "noframes", "style"].contains(tag.name):
                fatalError("not implemented")
            case .tag(let tag) where tag.kind == .start && ["head", "noscript"].contains(tag.name):
                // TODO: parse error
                break
            case .tag(let tag) where tag.kind == .end && tag.name != "br":
                // TODO: parse error
                break
            case let token:
                // TODO: parse error
                // TODO: Pop the current node (which will be a noscript element) from the stack of open elements; the new current node will be a head element.
                self.mode = .inHead
                return .reprocess(token)
            }
        case .afterHead:
            // TODO: implement here
            self.mode = .inBody
            return .reprocess(token)
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
        return .done
    }
}

extension TreeConstructor: TokenSink {
    public mutating func process(_ token: consuming Token) {
        repeat {
            switch self.step(token) {
            case .done: return
            case .reprocess(let t): token = t
            }
        } while true
    }
}
